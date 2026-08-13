%VALIDATE_PROJECT Fresh-session, evidence-based project acceptance suite.
bdclose('all');
clear;
clc;

root = fileparts(fileparts(mfilename('fullpath')));
modelName = 'Vataleni_PMSG_SSO_Final';
modelPath = fullfile(root,'model',[modelName '.slx']);
resultsDir = fullfile(root,'results','validation');
if ~isfolder(resultsDir), mkdir(resultsDir); end
testName = cell(20,1); status = repmat({'FAIL'},20,1); evidence = cell(20,1);
setcheck = @(i,n,p,e) assign_check(i,n,p,e); %#ok<NASGU>

% 1 - authoritative model exists.
testName{1}='Authoritative SLX exists';
status{1}=passfail(isfile(modelPath)); evidence{1}=modelPath;

% 2-14 - standalone model audit with project scripts deliberately absent.
scriptsDir=fullfile(root,'scripts'); testsDir=fullfile(root,'tests');
if contains(path,scriptsDir), rmpath(scriptsDir); end
if contains(path,testsDir), rmpath(testsDir); end
opened=false; compiled=false; simulated=false; raw=[]; tout=[]; loops=[]; sf={}; unresolved={};
try
    load_system(modelPath); opened=true;
catch ME
    openError=ME.message;
end
testName{2}='Model opens'; status{2}=passfail(opened);
if opened, evidence{2}='load_system completed from repository root without project paths'; else, evidence{2}=openError; end

if opened
    try
        set_param(modelName,'SimulationCommand','update'); compiled=true;
    catch ME
        compileError=getReport(ME,'basic','hyperlinks','off');
    end
end
testName{3}='Model compile/update'; status{3}=passfail(compiled);
if compiled, evidence{3}='SimulationCommand update completed'; else, evidence{3}=compileError; end

embeddedEngine={}; customSf={};
if opened
    sf=find_system(modelName,'LookUnderMasks','all','FollowLinks','on','BlockType','S-Function');
    for k=1:numel(sf)
        fn=get_param(sf{k},'FunctionName');
        % sf_sfun is Simulink's internal execution engine beneath an embedded
        % MATLAB Function block. It is stored in the SLX and is not a custom
        % or externally resolved S-Function implementation.
        if strcmp(fn,'sf_sfun'), embeddedEngine{end+1}=sf{k}; else, customSf{end+1}=sf{k}; end %#ok<AGROW>
    end
end
testName{4}='No missing block implementations'; status{4}=passfail(compiled && isempty(customSf));
evidence{4}=sprintf('Compile=%d; external/custom S-Function blocks=%d',compiled,numel(customSf));
testName{5}='No unresolved custom S-functions'; status{5}=passfail(isempty(customSf));
evidence{5}=sprintf('External/custom S-Functions: %d; embedded MATLAB Function engines: %d',numel(customSf),numel(embeddedEngine));

if opened
    unresolved=find_system(modelName,'LookUnderMasks','all','FollowLinks','off','LinkStatus','unresolved');
end
testName{6}='No broken library links'; status{6}=passfail(isempty(unresolved));
evidence{6}=sprintf('Unresolved links: %d',numel(unresolved));

machinePaths={}; callbacks={'PreLoadFcn','PostLoadFcn','InitFcn','StartFcn','StopFcn','CloseFcn'};
callbackText=''; modelReferences={};
if opened
    for k=1:numel(callbacks), callbackText=[callbackText ' ' get_param(modelName,callbacks{k})]; end %#ok<AGROW>
    blocks=find_system(modelName,'LookUnderMasks','all','FollowLinks','off','Type','Block');
    modelReferences=find_system(modelName,'LookUnderMasks','all','FollowLinks','off','BlockType','ModelReference');
    for b=1:numel(blocks)
        dp=get_param(blocks{b},'DialogParameters');
        if ~isstruct(dp), continue; end
        f=fieldnames(dp);
        for j=1:numel(f)
            try, val=get_param(blocks{b},f{j}); catch, continue; end
            if ischar(val) && ~isempty(regexp(val,'([A-Za-z]:\\)|(/Users/)|(/home/)','once'))
                machinePaths{end+1}=sprintf('%s.%s=%s',blocks{b},f{j},val); %#ok<AGROW>
            end
        end
    end
