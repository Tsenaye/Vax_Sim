function [domega,Pm,Tm,Cp,lambda] = turbine_pmsg_dynamics(vwind,omega,iqm,P)
%TURBINE_PMSG_DYNAMICS Rotor/aerodynamic state equation for the wind turbine + PMSG.
[Pm,Tm,Cp,lambda] = pmsg_aerodynamics(vwind,omega,P);
domega = (Tm-iqm-P.pmsg.D*(omega-1))/(2*P.pmsg.H);
end
