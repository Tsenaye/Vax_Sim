repo=fileparts(fileparts(mfilename('fullpath')));
mdl='Vataleni_PMSG_SSO_Final';
load_system(fullfile(repo,'model',[mdl '.slx']));
sc=find_system(mdl,'LookUnderMasks','all','BlockType','Scope');
for k=1:numel(sc)
 cfg=get_param(sc{k},'ScopeConfiguration');
 ph=get_param(sc{k},'PortHandles');
 fprintf('SCOPE %s | ports=%d | cfgports=%s | layout=%s | position=%s\n', ...
  get_param(sc{k},'Name'),numel(ph.Inport),string(cfg.NumInputPorts), ...
  mat2str(cfg.LayoutDimensions),mat2str(cfg.Position));
end
close_system(mdl,0);