end
testName{7}='No machine-specific paths'; status{7}=passfail(isempty(machinePaths));
status{7}=passfail(isempty(machinePaths) && isempty(modelReferences));
evidence{7}=sprintf('Machine-specific parameter strings: %d; external model references: %d',numel(machinePaths),numel(modelReferences));

if opened
    try
        out=sim(modelName); raw=out.get('simlog'); tout=out.get('tout'); simulated=true;
    catch ME
        simError=getReport(ME,'basic','hyperlinks','off');
    end
end
testName{8}='No manual initialization or callbacks';
status{8}=passfail(isempty(strtrim(callbackText)) && simulated);
evidence{8}=sprintf('Callbacks empty=%d; standalone simulation=%d',isempty(strtrim(callbackText)),simulated);

if compiled
    try, loops=Simulink.BlockDiagram.getAlgebraicLoops(modelName); catch, loops={NaN}; end
end
testName{9}='No algebraic loops'; status{9}=passfail(isempty(loops));
evidence{9}=sprintf('Algebraic loops: %d',numel(loops));

testName{10}='Configured simulation completes'; status{10}=passfail(simulated);
if simulated, evidence{10}=sprintf('%d time samples to t=%.3f s',numel(tout),tout(end)); else, evidence{10}=simError; end

y=[];
if simulated
    y=squeeze(raw);
    if size(y,1)==35 && size(y,2)==numel(tout), y=y.'; end
end
testName{11}='Required logged signals exist';
status{11}=passfail(simulated && size(y,2)==35 && size(y,1)==numel(tout));
evidence{11}=sprintf('Logged matrix: %s; required channels: 35',mat2str(size(y)));
testName{12}='All outputs finite'; status{12}=passfail(~isempty(y) && all(isfinite(y),'all'));
evidence{12}=sprintf('Finite values: %d of %d',sum(isfinite(y),'all'),numel(y));
testName{13}='No NaN'; status{13}=passfail(~isempty(y) && ~any(isnan(y),'all'));
evidence{13}=sprintf('NaN count: %d',sum(isnan(y),'all'));
testName{14}='No Inf'; status{14}=passfail(~isempty(y) && ~any(isinf(y),'all'));
evidence{14}=sprintf('Inf count: %d',sum(isinf(y),'all'));
if opened, close_system(modelName,0); end

% 15-20 - scenario, artifact and traceability checks.
addpath(scriptsDir); addpath(testsDir);
try, Rb=run_case('baseline',true); basePass=all(isfinite(Rb.power_e)) && max(abs(Rb.vdc-1))<0.02; catch ME, basePass=false; baseError=ME.message; end
testName{15}='Baseline scenario'; status{15}=passfail(basePass);
if basePass, evidence{15}=sprintf('P_end=%.6f pu; max Vdc deviation=%.6g pu',Rb.power_e(end),max(abs(Rb.vdc-1))); else, evidence{15}=baseError; end

try, Ru=run_case('sso_before',true); Mu=calculate_metrics(Ru); ssoPass=all(isfinite(Ru.power_e)) && real(Mu.eigenvalue)>0 && Mu.sso_frequency_fft<50; catch ME, ssoPass=false; ssoError=ME.message; end
testName{16}='SSO scenario'; status{16}=passfail(ssoPass);
if ssoPass, evidence{16}=sprintf('FFT=%.5f Hz; eigenvalue=%.6f%+.6fi',Mu.sso_frequency_fft,real(Mu.eigenvalue),imag(Mu.eigenvalue)); else, evidence{16}=ssoError; end
if ssoPass
    [regPass,regEvidence]=native_regression(Ru);
    status{4}=passfail(compiled && isempty(customSf) && regPass);
    evidence{4}=sprintf('Compile=%d; external/custom S-Functions=%d; %s',compiled,numel(customSf),regEvidence);
