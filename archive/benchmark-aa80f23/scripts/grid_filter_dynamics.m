function [did,diq,vd,vq,pout,scr] = grid_filter_dynamics(t,vcd,vcq,delta,domega_pll_pu,id,iq,P)
%GRID_FILTER_DYNAMICS Filter, weak-grid impedance and PCC algebraic/dynamic equations.
if t < P.grid.t_disturbance, scr = P.grid.scr_initial; else, scr = P.grid.scr_final; end
Xg = 1/scr; Rg = Xg/P.grid.xr;
Lf = P.filter.X; Lt = Lf+Xg; R = P.filter.R+Rg; E = P.grid.E;
vd = E*cos(delta)+Rg*id-Xg*iq;
vq = -E*sin(delta)+Rg*iq+Xg*id;
pout = vd*id+vq*iq;
did = P.base.w/Lt*(vcd-E*cos(delta)-R*id+Lt*(1+domega_pll_pu)*iq);
diq = P.base.w/Lt*(vcq+E*sin(delta)-R*iq-Lt*(1+domega_pll_pu)*id);
end
