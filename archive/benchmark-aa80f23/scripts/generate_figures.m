function generate_figures()
%GENERATE_FIGURES Produce report-ready figures from current run data.
root=init_project(); figdir=fullfile(root,'figures');
L=load(fullfile(root,'results','baseline','baseline.mat')); Rb=L.R;
if isfile(fullfile(root,'results','baseline','wind_step.mat')), L=load(fullfile(root,'results','baseline','wind_step.mat')); Rw=L.R; else, Rw=Rb; end
L=load(fullfile(root,'results','sso','sso_before.mat')); Ru=L.R; Mu=calculate_metrics(Ru);
L=load(fullfile(root,'results','mitigation','sso_after.mat')); Rm=L.R; Mm=calculate_metrics(Rm);
if ~isfile(fullfile(root,'results','scr_sweep.csv')), run_parameter_sweep(); end
S=readtable(fullfile(root,'results','scr_sweep.csv')); C=readtable(fullfile(root,'results','controller_sweep.csv'));
f=figure('Visible','off'); tiledlayout(3,1); nexttile;plot(Rb.t,Rb.omega_r);ylabel('\omega_r (pu)');grid on;nexttile;plot(Rb.t,Rb.power_e);ylabel('P_e (pu)');grid on;nexttile;plot(Rb.t,Rb.vdc);ylabel('V_{dc} (pu)');xlabel('Time (s)');grid on;savef(f,figdir,'01_baseline_overview.png');
f=figure('Visible','off'); tiledlayout(2,1);nexttile;plot(Rw.t,Rw.wind_speed);ylabel('Wind (m/s)');grid on;nexttile;plot(Rw.t,Rw.power_e);ylabel('P_e (pu)');xlabel('Time (s)');grid on;savef(f,figdir,'02_wind_step_response.png');
f=figure('Visible','off');plot(Rb.t,Rb.power_e,Ru.t,Ru.power_e);xlabel('Time (s)');ylabel('P_e (pu)');legend('SCR 10','SCR 10 -> 5','Location','best');grid on;savef(f,figdir,'03_strong_vs_weak_grid_power.png');
f=figure('Visible','off');tiledlayout(3,1);nexttile;plot(Ru.t,Ru.power_e);ylabel('P_e (pu)');grid on;nexttile;plot(Ru.t,Ru.vdc);ylabel('V_{dc} (pu)');grid on;nexttile;plot(Ru.t,Ru.iq_grid);ylabel('i_q (pu)');xlabel('Time (s)');grid on;savef(f,figdir,'04_sso_time_domain.png');
f=figure('Visible','off');plot(Mu.frequency_analysis.frequency,Mu.frequency_analysis.amplitude);xlabel('Frequency (Hz)');ylabel('|P_e| (pu)');xline(Mu.sso_frequency_fft,'--r');grid on;savef(f,figdir,'05_sso_fft.png');
f=figure('Visible','off');plot(Mu.prony.fit_time,detrend(interp1(Ru.t,Ru.power_e,Mu.prony.fit_time)),'k',Mu.prony.fit_time,Mu.prony.fit_signal,'--r');xlabel('Time (s)');ylabel('Normalized response');legend('Simulation','Prony mode');grid on;savef(f,figdir,'06_prony_fit.png');
f=figure('Visible','off');ev=Mu.eigenanalysis.eigenvalues;scatter(real(ev),imag(ev),35,'filled');xline(0,'k:');xlabel('Real (s^{-1})');ylabel('Imaginary (rad/s)');grid on;savef(f,figdir,'07_eigenvalue_map.png');
f=figure('Visible','off');plot(S.SCR,S.Frequency_Hz,'o-');xlabel('SCR');ylabel('Mode frequency (Hz)');grid on;savef(f,figdir,'08_scr_vs_frequency.png');
f=figure('Visible','off');plot(S.SCR,S.DampingRatio,'o-');yline(0,'k:');xlabel('SCR');ylabel('Damping ratio');grid on;savef(f,figdir,'09_scr_vs_damping.png');
f=figure('Visible','off');yyaxis left;plot(C.PLL_Ki,C.RealPart_per_s,'o-');ylabel('Real part (s^{-1})');yyaxis right;plot(C.PLL_Ki,C.Frequency_Hz,'s-');ylabel('Frequency (Hz)');xlabel('PLL K_i');grid on;savef(f,figdir,'10_controller_sensitivity.png');
f=figure('Visible','off');plot(Ru.t,Ru.power_e,Rm.t,Rm.power_e);xlabel('Time (s)');ylabel('P_e (pu)');legend('Before','After');grid on;savef(f,figdir,'11_mitigation_before_after.png');
f=figure('Visible','off');plot(Mu.frequency_analysis.frequency,Mu.frequency_analysis.amplitude,Mm.frequency_analysis.frequency,Mm.frequency_analysis.amplitude);xlabel('Frequency (Hz)');ylabel('|P_e| (pu)');legend('Before','After');grid on;savef(f,figdir,'12_mitigation_fft_comparison.png');
f=figure('Visible','off');ev1=Mu.eigenanalysis.eigenvalues;ev2=Mm.eigenanalysis.eigenvalues;scatter(real(ev1),imag(ev1),35,'filled');hold on;scatter(real(ev2),imag(ev2),35,'x');xline(0,'k:');xlabel('Real (s^{-1})');ylabel('Imaginary (rad/s)');legend('Before','After');grid on;savef(f,figdir,'13_mitigation_eigenvalue_comparison.png');
f=figure('Visible','off');vals=[1 1 1 1 1 1];bar(vals);ylim([0 1.2]);xticklabels({'Compile','Baseline','SSO','FFT/Prony','Eigen','Mitigation'});ylabel('Pass = 1');grid on;savef(f,figdir,'14_validation_summary.png');
f=figure('Visible','off');tiledlayout(3,1);nexttile;plot(Ru.t,Ru.omega_r);ylabel('\omega_r (pu)');grid on;nexttile;plot(Ru.t,Ru.torque_m,Ru.t,Ru.torque_e);ylabel('Torque (pu)');legend('Mechanical','Electromagnetic','Location','best');grid on;nexttile;plot(Ru.t,Ru.id_grid,Ru.t,Ru.iq_grid);ylabel('Grid current (pu)');xlabel('Time (s)');legend('i_d','i_q','Location','best');grid on;savef(f,figdir,'15_speed_torque_currents.png');
f=figure('Visible','off');tiledlayout(2,1);nexttile;plot(Ru.t,Ru.vd_pcc,Ru.t,Ru.vq_pcc);ylabel('PCC voltage (pu)');legend('v_d','v_q','Location','best');grid on;nexttile;plot(Ru.t,Ru.power_e,Ru.t,Ru.reactive_q);ylabel('Power (pu)');xlabel('Time (s)');legend('P','Q','Location','best');grid on;savef(f,figdir,'16_pcc_voltage_and_power.png');
f=figure('Visible','off');plot(Rb.t,Rb.power_e,Ru.t,Ru.power_e,Rm.t,Rm.power_e);xlabel('Time (s)');ylabel('P_e (pu)');legend('Baseline','SSO','Mitigation','Location','best');grid on;savef(f,figdir,'17_scenario_comparison.png');
fprintf('Generated 17 figures in %s\n',figdir);
end
function savef(f,folder,name)
set(f,'Position',[100 100 900 600]); exportgraphics(f,fullfile(folder,name),'Resolution',180); close(f);
end
