function [dxi_dc,dxi_id,dxi_iq,vcd,vcq,id_ref,iq_ref] = gsc_control_dynamics(vdc,id,iq,Pgen,xi_dc,xi_id,xi_iq,P)
%GSC_CONTROL_DYNAMICS Grid-side converter DC-voltage outer loop and dq current inner loop.
E = P.grid.E; Lf = P.filter.X;
id_ref = Pgen + P.gsc.Kp_dc*(vdc-P.dc.v_ref) + xi_dc;
iq_ref = 0;
vcd = E + P.gsc.Kp_current*(id_ref-id) + xi_id - Lf*iq;
vcq = P.gsc.Kp_current*(iq_ref-iq) + xi_iq + Lf*id;
dxi_dc = P.gsc.Ki_dc*(vdc-P.dc.v_ref);
dxi_id = P.gsc.Ki_current*(id_ref-id);
dxi_iq = P.gsc.Ki_current*(iq_ref-iq);
end
