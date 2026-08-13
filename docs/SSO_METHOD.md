# SSO Identification Method

At 2 s, SCR changes from 10 to 5. This changes Thevenin impedance and excites the converter-grid states; it does not inject a sine wave. The 3-12 s active-power record is detrended and analysed from 1 to 45 Hz.

`analyse_frequency.m` applies a Hann window and zero-padded FFT. `analyse_prony.m` fits a linear-prediction Prony model after anti-alias-safe decimation and selects the pole nearest the FFT peak. A synthetic 7.25 Hz, -0.35 s^-1 signal validates frequency and exponential damping extraction. `analyse_eigenvalues.m` finite-differences the same nonlinear ODE at its weak-grid equilibrium.

Before mitigation, executed results are FFT 4.83704 Hz, Prony 4.83487 Hz with sigma +0.05154 s^-1, and eigenvalue 0.047491 +/- j30.414487 s^-1 (4.84062 Hz). Positive sigma/real part means negative damping. The small differences are consistent with finite FFT resolution, nonlinear transient content and Prony windowing.
