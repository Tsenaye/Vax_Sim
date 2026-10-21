function F = analyse_frequency(t,y,band,t_start)
%ANALYSE_FREQUENCY Windowed FFT of an evenly resampled dq/power signal.
if nargin<3 || isempty(band), band=[1 45]; end
if nargin<4, t_start=t(1); end
keep=t>=t_start; t=t(keep); y=y(keep);
dt=median(diff(t)); tu=(t(1):dt:t(end))'; yu=interp1(t,y,tu,'linear');
yu=detrend(yu); n=numel(yu); w=hann(n,'periodic');
nfft=2^nextpow2(max(4096,4*n)); Y=fft(yu.*w,nfft);
f=(0:nfft-1)'/(nfft*dt); amp=2*abs(Y)/sum(w);
sel=f>=band(1) & f<=band(2); fb=f(sel); ab=amp(sel);
[peak_amp,k]=max(ab);
F=struct('frequency',fb,'amplitude',ab,'dominant_frequency',fb(k), ...
    'dominant_amplitude',peak_amp,'resolution',1/(nfft*dt),'sample_rate',1/dt, ...
    't_start',t_start,'signal_rms',rms(yu));
end
