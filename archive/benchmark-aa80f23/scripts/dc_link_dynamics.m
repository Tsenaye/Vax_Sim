function dvdc = dc_link_dynamics(Te,omega,pout,vdc,P)
%DC_LINK_DYNAMICS DC-link capacitor power balance.
dvdc = (Te*omega-pout)/(P.dc.C_pu*max(vdc,0.25));
end
