function dx = pmsg_dynamics(t,x,vwind,P,scr_override)
%PMSG_DYNAMICS Nonlinear averaged dq PMSG, converters, PLL, and weak grid.
if nargin >= 5
    scr = scr_override;
elseif t < P.grid.t_disturbance
    scr = P.grid.scr_initial;
else
    scr = P.grid.scr_final;
end
omega=x(1); iqm=x(2); xi_m=x(3); vdc=x(4);
id=x(5); xi_dc=x(6); iq=x(7); xi_id=x(8); xi_iq=x(9);
delta=x(10); xi_pll=x(11);
[Pm,Tm] = pmsg_aerodynamics(vwind,omega,P);
iqm_ref = P.msc.Kp_speed*(omega-1) + xi_m;
domega = (Tm-iqm-P.pmsg.D*(omega-1))/(2*P.pmsg.H);
diqm = (iqm_ref-iqm)/P.msc.tau_current;
dxi_m = P.msc.Ki_speed*(omega-1);
Xg = 1/scr; Rg = Xg/P.grid.xr;
Lf=P.filter.X; Lt=Lf+Xg; R=P.filter.R+Rg; E=P.grid.E;
vd = E*cos(delta)+Rg*id-Xg*iq;
vq = -E*sin(delta)+Rg*iq+Xg*id;
pout = vd*id+vq*iq;
Pgen = iqm*omega;
dvdc = (Pgen-pout)/(P.dc.C_pu*max(vdc,0.25));
id_ref = Pgen + P.gsc.Kp_dc*(vdc-P.dc.v_ref)+xi_dc;
iq_ref = 0;
if P.mitigation.enable, Ki_pll=P.pll.Ki_mitigated; else, Ki_pll=P.pll.Ki_base; end
domega_pll_pu = P.pll.Kp*vq+xi_pll;
vcd = E+P.gsc.Kp_current*(id_ref-id)+xi_id-Lf*iq;
vcq = P.gsc.Kp_current*(iq_ref-iq)+xi_iq+Lf*id;
did = P.base.w/Lt*(vcd-E*cos(delta)-R*id+Lt*(1+domega_pll_pu)*iq);
diq = P.base.w/Lt*(vcq+E*sin(delta)-R*iq-Lt*(1+domega_pll_pu)*id);
dxi_dc = P.gsc.Ki_dc*(vdc-P.dc.v_ref);
dxi_id = P.gsc.Ki_current*(id_ref-id);
dxi_iq = P.gsc.Ki_current*(iq_ref-iq);
ddelta = P.base.w*domega_pll_pu;
dxi_pll = Ki_pll*vq;
dx=[domega;diqm;dxi_m;dvdc;did;dxi_dc;diq;dxi_id;dxi_iq;ddelta;dxi_pll];
end
