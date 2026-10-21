function S = build_small_signal_model(P)
%BUILD_SMALL_SIGNAL_MODEL Numerical Jacobian of the exact nonlinear ODE.
x0=pmsg_initial_state(P,P.grid.scr_final); n=numel(x0); A=zeros(n);
f0=pmsg_dynamics(P.grid.t_disturbance+1,x0,P.wind.v_nom,P,P.grid.scr_final);
for k=1:n
    h=1e-6*max(1,abs(x0(k))); xp=x0; xm=x0; xp(k)=xp(k)+h; xm(k)=xm(k)-h;
    fp=pmsg_dynamics(P.grid.t_disturbance+1,xp,P.wind.v_nom,P,P.grid.scr_final);
    fm=pmsg_dynamics(P.grid.t_disturbance+1,xm,P.wind.v_nom,P,P.grid.scr_final);
    A(:,k)=(fp-fm)/(2*h);
end
S=struct('A',A,'x_equilibrium',x0,'residual_norm',norm(f0), ...
    'state_names',{{'omega_r','iq_m','xi_speed','vdc','id','xi_dc','iq','xi_id','xi_iq','delta_pll','xi_pll'}}, ...
    'scr',P.grid.scr_final,'mitigation',P.mitigation.enable);
end
