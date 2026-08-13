function [diqm,dxi_m,iqm_ref] = msc_control_dynamics(omega,iqm,xi_m,P)
%MSC_CONTROL_DYNAMICS Machine-side speed/current control loop.
iqm_ref = P.msc.Kp_speed*(omega-1) + xi_m;
diqm = (iqm_ref-iqm)/P.msc.tau_current;
dxi_m = P.msc.Ki_speed*(omega-1);
end
