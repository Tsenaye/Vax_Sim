function [Tscr,Tctrl]=run_parameter_sweep()
%RUN_PARAMETER_SWEEP Fast small-signal screening using the exact ODE Jacobian.
root=init_project(); P=configure_case('sso_before');
scr=(3:0.25:12)'; nr=numel(scr); realp=zeros(nr,1); freq=zeros(nr,1); zeta=zeros(nr,1);
target=5;
for k=1:nr
    P.grid.scr_final=scr(k); E=analyse_eigenvalues(P,target); target=E.critical_frequency;
    realp(k)=real(E.critical_eigenvalue); freq(k)=E.critical_frequency; zeta(k)=E.critical_damping_ratio;
end
Tscr=table(scr,realp,freq,zeta,'VariableNames',{'SCR','RealPart_per_s','Frequency_Hz','DampingRatio'});
writetable(Tscr,fullfile(root,'results','scr_sweep.csv'));
ki=(0.5:0.1:3.2)'; nr=numel(ki); realp=zeros(nr,1); freq=zeros(nr,1); zeta=zeros(nr,1);
P=configure_case('sso_before'); target=5;
for k=1:nr
    P.pll.Ki_base=ki(k); E=analyse_eigenvalues(P,target); target=E.critical_frequency;
    realp(k)=real(E.critical_eigenvalue); freq(k)=E.critical_frequency; zeta(k)=E.critical_damping_ratio;
end
Tctrl=table(ki,realp,freq,zeta,'VariableNames',{'PLL_Ki','RealPart_per_s','Frequency_Hz','DampingRatio'});
writetable(Tctrl,fullfile(root,'results','controller_sweep.csv'));
save(fullfile(root,'results','sweeps','small_signal_sweeps.mat'),'Tscr','Tctrl');
fprintf('Small-signal sweeps complete: %d SCR points, %d controller points.\n',height(Tscr),height(Tctrl));
end
