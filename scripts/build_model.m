function modelPath = build_model()
%BUILD_MODEL Build the self-contained native Simulink implementation.
% Core dynamics are embedded in MATLAB Function blocks inside the SLX.  The
% model has no run-time dependency on project M-files or the base workspace.

root = init_project();
P = init_parameters();
x0 = pmsg_initial_state(P);
mdl = 'Vataleni_PMSG_SSO_Final';
modelPath = fullfile(root,'model',[mdl '.slx']);
if bdIsLoaded(mdl), close_system(mdl,0); end
new_system(mdl);
set_param(mdl, ...
    'Solver','ode4','SolverType','Fixed-step','FixedStep',num2str(P.sim.dt,17), ...
    'StopTime',num2str(P.sim.t_end,17),'ReturnWorkspaceOutputs','on', ...
    'SaveTime','on','TimeSaveName','tout','SignalLogging','off', ...
    'AlgebraicLoopMsg','error','UnconnectedInputMsg','error', ...
    'UnconnectedOutputMsg','warning','UnconnectedLineMsg','error');

% Scenario controls.  Defaults live in the model workspace and may be
% overridden for a SimulationInput without rebuilding the model.
add_block('simulink/Sources/Step',[mdl '/Wind Profile'], ...
    'Time','wind_step_time','Before','wind_nom','After','wind_step', ...
    'SampleTime','0','Position',[25 252 95 282]);
add_block('simulink/Sources/Step',[mdl '/Grid SCR Profile'], ...
    'Time','grid_disturbance_time','Before','scr_initial','After','scr_final', ...
    'SampleTime','0','Position',[25 435 95 465]);
add_block('simulink/Sources/Constant',[mdl '/Mitigation Selector'], ...
    'Value','mitigation_enable','Position',[495 65 565 95]);
add_block('simulink/Sources/Clock',[mdl '/Simulation Time'], ...
    'Position',[1080 455 1110 475]);

build_wind_pmsg(mdl,x0,P,[150 205 340 330]);
fprintf('  built Wind Turbine + PMSG\n'); drawnow;
build_msc(mdl,x0,P,[150 25 340 150]);
fprintf('  built MSC Control\n'); drawnow;
build_dc_link(mdl,x0,P,[405 205 575 330]);
fprintf('  built DC Link\n'); drawnow;
build_gsc(mdl,x0,P,[635 195 825 350]);
fprintf('  built GSC Control\n'); drawnow;
build_pll(mdl,x0,P,[635 25 825 150]);
fprintf('  built PLL\n'); drawnow;
build_grid_current(mdl,x0,P,[885 205 1085 350]);
fprintf('  built Grid Current Dynamics\n'); drawnow;
build_pcc(mdl,P,[885 25 1085 150]);
fprintf('  built PCC Interface\n'); drawnow;
build_measurements(mdl,P,[1145 120 1375 430]);
fprintf('  built Measurements\n'); drawnow;

add_block('simulink/Sinks/To Workspace',[mdl '/Simulation Log'], ...
    'VariableName','simlog','SaveFormat','Array','MaxDataPoints','inf', ...
    'Position',[1430 255 1535 290]);

% Main physical/control signal paths.
L = @(a,b) add_line(mdl,a,b,'autorouting','on');
L('Wind Profile/1','Wind Turbine + PMSG/1');
L('MSC Control/1','Wind Turbine + PMSG/2');
L('Wind Turbine + PMSG/1','MSC Control/1');
L('Wind Turbine + PMSG/2','DC Link/1');
L('Wind Turbine + PMSG/1','DC Link/2');
L('PCC Interface/2','DC Link/3');
L('DC Link/1','GSC Control/1');
L('Grid Current Dynamics/1','GSC Control/2');
L('Grid Current Dynamics/2','GSC Control/3');
L('Wind Turbine + PMSG/2','GSC Control/4');
L('PCC Interface/1','PLL/1');
L('Mitigation Selector/1','PLL/2');
L('GSC Control/1','Grid Current Dynamics/1');
L('GSC Control/2','Grid Current Dynamics/2');
L('PLL/1','Grid Current Dynamics/3');
L('PLL/2','Grid Current Dynamics/4');
L('Grid SCR Profile/1','Grid Current Dynamics/5');
L('PLL/1','PCC Interface/1');
L('Grid Current Dynamics/1','PCC Interface/2');
L('Grid Current Dynamics/2','PCC Interface/3');
L('Grid SCR Profile/1','PCC Interface/4');

