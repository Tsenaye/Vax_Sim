function R = run_case(case_name,save_result)
%RUN_CASE Execute one scenario using the authoritative self-contained model.
if nargin<2, save_result=true; end
root=init_project(); P=configure_case(case_name);
model='Vataleni_PMSG_SSO_Final'; modelPath=fullfile(root,'model',[model '.slx']);
if ~isfile(modelPath), build_model(); end
load_system(modelPath);
in=Simulink.SimulationInput(model);
scenario = { ...
    'wind_nom',P.wind.v_nom; ...
    'wind_step',P.wind.v_step; ...
    'wind_step_time',P.wind.t_step; ...
    'scr_initial',P.grid.scr_initial; ...
    'scr_final',P.grid.scr_final; ...
    'grid_disturbance_time',P.grid.t_disturbance; ...
    'mitigation_enable',double(P.mitigation.enable)};
for k=1:size(scenario,1)
    in=in.setVariable(scenario{k,1},scenario{k,2},'Workspace',model);
end
in=in.setModelParameter('StopTime',num2str(P.sim.t_end,17), ...
    'FixedStep',num2str(P.sim.dt,17));
out=sim(in);
raw=out.get('simlog'); tout=out.get('tout');
y=squeeze(raw);
if size(y,1)==35 && size(y,2)==numel(tout)
    y=y.';
elseif size(y,2)~=35
    error('PMSG:MissingLog','Expected 35 logged channels; received size %s.',mat2str(size(raw)));
end
assert(size(y,1)==numel(tout),'PMSG:LogLength','Logged data and time vector lengths differ.');
assert(all(isfinite(y),'all'),'PMSG:NonFinite','Simulation produced NaN/Inf.');
names={'wind_speed','omega_r','torque_m','power_m','iq_machine','vdc','id_grid','iq_grid', ...
    'power_e','reactive_q','vd_pcc','vq_pcc','v_pcc','pll_angle','ia','va','current_pu','scr','cp','lambda', ...
    'turbine_speed','electrical_rotor_speed','torque_e','id_machine','iq_machine_reference', ...
    'vcd_reference','vcq_reference','pll_frequency_hz','sso_signal','damping_gain', ...
    'controller_command','grid_voltage_pu','id_grid_reference','iq_grid_reference','pll_ki_selected'};
R=struct('case_name',case_name,'P',P,'t',tout(:));
for k=1:numel(names), R.(names{k})=y(:,k); end
R.logged_signal_names=names;
R.created=datetime('now','TimeZone','local');
if save_result
    switch lower(case_name)
        case {'baseline','wind_step'}, folder='baseline';
        case {'weak_grid','sso_before'}, folder='sso';
        otherwise, folder='mitigation';
    end
    save(fullfile(root,'results',folder,[case_name '.mat']),'R');
end
close_system(model,0);
fprintf('%s: %d samples, max|I|=%.3f pu, Vdc range %.3f..%.3f pu\n', ...
    case_name,numel(R.t),max(R.current_pu),min(R.vdc),max(R.vdc));
end
