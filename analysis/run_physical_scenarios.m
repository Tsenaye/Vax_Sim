% Run this file in MATLAB R2025b or newer. The SLX owns all default values.
repo=fileparts(fileparts(mfilename('fullpath')));
mdl='Vataleni_PMSG_SSO_Final';
if bdIsLoaded(mdl),close_system(mdl,0);end
load_system(fullfile(repo,'model',[mdl '.slx']));
outdir=fullfile(repo,'results','physical');
if ~exist(outdir,'dir'),mkdir(outdir);end
cases={
 'baseline',12,10,0;
 'wind_variation',13,10,0;
 'weak_grid',13,5,0;
 'weak_grid_mitigated',13,5,1;
};
names={'wind_speed','shaft_speed','shaft_angle','generator_torque', ...
 'machine_id','machine_iq','machine_iqref','machine_vd','machine_vq', ...
 'machine_vd_actual','machine_vq_actual','machine_pgen', ...
 'machine_copper_loss','dc_voltage','msc_dc_current','gsc_dc_current', ...
 'dc_energy','dc_power_net','grid_id','grid_iq','grid_idref', ...
 'gsc_iabc','pcc_vd','pcc_vq','pcc_power','reactive_power', ...
 'pcc_voltage_magnitude','pll_omega','mitigation_enable'};
mw=get_param(mdl,'ModelWorkspace');
for k=1:size(cases,1)
 name=cases{k,1};
 assignin(mw,'wind_initial',12);assignin(mw,'wind_final',cases{k,2});
 assignin(mw,'wind_step_time',2);assignin(mw,'grid_scr',cases{k,3});
 assignin(mw,'mitigation_enable',cases{k,4});
 fprintf('START %s\n',name);drawnow;
 o=sim(mdl,'StopTime','6','ReturnWorkspaceOutputs','on');
 t=(0:0.01:6)';T=table(t,'VariableNames',{'time_s'});
 for j=1:numel(names)
  s=o.get(names{j});assert(isa(s,'timeseries'),['Missing live signal: ' names{j}]);
  z=squeeze(s.Data);tt=s.Time(:);
  if isvector(z),z=z(:);end
  if size(z,1)~=numel(tt),z=z';end
  [tt,idx]=unique(tt,'last');z=z(idx,:);
  if numel(tt)<2
   w=repmat(z(1,:),numel(t),1);
  else
   w=interp1(tt,z,t,'linear','extrap');
  end
  if size(z,2)==1
   T.(names{j})=w;
  else
   for phase=1:size(z,2)
    T.([names{j} '_' num2str(phase)])=w(:,phase);
   end
  end
 end
 assert(all(isfinite(T{:,:}),'all'),['Nonfinite data: ' name]);
 writetable(T,fullfile(outdir,[name '.csv']));
 ix=t>=5.5;
 fprintf('DONE %s: DC %.4f V, Pgrid %.5f MW, PCC q std %.6f V\n', ...
  name,mean(T.dc_voltage(ix)),mean(T.pcc_power(ix))/1e6, ...
  std(T.pcc_vq(ix)));drawnow;
end
close_system(mdl,0);
fprintf('ALL PHYSICAL CASES SAVED\n');
