function x0 = pmsg_initial_state(P,scr)
%PMSG_INITIAL_STATE Compute a consistent pre-disturbance operating point.
if nargin < 2, scr = P.grid.scr_initial; end
[P0,~,~,~] = pmsg_aerodynamics(P.wind.v_nom,1,P);
Xg = 1/scr;
Rg = Xg/P.grid.xr;
imax = 0.999/Xg;
fun = @(id) (sqrt(max(P.grid.E^2-(Xg*id).^2,0)) + Rg*id).*id - P0;
scan = linspace(1e-6,imax,2000);
fv = arrayfun(fun,scan);
idx = find(fv(1:end-1).*fv(2:end) <= 0,1,'first');
if isempty(idx)
    error('PMSG:PowerFlow','No feasible power-flow solution at SCR %.3g.',scr);
end
id = fzero(fun,[scan(idx),scan(idx+1)]);
delta = asin(Xg*id/P.grid.E);
Rtot = P.filter.R + Rg;
x_current_d = P.grid.E*cos(delta) + Rtot*id - P.grid.E;
x_dc = id-P0;
% [speed iq_m speed_I vdc id dc_I iq id_I iq_I pll_angle pll_I]
x0 = [1; P0; P0; 1; id; x_dc; 0; x_current_d; 0; delta; 0];
end
