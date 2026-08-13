# Archive: Superseded Scripts

`pmsg_sso_sfunc.m` is the original monolithic Level-2 MATLAB S-Function that
implemented the eleven-state PMSG, converters, PLL and grid model in one block.

The authoritative SLX supersedes both that monolithic implementation and the
later eight-wrapper S-Function architecture. Its eight top-level engineering
subsystems now contain native Integrator blocks and embedded MATLAB Function
blocks. The archived file is retained only as a historical equation source; it
is not referenced by the model, scenario automation or validator.
