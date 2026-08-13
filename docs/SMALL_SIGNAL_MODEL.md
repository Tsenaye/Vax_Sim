# Small-Signal Model

`build_small_signal_model.m` computes the central-difference Jacobian (A=\partial f/\partial x) of `pmsg_dynamics.m` at the analytically solved SCR-specific equilibrium. It is not a hand-authored matrix. The equilibrium residual is asserted below 1e-7.

For each complex eigenvalue (\lambda=\sigma+j\omega), modal frequency is (f=|\omega|/(2\pi)) and damping ratio is (\zeta=-\sigma/|\lambda|). The weak-grid benchmark mode is (0.047491+j30.414487\) s^-1, or 4.84062 Hz with damping ratio -0.001561. Controller retuning moves the observed dominant response to a stable mode near 1.892 Hz; complete eigenvalues remain in the saved metric MAT files.
