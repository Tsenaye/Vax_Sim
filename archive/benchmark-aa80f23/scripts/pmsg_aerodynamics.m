function [Ppu,Tpu,Cp,lambda] = pmsg_aerodynamics(v,omega_pu,P)
%PMSG_AERODYNAMICS Aerodynamic power with the standard exponential Cp fit.
v = max(double(v),0.1);
omega_pu = max(double(omega_pu),0.05);
omega = omega_pu*P.wind.omega_base;
lambda = omega*P.wind.R/v;
beta = P.wind.beta;
inv_lambda_i = 1/(lambda + 0.08*beta) - 0.035/(beta^3 + 1);
lambda_i = 1/max(inv_lambda_i,1e-3);
Cp = 0.22*(116/lambda_i - 0.4*beta - 5)*exp(-12.5/lambda_i);
Cp = min(max(Cp,0),0.50);
Pwind = 0.5*P.wind.rho*P.wind.A*Cp*v^3;
Ppu = min(max(Pwind/P.base.S,0),1.15);
Tpu = Ppu/omega_pu;
end
