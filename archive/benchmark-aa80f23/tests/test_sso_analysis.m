function tests=test_sso_analysis, tests=functiontests(localfunctions); end
function fftResolutionTest(testCase),root=init_project();L=load(fullfile(root,'results','sso','sso_before.mat'));F=analyse_frequency(L.R.t,L.R.power_e,[1 45],3);verifyLessThan(testCase,F.resolution,.05);end