% Compact subsystem diagnostic vectors keep the top-level diagram readable.
meas = {'Wind Profile/1','Wind Turbine + PMSG/3','MSC Control/2','DC Link/1', ...
    'GSC Control/3','PLL/3','Grid Current Dynamics/3','PCC Interface/3', ...
    'Mitigation Selector/1','Grid SCR Profile/1','Simulation Time/1'};
for k=1:numel(meas), L(meas{k},sprintf('Measurements and Analysis Interface/%d',k)); end
L('Measurements and Analysis Interface/1','Simulation Log/1');

add_block('built-in/Note',[mdl '/Architecture'], ...
    'Position',[150 -55 1375 -15], ...
    'Name',sprintf(['WIND -> TURBINE + PMSG -> MSC -> DC LINK -> GSC -> GRID CURRENT -> PCC / WEAK GRID\n' ...
    'PLL synchronises to PCC voltage. All equations and continuous states are embedded in this SLX.']));
set_param(mdl,'Location',[40 40 1580 720]);

% Arrange and mask the engineering subsystems.  Masks keep the top level
% architectural while double-clicking still exposes every native block.
subNames={'Wind Turbine + PMSG','MSC Control','DC Link','GSC Control','PLL', ...
    'Grid Current Dynamics','PCC Interface','Measurements and Analysis Interface'};
for k=1:numel(subNames)
    sub=[mdl '/' subNames{k}];
    Simulink.BlockDiagram.arrangeSystem(sub);
    set_param(sub,'ShowName','on');
    mask=Simulink.Mask.create(sub);
    mask.Display='';
    try, mask.IconOpaque='opaque-with-ports'; catch, end
end

% Deterministic self-contained scenario defaults.
mw = get_param(mdl,'ModelWorkspace');
assignin(mw,'wind_nom',P.wind.v_nom);
assignin(mw,'wind_step',P.wind.v_step);
assignin(mw,'wind_step_time',P.wind.t_step);
assignin(mw,'scr_initial',P.grid.scr_initial);
assignin(mw,'scr_final',P.grid.scr_final);
assignin(mw,'grid_disturbance_time',P.grid.t_disturbance);
assignin(mw,'mitigation_enable',double(P.mitigation.enable));

save_system(mdl,modelPath);
fprintf('  saved model, compiling\n'); drawnow;
set_param(mdl,'SimulationCommand','update');
fprintf('  compiled model\n'); drawnow;
loops = Simulink.BlockDiagram.getAlgebraicLoops(mdl);
assert(isempty(loops),'PMSG:AlgebraicLoops','Native model contains %d algebraic loop(s).',numel(loops));
save_system(mdl);
close_system(mdl,0);
fprintf('Built native self-contained model: %s\n',modelPath);
end

function build_wind_pmsg(mdl,x0,P,pos)
sub = fresh_subsystem(mdl,'Wind Turbine + PMSG',pos);
add_in(sub,'Wind speed (m_s)',1,[25 55 55 69]);
add_in(sub,'iq machine (pu)',2,[25 135 55 149]);
add_block('simulink/Continuous/Integrator',[sub '/Rotor speed state'], ...
    'InitialCondition',num2str(x0(1),17),'Position',[265 52 300 88]);
code = sprintf([ ...
 'function [domega,Pm,Tm,Cp,lambda] = dynamics(v,omega,iqm)\n' ...
 '%%#codegen\n' ...
 'v=max(double(v),0.1); omega=max(double(omega),0.05);\n' ...
 'lambda=(omega*%.17g)*%.17g/v; beta=%.17g;\n' ...
 'invli=1/(lambda+0.08*beta)-0.035/(beta^3+1); li=1/max(invli,1e-3);\n' ...
 'Cp=0.22*(116/li-0.4*beta-5)*exp(-12.5/li); Cp=min(max(Cp,0),0.50);\n' ...
 'Pwind=0.5*%.17g*%.17g*Cp*v^3; Pm=min(max(Pwind/%.17g,0),1.15);\n' ...
 'Tm=Pm/omega; domega=(Tm-iqm-%.17g*(omega-1))/(2*%.17g);\n' ...
 'end'],P.wind.omega_base,P.wind.R,P.wind.beta,P.wind.rho,P.wind.A,P.base.S,P.pmsg.D,P.pmsg.H);
