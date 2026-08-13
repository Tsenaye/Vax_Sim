function tests=test_small_signal, tests=functiontests(localfunctions); end
function equilibriumAndModeTest(testCase)
root=init_project(); P=configure_case('sso_before');
S=build_small_signal_model(P); verifyLessThan(testCase,S.residual_norm,1e-7);
L=load(fullfile(root,'results','sso','sso_before.mat'));
F=analyse_frequency(L.R.t,L.R.power_e,P.analysis.band,P.sim.analysis_start);
E=analyse_eigenvalues(P,F.dominant_frequency);
verifyGreaterThan(testCase,real(E.critical_eigenvalue),0);
end
