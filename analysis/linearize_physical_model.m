% Closed-loop Simscape small-signal poles at simulation snapshots.
% Requires Simulink Control Design. Scenario waveforms do not depend on it.
repo=fileparts(fileparts(mfilename('fullpath')));mdl='Vataleni_PMSG_SSO_Final';
if bdIsLoaded(mdl),close_system(mdl,0);end
load_system(fullfile(repo,'model',[mdl '.slx']));
mw=get_param(mdl,'ModelWorkspace');
assignin(mw,'wind_initial',12);assignin(mw,'wind_final',12);
assignin(mw,'wind_step_time',2);
io=[linio([mdl '/Wind 12mps'],1,'input'); ...
    linio([mdl '/Telemetry and Scopes/Data Logging/From pcc_vq'],1,'output')];
cases={'strong',10,0;'weak',5,0;'weak_mitigated',5,1};
rows=cell(0,6);
for k=1:size(cases,1)
 assignin(mw,'grid_scr',cases{k,2});
 assignin(mw,'mitigation_enable',cases{k,3});
 fprintf('LINEARIZE %s\n',cases{k,1});drawnow;
 sys=linearize(mdl,io,5.5);
 E=eig(sys.A);E=E(imag(E)>2*pi&imag(E)<2*pi*45);
 [~,ind]=sort(real(E),'descend');E=E(ind);
 for j=1:numel(E)
  p=E(j);rows(end+1,:)={cases{k,1},j,real(p),imag(p), ...
      imag(p)/(2*pi),-real(p)/abs(p)};
 end
 fprintf('DOMINANT %s %.7f %+.7fi, %.5f Hz, zeta %.5f\n', ...
  cases{k,1},real(E(1)),imag(E(1)),imag(E(1))/(2*pi),-real(E(1))/abs(E(1)));drawnow;
end
T=cell2table(rows,'VariableNames', ...
 {'case','rank','real_per_s','imag_rad_s','frequency_Hz','damping_ratio'});
writetable(T,fullfile(repo,'results','physical','linearized_modes.csv'));
close_system(mdl,0);
