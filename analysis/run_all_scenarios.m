%RUN_ALL_SCENARIOS Rebuild and run all authoritative study scenarios.
root=fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(root,'scripts'));
build_model();
run_case('baseline',true);
run_case('wind_step',true);
run_case('sso_before',true);
run_case('sso_after',true);
run_parameter_sweep();
generate_results_tables();
generate_figures();
