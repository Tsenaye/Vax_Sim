function tests=test_grid_strength, tests=functiontests(localfunctions); end
function impedanceMonotonicTest(testCase), scr=[3 5 10]; X=1./scr; verifyGreaterThan(testCase,X(1),X(2)); verifyGreaterThan(testCase,X(2),X(3)); end
