function [R,M]=run_mitigation_cases()
R=run_case('sso_after',true); M=calculate_metrics(R);
root=init_project(); save(fullfile(root,'results','mitigation','metrics_after.mat'),'M');
end
