% Each live Scope input gets its own display so V, A, N m and rad/s do not
% share one numeric y-axis. No physical or control connections are changed.
repo=fileparts(fileparts(mfilename('fullpath')));
file=fullfile(repo,'model','Vataleni_PMSG_SSO_Final.slx');
mdl='Vataleni_PMSG_SSO_Final';
load_system(file);
sc=find_system(mdl,'LookUnderMasks','all','BlockType','Scope');
assert(numel(sc)==12);
for k=1:numel(sc)
 ph=get_param(sc{k},'PortHandles');n=numel(ph.Inport);
 cfg=get_param(sc{k},'ScopeConfiguration');
 assert(str2double(string(cfg.NumInputPorts))==n);
 cfg.LayoutDimensions=[n 1];
 cfg.Position=[120 100 1200 720];
 cfg.ShowLegend=true;
 fprintf('SCOPE_LAYOUT %s %d displays\n',get_param(sc{k},'Name'),n);
end
save_system(mdl,file);
close_system(mdl,0);
fprintf('SCOPE_LAYOUT_SAVE_PASS\n');
