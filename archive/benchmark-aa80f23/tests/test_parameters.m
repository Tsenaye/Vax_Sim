function tests=test_parameters, tests=functiontests(localfunctions); end
function basesTest(testCase), P=init_parameters(); verifyEqual(testCase,P.base.I,P.base.S/(sqrt(3)*P.base.Vll),'RelTol',1e-12); verifyGreaterThan(testCase,P.wind.A,0); end
function aeroTest(testCase), P=init_parameters(); [p,t,cp,l]=pmsg_aerodynamics(12,1,P); verifyGreaterThan(testCase,p,0); verifyLessThanOrEqual(testCase,cp,0.5); verifyEqual(testCase,p,t,'RelTol',1e-12); verifyGreaterThan(testCase,l,0); end
