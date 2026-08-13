function [ddelta,dxi_pll,domega_pll_pu,Ki_pll] = pll_dynamics(vq,delta,xi_pll,mitigation_enable,P) %#ok<INUSL>
%PLL_DYNAMICS Synchronous-reference-frame PLL with a mitigation-switchable integral gain.
if mitigation_enable, Ki_pll = P.pll.Ki_mitigated; else, Ki_pll = P.pll.Ki_base; end
domega_pll_pu = P.pll.Kp*vq + xi_pll;
dxi_pll = Ki_pll*vq;
ddelta = P.base.w*domega_pll_pu;
end