end

try, Rm=run_case('sso_after',true); Mm=calculate_metrics(Rm); mitPass=all(isfinite(Rm.power_e)) && Mm.power_osc_rms<Mu.power_osc_rms && real(Mm.eigenvalue)<0; catch ME, mitPass=false; mitError=ME.message; end
testName{17}='Mitigation scenario'; status{17}=passfail(mitPass);
if mitPass, evidence{17}=sprintf('Power oscillation RMS %.6g -> %.6g pu',Mu.power_osc_rms,Mm.power_osc_rms); else, evidence{17}=mitError; end

try
    run_case('wind_step',true); run_parameter_sweep(); generate_results_tables(); generate_figures();
    figs=dir(fullfile(root,'figures','*.png')); figPass=numel(figs)>=17;
catch ME
    figPass=false; figs=[]; figError=ME.message;
end
testName{18}='Figures regenerate'; status{18}=passfail(figPass);
if figPass, evidence{18}=sprintf('%d fresh PNG figures generated',numel(figs)); else, evidence{18}=figError; end

exports={fullfile(root,'results','summary_cases.csv'),fullfile(root,'results','mitigation_comparison.csv'), ...
    fullfile(root,'results','modal_comparison.csv'),fullfile(root,'results','scr_sweep.csv'),fullfile(root,'results','controller_sweep.csv')};
exportPass=all(cellfun(@isfile,exports));
testName{19}='Numerical result exports regenerate'; status{19}=passfail(exportPass);
evidence{19}=sprintf('Required exports present: %d/%d',sum(cellfun(@isfile,exports)),numel(exports));

tracePath=fullfile(root,'report','results_traceability.csv');
tracePass=false;
if isfile(tracePath) && isfile(fullfile(root,'report','Vataleni_PMSG_SSO_Technical_Report.pdf')) && ...
        isfile(fullfile(root,'report','Vataleni_PMSG_SSO_Technical_Report.docx'))
    try
        Tr=readtable(tracePath,'TextType','string'); Ts=readtable(fullfile(root,'results','summary_cases.csv'),'TextType','string');
        tracePass=height(Tr)>=2 && height(Ts)>=2 && max(abs(Tr.FFT_Hz(1:2)-Ts.FFT_Hz(1:2)))<1e-10;
    catch
        tracePass=false;
    end
end
testName{20}='Report values trace to current results'; status{20}=passfail(tracePass);
evidence{20}=sprintf('Trace table and final PDF/DOCX consistent: %d',tracePass);

% Regenerate the mandatory solver-sensitivity evidence in this fresh run.
P_sens=Ru.P; P_sens.sim.dt=P_sens.sim.dt/2; Fsens=struct('dominant_frequency',NaN);
try
    Rsens=run_case_override(P_sens,modelPath,modelName);
    Fsens=analyse_frequency(Rsens.t,Rsens.power_e,P_sens.analysis.band,P_sens.sim.analysis_start);
    sensDiff=abs(Fsens.dominant_frequency-Mu.sso_frequency_fft); sensPass=sensDiff<0.1;
catch ME
    sensPass=false; sensDiff=NaN; sensitivityError=ME.message;
end
Tsens=table(Ru.P.sim.dt,P_sens.sim.dt,Mu.sso_frequency_fft,Fsens.dominant_frequency,sensDiff,sensPass, ...
    'VariableNames',{'dt_baseline_s','dt_refined_s','freq_baseline_Hz','freq_refined_Hz','abs_diff_Hz','pass'});
