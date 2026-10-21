%RUN_ALL_SCENARIOS Run all scenarios from the saved authoritative SLX.
root=fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(root,'scripts'));
assert(isfile(fullfile(root,'model','Vataleni_PMSG_SSO_Final.slx')), ...
    'The saved authoritative model is missing.');
run_case('baseline',true);
run_case('wind_step',true);
run_case('sso_before',true);
run_case('sso_after',true);
run_parameter_sweep();
generate_results_tables();
generate_figures();
