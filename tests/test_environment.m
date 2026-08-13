function tests=test_environment, tests=functiontests(localfunctions); end
function simulinkInstalledTest(testCase), verifyNotEmpty(testCase,ver('simulink')); end
function requiredProductsTest(testCase)
names={ver().Name}; verifyTrue(testCase,any(strcmp(names,'Control System Toolbox'))); verifyTrue(testCase,any(strcmp(names,'Signal Processing Toolbox')));
end
