% Fresh MATLAB process entry point for the final saved physical SLX.
repo=fileparts(fileparts(mfilename('fullpath')));
logfile=fullfile(repo,'results','physical','final_saved_model_run.log');
fid=fopen(logfile,'w');fclose(fid);
diary(logfile);diary on;
fprintf('FINAL PHYSICAL MODEL VALIDATION\nMATLAB %s\n',version);drawnow;
run(fullfile(repo,'validation','fresh_session_check.m'));
run(fullfile(repo,'analysis','run_physical_scenarios.m'));
run(fullfile(repo,'validation','convergence_check.m'));
run(fullfile(repo,'analysis','linearize_physical_model.m'));
fprintf('FINAL PHYSICAL MODEL VALIDATION PASS\n');drawnow;
diary off;
