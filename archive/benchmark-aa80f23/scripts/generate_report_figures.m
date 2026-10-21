function generate_report_figures()
%GENERATE_REPORT_FIGURES Additional publication figures for the technical report.
%Regenerates the timestep-sensitivity sweep and a zoomed eigenvalue view from
%fresh execution; does not duplicate figures already produced by generate_figures.m.
root = init_project();
outDir = fullfile(root,'report','evidence','figures');
if ~isfolder(outDir), mkdir(outDir); end

mdl = 'Vataleni_PMSG_SSO_Final';
load_system(fullfile(root,'model',[mdl '.slx']));

%% --- Timestep sensitivity sweep -----------------------------------------
dts = [1e-3, 5e-4, 2e-4, 1e-4];
freqs = zeros(size(dts));
for i = 1:numel(dts)
    P = configure_case('sso_before'); P.sim.dt = dts(i);
    in = Simulink.SimulationInput(mdl);
    scenario={'wind_nom',P.wind.v_nom;'wind_step',P.wind.v_step;'wind_step_time',P.wind.t_step; ...
        'scr_initial',P.grid.scr_initial;'scr_final',P.grid.scr_final; ...
        'grid_disturbance_time',P.grid.t_disturbance;'mitigation_enable',double(P.mitigation.enable)};
    for j=1:size(scenario,1), in=in.setVariable(scenario{j,1},scenario{j,2},'Workspace',mdl); end
    in = in.setModelParameter('StopTime',num2str(P.sim.t_end,17),'FixedStep',num2str(P.sim.dt,17));
    out = sim(in);
    y = squeeze(out.get('simlog')); tout = out.get('tout');
    if size(y,1)==35 && size(y,2)==numel(tout), y=y.'; end
    F = analyse_frequency(tout, y(:,9), P.analysis.band, P.sim.analysis_start);
    freqs(i) = F.dominant_frequency;
    fprintf('dt=%.1e s -> FFT SSO frequency = %.4f Hz\n', dts(i), freqs(i));
end
close_system(mdl,0);

Tdt = table(dts(:), freqs(:), 'VariableNames', {'dt_s','fft_frequency_Hz'});
writetable(Tdt, fullfile(root,'report','evidence','logs','dt_sensitivity_sweep.csv'));

fig = figure('Visible','off','Position',[100 100 900 550]);
semilogx(dts, freqs, '-o', 'LineWidth', 1.5, 'MarkerSize', 7, 'MarkerFaceColor','auto');
grid on; box on;
xlabel('Solver fixed step, dt (s)');
ylabel('FFT-identified SSO frequency (Hz)');
set(gca,'FontSize',11);
xticks(sort(dts)); xticklabels(arrayfun(@(x) sprintf('%.1e',x), sort(dts), 'UniformOutput', false));
yline(freqs(end), '--', sprintf('Converged: %.4f Hz', freqs(end)), 'LabelHorizontalAlignment','left');
exportgraphics(fig, fullfile(outDir,'07_dt_sensitivity.png'), 'Resolution', 200);
close(fig);

%% --- Zoomed eigenvalue view (dominant SSO mode only) ---------------------
Lu = load(fullfile(root,'results','sso','sso_before.mat'));
Lm = load(fullfile(root,'results','mitigation','sso_after.mat'));
Mb = calculate_metrics(Lu.R); Ma = calculate_metrics(Lm.R);

fig = figure('Visible','off','Position',[100 100 800 650]);
hold on; grid on; box on;
plot(real(Mb.eigenvalue), imag(Mb.eigenvalue), 'bo', 'MarkerSize', 12, 'MarkerFaceColor','b');
plot(real(Mb.eigenvalue), -imag(Mb.eigenvalue), 'bo', 'MarkerSize', 12, 'MarkerFaceColor','b','HandleVisibility','off');
plot(real(Ma.eigenvalue), imag(Ma.eigenvalue), 'rx', 'MarkerSize', 14, 'LineWidth', 2.5);
plot(real(Ma.eigenvalue), -imag(Ma.eigenvalue), 'rx', 'MarkerSize', 14, 'LineWidth', 2.5,'HandleVisibility','off');
xline(0, ':k', 'LineWidth', 1.2);
annotation_str = sprintf('Before: %.4f %+.4fi\nAfter:  %.4f %+.4fi', ...
    real(Mb.eigenvalue), imag(Mb.eigenvalue), real(Ma.eigenvalue), imag(Ma.eigenvalue));
text(min(real(Ma.eigenvalue),real(Mb.eigenvalue))-0.15, max(imag(Mb.eigenvalue),imag(Ma.eigenvalue))+2, ...
    annotation_str, 'FontSize', 9, 'VerticalAlignment','bottom');
xlabel('Real  (s^{-1})'); ylabel('Imaginary  (rad/s)');
legend({'Before mitigation (unstable)','After mitigation (stable)'}, 'Location','southoutside');
title('Dominant sub-synchronous mode: zoomed view');
set(gca,'FontSize',11);
xlim([min(real(Ma.eigenvalue),real(Mb.eigenvalue))-1, max(real(Ma.eigenvalue),real(Mb.eigenvalue))+1]);
exportgraphics(fig, fullfile(outDir,'zoomed_eigenvalue_dominant_mode.png'), 'Resolution', 200);
close(fig);

fprintf('Report figures written to %s\n', outDir);
end
