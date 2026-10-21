function E = analyse_eigenvalues(P,target_frequency)
%ANALYSE_EIGENVALUES Identify the converter-grid mode of the actual ODE.
if nargin<2, target_frequency=5; end
S=build_small_signal_model(P); ev=eig(S.A); freq=abs(imag(ev))/(2*pi);
zeta=-real(ev)./max(abs(ev),eps);
valid=imag(ev)>0 & freq>=1 & freq<=45;
candidates=find(valid);
[~,j]=min(abs(freq(candidates)-target_frequency)); idx=candidates(j);
E=struct('eigenvalues',ev,'frequency',freq,'damping_ratio',zeta, ...
    'critical_eigenvalue',ev(idx),'critical_frequency',freq(idx), ...
    'critical_damping_ratio',zeta(idx),'max_real_part',max(real(ev)), ...
    'small_signal',S);
end
