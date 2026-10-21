function root = init_project()
%INIT_PROJECT Configure reproducible project paths and graphics defaults.
root = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(root,'scripts'));
addpath(fullfile(root,'tests'));
dirs = {'model','data/generated','results/baseline','results/sso', ...
    'results/mitigation','results/sweeps','results/validation','figures', ...
    'artifacts/environment','artifacts/logs','artifacts/model_snapshots'};
for k = 1:numel(dirs)
    d = fullfile(root,dirs{k});
    if ~isfolder(d), mkdir(d); end
end
set(groot,'defaultAxesFontName','Times New Roman', ...
    'defaultAxesFontSize',10,'defaultLineLineWidth',1.25, ...
    'defaultFigureColor','w');
fprintf('Vataleni PMSG SSO project initialized: %s\n',root);
end