add_chart(sub,'Embedded aerodynamic and rotor equations',code,[105 35 225 165]);
outs={'omega_r (pu)','P_mech (pu)'};
for k=1:2, add_out(sub,outs{k},k,[390 35+45*(k-1) 420 49+45*(k-1)]); end
line(sub,'Wind speed (m_s)/1','Embedded aerodynamic and rotor equations/1');
line(sub,'Rotor speed state/1','Embedded aerodynamic and rotor equations/2');
line(sub,'iq machine (pu)/1','Embedded aerodynamic and rotor equations/3');
line(sub,'Embedded aerodynamic and rotor equations/1','Rotor speed state/1');
line(sub,'Rotor speed state/1','omega_r (pu)/1');
line(sub,'Embedded aerodynamic and rotor equations/2','P_mech (pu)/1');
add_vector_output(sub,'diagnostics',3,{'Rotor speed state/1', ...
    'Embedded aerodynamic and rotor equations/2','Embedded aerodynamic and rotor equations/3', ...
    'Embedded aerodynamic and rotor equations/4','Embedded aerodynamic and rotor equations/5'});
end

function build_msc(mdl,x0,P,pos)
sub=fresh_subsystem(mdl,'MSC Control',pos);
add_in(sub,'omega_r (pu)',1,[20 65 50 79]);
add_block('simulink/Continuous/Integrator',[sub '/iq state'],'InitialCondition',num2str(x0(2),17),'Position',[275 35 310 65]);
add_block('simulink/Continuous/Integrator',[sub '/speed PI state'],'InitialCondition',num2str(x0(3),17),'Position',[275 105 310 135]);
code=sprintf([ ...
 'function [diq,dxi,iq_ref] = control(omega,iq,xi)\n' ...
 '%%#codegen\n' ...
 'iq_ref=%.17g*(omega-1)+xi; diq=(iq_ref-iq)/%.17g; dxi=%.17g*(omega-1);\n' ...
 'end'],P.msc.Kp_speed,P.msc.tau_current,P.msc.Ki_speed);
add_chart(sub,'Embedded MSC equations',code,[95 35 225 145]);
outs={'iq_machine (pu)'};
add_out(sub,outs{1},1,[385 35 415 49]);
line(sub,'omega_r (pu)/1','Embedded MSC equations/1');
line(sub,'iq state/1','Embedded MSC equations/2');
line(sub,'speed PI state/1','Embedded MSC equations/3');
line(sub,'Embedded MSC equations/1','iq state/1');
line(sub,'Embedded MSC equations/2','speed PI state/1');
line(sub,'iq state/1','iq_machine (pu)/1');
add_vector_output(sub,'diagnostics',2,{'iq state/1','speed PI state/1','Embedded MSC equations/3'});
end

function build_dc_link(mdl,x0,P,pos)
sub=fresh_subsystem(mdl,'DC Link',pos);
ins={'P_mech (pu)','omega_r (pu)','P_grid (pu)'};
for k=1:3,add_in(sub,ins{k},k,[20 35+50*(k-1) 50 49+50*(k-1)]);end
add_block('simulink/Continuous/Integrator',[sub '/DC voltage state'],'InitialCondition',num2str(x0(4),17),'Position',[270 75 305 105]);
code=sprintf(['function dv = dynamics(Pm,omega,Pout,vdc)\n%%#codegen\n' ...
    'dv=(Pm*omega-Pout)/(%.17g*max(vdc,0.25));\nend'],P.dc.C_pu);
add_chart(sub,'Embedded power balance',code,[95 35 220 140]);
add_out(sub,'vdc (pu)',1,[385 82 415 96]);
for k=1:3,line(sub,sprintf('%s/1',ins{k}),sprintf('Embedded power balance/%d',k));end
line(sub,'DC voltage state/1','Embedded power balance/4');
line(sub,'Embedded power balance/1','DC voltage state/1');
line(sub,'DC voltage state/1','vdc (pu)/1');
end