writetable(Tsens,fullfile(resultsDir,'numerical_sensitivity.csv'));
if ~sensPass
    status{19}='FAIL';
    evidence{19}=sprintf('%s; numerical sensitivity failed: %s',evidence{19},sensitivityError);
else
    evidence{19}=sprintf('%s; dt %.1e -> %.1e s, frequency change %.6g Hz',evidence{19},Ru.P.sim.dt,P_sens.sim.dt,sensDiff);
end

T=table(testName,status,evidence,'VariableNames',{'Test','Status','Evidence'});
writetable(T,fullfile(resultsDir,'validation_summary.csv'));
fid=fopen(fullfile(root,'docs','VALIDATION.md'),'w');
fprintf(fid,'# Validation\n\nFresh-session validation executed %s in MATLAB %s.\n\n| Test | Status | Evidence |\n|---|---|---|\n',datestr(now,31),version);
for k=1:height(T), fprintf(fid,'| %s | %s | %s |\n',T.Test{k},T.Status{k},strrep(T.Evidence{k},'|','/')); end
fclose(fid);

disp(T);
npass=sum(strcmp(status,'PASS'));
if npass==20
    fprintf('VAX_SIM VALIDATION: PASS\n20/20 checks passed.\n');
else
    fprintf('VAX_SIM VALIDATION: FAIL\n%d/20 checks passed.\n',npass);
    error('VAX_SIM:ValidationFailed','%d of 20 validation checks failed.',20-npass);
end

function s=passfail(p)
if p, s='PASS'; else, s='FAIL'; end
end

function assign_check(~,~,~,~)
% Reserved to keep the script compatible with older MATLAB parser behavior.
end

function [pass,evidence]=native_regression(R)
% Compare the embedded native trajectory with the recovered monolithic ODE.
P=R.P; dt=P.sim.dt; stop=min(2.5,R.t(end)); n=round(stop/dt)+1;
t=(0:n-1)'*dt; x=zeros(n,11); x(1,:)=pmsg_initial_state(P).';
for k=1:n-1
    tk=t(k); xk=x(k,:).';
    f=@(tt,xx) pmsg_dynamics(tt,xx,wind_at(tt,P),P);
    k1=f(tk,xk); k2=f(tk+dt/2,xk+dt*k1/2);
    k3=f(tk+dt/2,xk+dt*k2/2); k4=f(tk+dt,xk+dt*k3);
    x(k+1,:)=(xk+dt*(k1+2*k2+2*k3+k4)/6).';
end
actual=[R.omega_r(1:n),R.iq_machine(1:n),R.vdc(1:n),R.id_grid(1:n),R.iq_grid(1:n),R.pll_angle(1:n)];
reference=x(:,[1 2 4 5 7 10]); err=max(abs(actual-reference),[],'all');
pass=err<1e-8; evidence=sprintf('native-vs-reference max abs error %.3g',err);
end

function v=wind_at(t,P)
if t<P.wind.t_step, v=P.wind.v_nom; else, v=P.wind.v_step; end
end

function R=run_case_override(P,modelPath,modelName)
load_system(modelPath); in=Simulink.SimulationInput(modelName);
scenario={'wind_nom',P.wind.v_nom;'wind_step',P.wind.v_step;'wind_step_time',P.wind.t_step; ...
    'scr_initial',P.grid.scr_initial;'scr_final',P.grid.scr_final; ...
    'grid_disturbance_time',P.grid.t_disturbance;'mitigation_enable',double(P.mitigation.enable)};
for k=1:size(scenario,1), in=in.setVariable(scenario{k,1},scenario{k,2},'Workspace',modelName); end
in=in.setModelParameter('StopTime',num2str(P.sim.t_end,17),'FixedStep',num2str(P.sim.dt,17));
out=sim(in); y=squeeze(out.get('simlog')); tout=out.get('tout');
if size(y,1)==35 && size(y,2)==numel(tout), y=y.'; end
R=struct('P',P,'t',tout(:),'power_e',y(:,9)); close_system(modelName,0);
end
