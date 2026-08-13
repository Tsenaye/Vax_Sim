function tests=test_end_to_end, tests=functiontests(localfunctions); end
function artifactsTest(testCase),root=init_project();verifyTrue(testCase,isfile(fullfile(root,'model','Vataleni_PMSG_SSO_Final.slx')));verifyGreaterThanOrEqual(testCase,numel(dir(fullfile(root,'figures','*.png'))),14);verifyTrue(testCase,isfile(fullfile(root,'results','summary_cases.csv')));end
