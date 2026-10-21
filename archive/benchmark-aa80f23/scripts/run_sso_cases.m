function [R,M]=run_sso_cases()
R=run_case('sso_before',true); M=calculate_metrics(R);
root=init_project(); save(fullfile(root,'results','sso','metrics_before.mat'),'M');
end
