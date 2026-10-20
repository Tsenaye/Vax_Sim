# Archive: Superseded Scripts

`pmsg_sso_sfunc.m` is the original monolithic Level-2 MATLAB S-Function that
implemented the eleven-state PMSG, converters, PLL and grid model in one block.

`build_model.m` is also archived because running it would overwrite the newer
native-block SLX with the earlier eight-MATLAB-Function version. The
authoritative saved SLX has seven native equation groups, native Integrators,
and one internal diagnostic MATLAB Function block. These archived files are
historical equation sources; neither is called by scenario automation or the
validator.
