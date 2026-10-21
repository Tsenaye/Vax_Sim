function y = pmsg_outputs(t,x,vwind,P)
%PMSG_OUTPUTS Measured scalar and reconstructed three-phase quantities.
if t < P.grid.t_disturbance, scr=P.grid.scr_initial; else, scr=P.grid.scr_final; end
omega=x(1); iqm=x(2); vdc=x(4); id=x(5); iq=x(7); delta=x(10);
[Pm,Tm,Cp,lambda]=pmsg_aerodynamics(vwind,omega,P);
Xg=1/scr; Rg=Xg/P.grid.xr; E=P.grid.E;
vd=E*cos(delta)+Rg*id-Xg*iq; vq=-E*sin(delta)+Rg*iq+Xg*id;
p=vd*id+vq*iq; q=vq*id-vd*iq; vmag=hypot(vd,vq); imag=hypot(id,iq);
theta=P.base.w*t+delta;
ia=sqrt(2)*P.base.I*(id*cos(theta)-iq*sin(theta));
va=sqrt(2)*(P.base.Vll/sqrt(3))*(vd*cos(theta)-vq*sin(theta));
y=[vwind;omega;Tm;Pm;iqm;vdc;id;iq;p;q;vd;vq;vmag;delta;ia;va;imag;scr;Cp;lambda];
end
