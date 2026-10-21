repo=fileparts(fileparts(mfilename('fullpath')));
asset=fullfile(repo,'Final_Delivery','Presentation_Assets');
if ~exist(asset,'dir'),mkdir(asset);end
w=readtable(fullfile(repo,'results','physical','weak_grid.csv'));
m=readtable(fullfile(repo,'results','physical','weak_grid_mitigated.csv'));
s=readtable(fullfile(repo,'results','physical','wind_variation.csv'));
make_figure(w,'Weak grid, no mitigation',fullfile(asset,'06_sso_unmitigated'));
make_figure(m,'Weak grid, PLL mitigation',fullfile(asset,'07_sso_mitigated'));
f=figure('Visible','off','Color','w','Position',[100 100 1200 650]);
ix=s.time_s>=1.8&s.time_s<=4.5;
plot(s.time_s(ix),s.pcc_vq(ix),'Color',[.16 .38 .65],'LineWidth',1.6);hold on;
plot(w.time_s(ix),w.pcc_vq(ix),'Color',[.78 .31 .13],'LineWidth',1.6);
plot(m.time_s(ix),m.pcc_vq(ix),'Color',[.13 .48 .34],'LineWidth',1.6);
xline(2,'--','Wind step','LabelVerticalAlignment','bottom');
xlim([1.8 4.5]);ylim([-15 15]);grid on;
xlabel('Time (s)');ylabel('PCC q-axis voltage (V)');
title('Identical 12 to 13 m/s wind step: grid and PLL comparison');
legend('SCR 10','SCR 5','SCR 5, mitigated','Location','northeast');
exportgraphics(f,fullfile(asset,'08_scenario_comparison.png'),'Resolution',300);
exportgraphics(f,fullfile(asset,'08_scenario_comparison.pdf'),'ContentType','vector');
close(f);
fprintf('NATIVE_MATLAB_PLOTS_PASS\n');
function make_figure(T,label,stem)
 f=figure('Visible','off','Color','w','Position',[100 100 1200 650]);
 ix=T.time_s>=1.8&T.time_s<=4.5;
 plot(T.time_s(ix),T.pcc_vq(ix),'Color',[.13 .35 .58],'LineWidth',1.6);
 xline(2,'--','Wind step','LabelVerticalAlignment','bottom');
 xlim([1.8 4.5]);ylim([-15 15]);grid on;
 xlabel('Time (s)');ylabel('PCC q-axis voltage (V)');title(label);
 exportgraphics(f,[stem '.png'],'Resolution',300);
 exportgraphics(f,[stem '.pdf'],'ContentType','vector');
 close(f);
end
