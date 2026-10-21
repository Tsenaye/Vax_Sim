%VALIDATE_PROJECT Compatibility entry point for the authoritative validator.
root=fileparts(fileparts(mfilename('fullpath')));
run(fullfile(root,'validation','validate_project.m'));
