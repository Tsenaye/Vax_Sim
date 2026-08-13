# Model Equations

Wind power, tip-speed ratio and torque are

\[
P_w=\tfrac12\rho A C_p(\lambda,\beta)v_w^3,\quad
\lambda=\omega_tR/v_w,\quad T_m=P_w/\omega_r.
\]

The empirical coefficient is

\[
C_p=0.22(116/\lambda_i-0.4\beta-5)e^{-12.5/\lambda_i},\quad
\lambda_i^{-1}=(\lambda+0.08\beta)^{-1}-0.035/(\beta^3+1).
\]

The surface-PMSG electromagnetic relationship is represented in per unit by (T_e=\psi_{pm}i_{qm}=i_{qm}), consistent with (L_d=L_q). Rotor and averaged MSC dynamics are

\[
2H\dot\omega_r=T_m-T_e-D(\omega_r-1),\quad
\tau_m\dot i_{qm}=i_{qm}^*-i_{qm}.
\]

The DC-link energy balance is

\[
C_{dc,pu}V_{dc}\dot V_{dc}=P_m\omega_r-P_{pcc}.
\]

For SCR-controlled grid impedance (X_g=1/SCR, R_g=X_g/(X/R)), the quasi-steady PCC voltage in the PLL frame is

\[
v_d=E\cos\delta+R_gi_d-X_gi_q,\qquad
v_q=-E\sin\delta+R_gi_q+X_gi_d.
\]

The total filter/grid current dynamics are

\[
\dot i_d={\omega_b\over X_f+X_g}[v_{cd}-E\cos\delta-(R_f+R_g)i_d+(X_f+X_g)\omega_{pll}i_q],
\]

\[
\dot i_q={\omega_b\over X_f+X_g}[v_{cq}+E\sin\delta-(R_f+R_g)i_q-(X_f+X_g)\omega_{pll}i_d].
\]

PI controller and PLL equations are implemented explicitly in `pmsg_dynamics.m`. Three-phase voltage/current are inverse-dq reconstructions for waveform reporting; SSO analysis uses power and dq signals to avoid confusing the 50 Hz carrier with the control mode.
