function tests=test_baseline, tests=functiontests(localfunctions); end
function stableTest(testCase), root=init_project(); L=load(fullfile(root,'results','baseline','baseline.mat')); verifyTrue(testCase,all(isfinite(L.R.power_e))); verifyLessThan(testCase,max(abs(L.R.vdc-1)),0.02); end
