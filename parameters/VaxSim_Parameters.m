function P = VaxSim_Parameters()
%VAXSIM_PARAMETERS Optional editable parameter reference and scenario presets.
% The SLX contains its own defaults and does not call this file. To change a
% value in a standalone model, edit the matching block or Model Workspace
% variable inside Simulink and save the SLX.

P.base.S = 5e6;                 % VA; Wang et al. 2019 turbine rating
P.base.Vll = 690;               % V rms; engineering assumption
P.base.f = 50;                  % Hz
P.wind.rho = 1.225;             % kg/m^3; engineering assumption
P.wind.R = 55;                  % m; engineering assumption
P.wind.v_nom = 12;              % m/s
P.wind.beta = 0;                % deg
P.pmsg.H = 4;                   % s; engineering assumption
P.pmsg.D = 0.02;                % pu; engineering assumption
P.msc.Kp_speed = 2;
P.msc.Ki_speed = 1;
P.msc.tau_current = 0.02;       % s; reduced order closed current loop
P.dc.C_pu = 0.08;               % s; energy-normalized capacitance
P.dc.v_ref = 1;
P.gsc.Kp_current = 0.30;
P.gsc.Ki_current = 20;
P.gsc.Kp_dc = 0.80;
P.gsc.Ki_dc = 20;
P.filter.R = 0.01;              % pu
P.filter.X = 0.15;              % pu
P.grid.E = 1;                   % pu
P.grid.xr = 10;
P.grid.scr_baseline = 10;
P.grid.scr_weak = 5;
P.pll.Kp = 0.01;
P.pll.Ki_unmitigated = 2.80;
P.pll.Ki_mitigated = 0.50;
P.sim.dt = 2e-4;                % s
P.sim.stop = 12;                % s
P.scenarios.baseline = struct('scr_initial',10,'scr_final',10,'mitigation_enable',0);
P.scenarios.sso = struct('scr_initial',10,'scr_final',5,'mitigation_enable',0);
P.scenarios.mitigation = struct('scr_initial',10,'scr_final',5,'mitigation_enable',1);
end