function build_gsc(mdl,x0,P,pos)
sub=fresh_subsystem(mdl,'GSC Control',pos);
ins={'vdc (pu)','id (pu)','iq (pu)','P_mech (pu)'};
for k=1:4,add_in(sub,ins{k},k,[20 25+45*(k-1) 50 39+45*(k-1)]);end
ics=x0([6 8 9]); states={'dc PI state','id PI state','iq PI state'};
for k=1:3,add_block('simulink/Continuous/Integrator',[sub '/' states{k}], ...
        'InitialCondition',num2str(ics(k),17),'Position',[275 30+60*(k-1) 310 60+60*(k-1)]);end
code=sprintf([ ...
 'function [dxdc,dxid,dxiq,vcd,vcq,id_ref,iq_ref] = control(vdc,id,iq,Pm,xdc,xid,xiq)\n' ...
 '%%#codegen\n' ...
 'id_ref=Pm+%.17g*(vdc-%.17g)+xdc; iq_ref=0;\n' ...
 'vcd=%.17g+%.17g*(id_ref-id)+xid-%.17g*iq;\n' ...
 'vcq=%.17g*(iq_ref-iq)+xiq+%.17g*id;\n' ...
 'dxdc=%.17g*(vdc-%.17g); dxid=%.17g*(id_ref-id); dxiq=%.17g*(iq_ref-iq);\n' ...
 'end'],P.gsc.Kp_dc,P.dc.v_ref,P.grid.E,P.gsc.Kp_current,P.filter.X, ...
 P.gsc.Kp_current,P.filter.X,P.gsc.Ki_dc,P.dc.v_ref,P.gsc.Ki_current,P.gsc.Ki_current);
add_chart(sub,'Embedded GSC equations',code,[85 20 235 190]);
outs={'vcd command (pu)','vcq command (pu)'};
for k=1:2,add_out(sub,outs{k},k,[390 35+55*(k-1) 420 49+55*(k-1)]);end
for k=1:4,line(sub,sprintf('%s/1',ins{k}),sprintf('Embedded GSC equations/%d',k));end
for k=1:3
    line(sub,sprintf('%s/1',states{k}),sprintf('Embedded GSC equations/%d',4+k));
    line(sub,sprintf('Embedded GSC equations/%d',k),sprintf('%s/1',states{k}));
end
line(sub,'Embedded GSC equations/4','vcd command (pu)/1');
line(sub,'Embedded GSC equations/5','vcq command (pu)/1');
add_vector_output(sub,'diagnostics',3,{'Embedded GSC equations/4','Embedded GSC equations/5', ...
    'dc PI state/1','id PI state/1','iq PI state/1','Embedded GSC equations/6','Embedded GSC equations/7'});
end

function build_pll(mdl,x0,P,pos)
sub=fresh_subsystem(mdl,'PLL',pos);
add_in(sub,'vq (pu)',1,[20 45 50 59]); add_in(sub,'mitigation enable',2,[20 115 50 129]);
add_block('simulink/Continuous/Integrator',[sub '/angle state'],'InitialCondition',num2str(x0(10),17),'Position',[275 35 310 65]);
add_block('simulink/Continuous/Integrator',[sub '/PLL PI state'],'InitialCondition',num2str(x0(11),17),'Position',[275 105 310 135]);
code=sprintf([ ...
 'function [ddelta,dxi,domega,Ki] = control(vq,mitig,delta,xi)\n' ...
 '%%#codegen\n' ...
 'if mitig>0.5, Ki=%.17g; else, Ki=%.17g; end\n' ...
 'domega=%.17g*vq+xi; dxi=Ki*vq; ddelta=%.17g*domega; delta=delta;\n' ...
 'end'],P.pll.Ki_mitigated,P.pll.Ki_base,P.pll.Kp,P.base.w);
add_chart(sub,'Embedded PLL equations',code,[85 35 225 145]);
outs={'delta (rad)','frequency deviation (pu)'};
for k=1:2,add_out(sub,outs{k},k,[385 35+55*(k-1) 415 49+55*(k-1)]);end
line(sub,'vq (pu)/1','Embedded PLL equations/1'); line(sub,'mitigation enable/1','Embedded PLL equations/2');
line(sub,'angle state/1','Embedded PLL equations/3'); line(sub,'PLL PI state/1','Embedded PLL equations/4');
line(sub,'Embedded PLL equations/1','angle state/1'); line(sub,'Embedded PLL equations/2','PLL PI state/1');
line(sub,'angle state/1','delta (rad)/1'); line(sub,'Embedded PLL equations/3','frequency deviation (pu)/1');
add_vector_output(sub,'diagnostics',3,{'angle state/1','Embedded PLL equations/3','PLL PI state/1','Embedded PLL equations/4'});
end

