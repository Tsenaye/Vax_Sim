function M = analyse_prony(t,y,order,band,target_frequency)
%ANALYSE_PRONY Classical linear-prediction Prony modal estimate.
if nargin<3 || isempty(order), order=20; end
if nargin<4 || isempty(band), band=[1 45]; end
if nargin<5, target_frequency=mean(band); end
t=t(:); y=detrend(y(:)); dt0=median(diff(t));
dec=max(1,round(1/(250*dt0))); t=t(1:dec:end); y=y(1:dec:end);
dt=median(diff(t)); y=y/max(std(y),eps);
N=numel(y); order=min([order,floor(N/10),60]);
H=zeros(N-order,order);
for k=1:order, H(:,k)=y(order+1-k:N-k); end
a=-lsqminnorm(H,y(order+1:N)); z=roots([1;a]); lambda=log(z)/dt;
freq=imag(lambda)/(2*pi); valid=freq>band(1) & freq<band(2) & abs(real(lambda))<100;
lambda=lambda(valid); freq=freq(valid);
if isempty(lambda), error('PMSG:PronyFailure','No Prony poles in analysis band.'); end
[~,idx]=min(abs(freq-target_frequency)+0.01*abs(real(lambda)));
pole=lambda(idx); fit=fit_mode(t,y,pole);
M=struct('pole',pole,'frequency',imag(pole)/(2*pi),'sigma',real(pole), ...
    'damping_ratio',-real(pole)/abs(pole),'fit_nrmse',fit.nrmse, ...
    'fit_signal',fit.yhat,'fit_time',t,'order',order,'decimation',dec);
end
function out=fit_mode(t,y,pole)
E=[exp(pole*(t-t(1))),exp(conj(pole)*(t-t(1))),ones(size(t)),t-t(1)];
c=lsqminnorm(E,y); yh=real(E*c); out.yhat=yh;
out.nrmse=1-norm(y-yh)/max(norm(y-mean(y)),eps);
end
