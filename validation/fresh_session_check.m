% Execute with matlab -batch in a new process, without running any init file.
repo=fileparts(fileparts(mfilename('fullpath')));mdl='Vataleni_PMSG_SSO_Final';
assert(~evalin('base','exist(''wind_initial'',''var'')'), ...
 'Base workspace already contains scenario variables');
load_system(fullfile(repo,'model',[mdl '.slx']));
sc=find_system(mdl,'LookUnderMasks','all','BlockType','Scope');
assert(numel(sc)==12,'Expected twelve native live Scopes');
% MathWorks native Simscape masks contain internal S-functions. Inspect only
% user-authored model levels for an external custom S-function dependency.
custom=find_system(mdl,'LookUnderMasks','none','FollowLinks','off', ...
 'BlockType','S-Function');
assert(isempty(custom),'User-level custom S-function block found');
for k=1:numel(sc)
 ph=get_param(sc{k},'PortHandles');
 for j=1:numel(ph.Inport)
  line=get_param(ph.Inport(j),'Line');
  assert(line~=-1,['Unwired live Scope input: ' sc{k}]);
  src=get_param(line,'SrcBlockHandle');
  assert(strcmp(get_param(src,'BlockType'),'From'), ...
   ['Scope input is not a live routed signal: ' sc{k}]);
 end
end
set_param(mdl,'SimulationCommand','update');
o=sim(mdl);
assert(abs(o.tout(end)-6)<1e-9,'Saved stop time is not six seconds');
for tag={'dc_voltage','machine_id','machine_iq','machine_vd_actual', ...
         'machine_pgen','pcc_vq','pcc_power','pll_omega', ...
         'msc_dc_current','gsc_dc_current'}
 s=o.get(tag{1});assert(isa(s,'timeseries')&&numel(s.Time)>100, ...
  ['Missing live output ' tag{1}]);
 assert(all(isfinite(s.Data),'all'),['Nonfinite output ' tag{1}]);
end
out=fullfile(repo,'results','physical','fresh_session_audit.txt');
fid=fopen(out,'w');
fprintf(fid,'MATLAB: %s\nModel: %s\n',version,mdl);
fprintf(fid,'Fresh base workspace scenario variables: none\n');
fprintf(fid,'Scope count: %d\nStop time: %.3f s\n',numel(sc),o.tout(end));
fprintf(fid,'All Scope input ports have live routed sources: yes\n');
fprintf(fid,'Custom S-function count: %d\n',numel(custom));
fprintf(fid,'Final DC voltage: %.6f V\n',o.dc_voltage.Data(end));
fprintf(fid,'Final PCC active power: %.6f MW\n',o.pcc_power.Data(end)/1e6);
fprintf(fid,'Result: PASS\n');fclose(fid);
fprintf('FRESH SESSION PASS: %d Scopes; Vdc %.6f V; Pgrid %.6f MW\n', ...
 numel(sc),o.dc_voltage.Data(end),o.pcc_power.Data(end)/1e6);
close_system(mdl,0);