function build_grid_current(mdl,x0,P,pos)
sub=fresh_subsystem(mdl,'Grid Current Dynamics',pos);
ins={'vcd (pu)','vcq (pu)','delta (rad)','frequency deviation (pu)','SCR'};
for k=1:5,add_in(sub,ins{k},k,[20 20+38*(k-1) 50 34+38*(k-1)]);end
add_block('simulink/Continuous/Integrator',[sub '/id state'],'InitialCondition',num2str(x0(5),17),'Position',[285 45 320 75]);
add_block('simulink/Continuous/Integrator',[sub '/iq state'],'InitialCondition',num2str(x0(7),17),'Position',[285 120 320 150]);
code=sprintf([ ...
 'function [did,diq] = dynamics(vcd,vcq,delta,domega,scr,id,iq)\n' ...
 '%%#codegen\n' ...
 'Xg=1/max(scr,0.1); Rg=Xg/%.17g; Lt=%.17g+Xg; R=%.17g+Rg; E=%.17g;\n' ...
 'did=%.17g/Lt*(vcd-E*cos(delta)-R*id+Lt*(1+domega)*iq);\n' ...
 'diq=%.17g/Lt*(vcq+E*sin(delta)-R*iq-Lt*(1+domega)*id);\n' ...
 'end'],P.grid.xr,P.filter.X,P.filter.R,P.grid.E,P.base.w,P.base.w);
add_chart(sub,'Embedded filter-grid equations',code,[80 25 240 185]);
add_out(sub,'id (pu)',1,[395 55 425 69]); add_out(sub,'iq (pu)',2,[395 125 425 139]);
for k=1:5,line(sub,sprintf('%s/1',ins{k}),sprintf('Embedded filter-grid equations/%d',k));end
line(sub,'id state/1','Embedded filter-grid equations/6'); line(sub,'iq state/1','Embedded filter-grid equations/7');
line(sub,'Embedded filter-grid equations/1','id state/1'); line(sub,'Embedded filter-grid equations/2','iq state/1');
line(sub,'id state/1','id (pu)/1'); line(sub,'iq state/1','iq (pu)/1');
add_vector_output(sub,'diagnostics',3,{'id state/1','iq state/1'});
end

function build_pcc(mdl,P,pos)
sub=fresh_subsystem(mdl,'PCC Interface',pos);
ins={'delta (rad)','id (pu)','iq (pu)','SCR'};
for k=1:4,add_in(sub,ins{k},k,[20 25+45*(k-1) 50 39+45*(k-1)]);end
code=sprintf([ ...
 'function [vd,vq,p,q,vmag] = interface(delta,id,iq,scr)\n' ...
 '%%#codegen\n' ...
 'Xg=1/max(scr,0.1); Rg=Xg/%.17g; E=%.17g;\n' ...
 'vd=E*cos(delta)+Rg*id-Xg*iq; vq=-E*sin(delta)+Rg*iq+Xg*id;\n' ...
 'p=vd*id+vq*iq; q=vq*id-vd*iq; vmag=hypot(vd,vq);\n' ...
 'end'],P.grid.xr,P.grid.E);
add_chart(sub,'Embedded PCC equations',code,[90 35 235 165]);
outs={'vq (pu)','P_grid (pu)'};
for k=1:2,add_out(sub,outs{k},k,[390 45+55*(k-1) 420 59+55*(k-1)]);end
for k=1:4,line(sub,sprintf('%s/1',ins{k}),sprintf('Embedded PCC equations/%d',k));end
line(sub,'Embedded PCC equations/2','vq (pu)/1');
line(sub,'Embedded PCC equations/3','P_grid (pu)/1');
add_vector_output(sub,'diagnostics',3,{'Embedded PCC equations/1','Embedded PCC equations/2', ...
    'Embedded PCC equations/3','Embedded PCC equations/4','Embedded PCC equations/5'});
end

