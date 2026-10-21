% Solver sensitivity for the saved physical weak-grid case.
repo=fileparts(fileparts(mfilename('fullpath')));mdl='Vataleni_PMSG_SSO_Final';
if bdIsLoaded(mdl),close_system(mdl,0);end
load_system(fullfile(repo,'model',[mdl '.slx']));
mw=get_param(mdl,'ModelWorkspace');
assignin(mw,'wind_initial',12);assignin(mw,'wind_final',13);
assignin(mw,'wind_step_time',2);assignin(mw,'grid_scr',5);
assignin(mw,'mitigation_enable',0);
set_param(mdl,'MaxStep','0.0005');
fprintf('START convergence 0.5 ms\n');drawnow;
o=sim(mdl,'StopTime','6','ReturnWorkspaceOutputs','on');
t=(0:0.01:6)';T=table(t,'VariableNames',{'time_s'});
for name={'dc_voltage','pcc_vq','pcc_power','grid_id','machine_id','machine_iq'}
 s=o.get(name{1});[tt,ix]=unique(s.Time(:),'last');z=s.Data(ix);
 T.(name{1})=interp1(tt,z,t,'linear','extrap');
end
outdir=fullfile(repo,'results','physical');
writetable(T,fullfile(outdir,'weak_grid_half_step.csv'));
fprintf('DONE convergence Vdc %.6f, Pgrid %.6f MW\n', ...
 mean(T.dc_voltage(t>=5.5)),mean(T.pcc_power(t>=5.5))/1e6);drawnow;
close_system(mdl,0);
