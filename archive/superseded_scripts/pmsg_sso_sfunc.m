function pmsg_sso_sfunc(block)
%PMSG_SSO_SFUNC Continuous Level-2 S-function wrapping the documented ODE.
setup(block);
end
function setup(block)
block.NumDialogPrms=1; block.NumInputPorts=1; block.NumOutputPorts=1;
block.InputPort(1).Dimensions=1; block.InputPort(1).DirectFeedthrough=true;
block.OutputPort(1).Dimensions=20;
block.NumContStates=11; block.SampleTimes=[0 0];
block.SimStateCompliance='DefaultSimState';
block.RegBlockMethod('InitializeConditions',@init);
block.RegBlockMethod('Derivatives',@derivs);
block.RegBlockMethod('Outputs',@outputs);
end
function init(block)
P=block.DialogPrm(1).Data; block.ContStates.Data=pmsg_initial_state(P);
end
function derivs(block)
P=block.DialogPrm(1).Data;
block.Derivatives.Data=pmsg_dynamics(block.CurrentTime,block.ContStates.Data,block.InputPort(1).Data,P);
end
function outputs(block)
P=block.DialogPrm(1).Data;
block.OutputPort(1).Data=pmsg_outputs(block.CurrentTime,block.ContStates.Data,block.InputPort(1).Data,P);
end
