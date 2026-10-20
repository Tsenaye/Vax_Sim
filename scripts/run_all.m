%RUN_ALL Execute the saved authoritative model and optional analyses.
root=init_project();
assert(isfile(fullfile(root,'model','Vataleni_PMSG_SSO_Final.slx')), ...
    'The saved authoritative model is missing.');
run_case('baseline',true); run_case('wind_step',true);
run_case('sso_before',true); run_case('sso_after',true);
run_parameter_sweep(); generate_results_tables(); generate_figures();
export_model_snapshots();
run(fullfile(root,'scripts','validate_project.m'));