function build_measurements(mdl,P,pos)
sub=fresh_subsystem(mdl,'Measurements and Analysis Interface',pos);
ins={'wind','wind_pmsg','msc','vdc','gsc','pll','grid_current','pcc','mitig','scr','time_s'};
for k=1:numel(ins),add_in(sub,ins{k},k,[15 8+17*(k-1) 35 18+17*(k-1)]);end
code=sprintf([ ...
 'function y = measurements(wind,wind_pmsg,msc,vdc,gsc,pll,grid_current,pcc,mitig,scr,time_s)\n' ...
 '%%#codegen\n' ...
 'omega=wind_pmsg(1); Pm=wind_pmsg(2); Tm=wind_pmsg(3); Cp=wind_pmsg(4); lambda=wind_pmsg(5);\n' ...
 'iqm=msc(1); xi_m=msc(2); iqm_ref=msc(3);\n' ...
 'vcd=gsc(1); vcq=gsc(2); xi_dc=gsc(3); xi_id=gsc(4); xi_iq=gsc(5); id_ref=gsc(6); iq_ref=gsc(7);\n' ...
 'delta=pll(1); domega=pll(2); xi_pll=pll(3); pll_ki=pll(4);\n' ...
 'id=grid_current(1); iq=grid_current(2);\n' ...
 'vd=pcc(1); vq=pcc(2); p=pcc(3); q=pcc(4); vmag=pcc(5);\n' ...
 'theta=%.17g*time_s+delta; Ibase=%.17g; Vphase=%.17g;\n' ...
 'ia=sqrt(2)*Ibase*(id*cos(theta)-iq*sin(theta)); va=sqrt(2)*Vphase*(vd*cos(theta)-vq*sin(theta));\n' ...
 'imag=hypot(id,iq); Ki=pll_ki;\n' ...
 'y=[wind;omega;Tm;Pm;iqm;vdc;id;iq;p;q;vd;vq;vmag;delta;ia;va;imag;scr;Cp;lambda; ...\n' ...
 'omega;omega;iqm;0;iqm_ref;vcd;vcq;%.17g*(1+domega);p;Ki;domega;%.17g;id_ref;iq_ref;pll_ki];\n' ...
 'xi_m=xi_m; xi_dc=xi_dc; xi_id=xi_id; xi_iq=xi_iq; xi_pll=xi_pll;\n' ...
 'end'],P.base.w,P.base.I,P.base.Vll/sqrt(3),P.base.f,P.grid.E);
add_chart(sub,'Embedded measurements',code,[75 105 245 335]);
add_out(sub,'Logged vector (35)',1,[390 215 425 229]);
for k=1:numel(ins),line(sub,sprintf('%s/1',ins{k}),sprintf('Embedded measurements/%d',k));end
line(sub,'Embedded measurements/1','Logged vector (35)/1');
end

function sub=fresh_subsystem(mdl,name,pos)
sub=[mdl '/' name];
add_block('simulink/Ports & Subsystems/Subsystem',sub,'Position',pos);
try, delete_line(sub,'In1/1','Out1/1'); catch, end
try, delete_block([sub '/In1']); catch, end
try, delete_block([sub '/Out1']); catch, end
end

function add_in(sub,name,port,pos)
add_block('simulink/Ports & Subsystems/In1',[sub '/' name], ...
    'Port',num2str(port),'Position',pos);
end

function add_out(sub,name,port,pos)
add_block('simulink/Ports & Subsystems/Out1',[sub '/' name], ...
    'Port',num2str(port),'Position',pos);
end

function add_chart(sub,name,code,pos)
path=[sub '/' name];
add_block('simulink/User-Defined Functions/MATLAB Function',path,'Position',pos);
rt=sfroot;
chart=rt.find('-isa','Stateflow.EMChart','Path',path);
assert(~isempty(chart),'PMSG:ChartCreation','Could not locate MATLAB Function block %s.',path);
chart.Script=code;
end

function line(sub,a,b)
add_line(sub,a,b,'autorouting','on');
end

function add_vector_output(sub,name,port,sources)
mux=[sub '/' name ' mux']; out=[sub '/' name];
add_block('simulink/Signal Routing/Mux',mux,'Inputs',num2str(numel(sources)), ...
    'Position',[335 245 340 245+18*numel(sources)]);
add_out(sub,name,port,[395 260 425 274]);
for k=1:numel(sources), line(sub,sources{k},sprintf('%s mux/%d',name,k)); end
line(sub,[name ' mux/1'],[name '/1']);
end
