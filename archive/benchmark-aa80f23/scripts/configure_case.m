function P = configure_case(case_name)
%CONFIGURE_CASE Return a complete, reproducible scenario definition.
if nargin<1, case_name='baseline'; end
P=init_parameters(); P.sim.case_name=char(case_name);
switch lower(char(case_name))
    case 'baseline'
        P.grid.scr_initial=10; P.grid.scr_final=10;
    case 'wind_step'
        P.grid.scr_initial=10; P.grid.scr_final=10; P.wind.v_step=10.5;
    case {'weak_grid','sso_before'}
        P.grid.scr_initial=10; P.grid.scr_final=5; P.mitigation.enable=false;
    case 'sso_after'
        P.grid.scr_initial=10; P.grid.scr_final=5; P.mitigation.enable=true;
    otherwise
        error('PMSG:UnknownCase','Unknown case: %s',case_name);
end
end
