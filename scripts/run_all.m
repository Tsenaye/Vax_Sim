%RUN_ALL Clean end-to-end project execution.
root=init_project(); build_model();
run_case('baseline',true); run_case('wind_step',true);
run_case('sso_before',true); run_case('sso_after',true);
run_parameter_sweep(); generate_results_tables(); generate_figures();
export_model_snapshots();
run(fullfile(root,'scripts','validate_project.m'));
