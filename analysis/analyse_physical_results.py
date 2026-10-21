"""Recompute tables and figures from CSVs written by the saved physical SLX."""
from __future__ import annotations
import csv
from pathlib import Path
import numpy as np
from scipy.signal import butter, detrend, periodogram, sosfiltfilt
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

ROOT=Path(__file__).resolve().parents[1]
DATA=ROOT/'results'/'physical'
FIG=ROOT/'figures'/'physical'
FIG.mkdir(parents=True,exist_ok=True)
CASES=['baseline','wind_variation','weak_grid','weak_grid_mitigated']

def read(name):
    with (DATA/(name+'.csv')).open(newline='') as f:
        rows=list(csv.DictReader(f))
    return {k:np.array([float(r[k]) for r in rows]) for k in rows[0]}

def write(name,headers,rows):
    with (DATA/name).open('w',newline='') as f:
        w=csv.writer(f);w.writerow(headers);w.writerows(rows)

def mode(a):
    t=a['time_s'];y=a['pcc_vq'];fs=1/np.median(np.diff(t))
    ix=(t>=2.05)&(t<=4.5)
    f,p=periodogram(detrend(y[ix]),fs=fs,nfft=16384)
    band=(f>=1)&(f<=45)
    peak=f[band][np.argmax(p[band])]
    z=sosfiltfilt(butter(3,[3,8],btype='bandpass',fs=fs,output='sos'),y)
    ix=(t>=2.15)&(t<=3.5);u=z[ix]
    coeff=np.linalg.lstsq(np.stack([u[1:-1],u[:-2]],axis=1),u[2:],rcond=None)[0]
    roots=np.roots([1,-coeff[0],-coeff[1]])
    pole=np.log(roots[np.argmax(np.imag(roots))])*fs
    return peak,pole

A={name:read(name) for name in CASES}
metrics=[];modes=[]
for name,a in A.items():
    t=a['time_s'];early=(t>=2.25)&(t<3.25);late=t>=5.5
    freq,pole=mode(a)
    metrics.append([name,int(round(a['wind_speed'][-1])),5 if 'weak' in name else 10,
                    int(round(a['mitigation_enable'][-1])),
                    np.mean(a['dc_voltage'][late]),np.mean(a['pcc_power'][late])/1e6,
                    np.std(a['pcc_vq'][early]),np.std(a['pcc_vq'][late]),
                    np.mean(a['shaft_speed'][late]),
                    np.mean(a['machine_pgen'][late])/1e6,
                    np.mean(a['machine_copper_loss'][late])/1000,
                    np.mean(a['grid_id'][late]),np.mean(a['machine_iq'][late])])
    modes.append([name,freq,pole.real,pole.imag,
                  abs(pole.imag)/(2*np.pi),-pole.real/abs(pole)])
write('scenario_metrics.csv',['case','final_wind_mps','nominal_external_scr','mitigation',
    'late_dc_voltage_V','late_pcc_active_MW','early_pcc_q_std_V','late_pcc_q_std_V',
    'late_shaft_speed_rad_s','late_generator_electrical_MW','late_stator_copper_kW',
    'late_grid_d_A','late_machine_q_A'],metrics)
write('modal_estimates.csv',['case','fft_peak_Hz','prony_real_per_s',
    'prony_imag_rad_s','prony_frequency_Hz','prony_damping_ratio'],modes)

b=A['baseline'];t=b['time_s'];steady=(t>=4)&(t<=6);dt=np.median(np.diff(t))
we=23*b['shaft_speed'];Ld=Lq=7.53e-4;Rs=9.522e-4;psi=17.8
did=np.gradient(b['machine_id'],dt);diq=np.gradient(b['machine_iq'],dt)
rd=Ld*did-b['machine_vd_actual']+Rs*b['machine_id']-we*Lq*b['machine_iq']
rq=Lq*diq-b['machine_vq_actual']+Rs*b['machine_iq']+we*(Ld*b['machine_id']+psi)
rms=lambda z:np.sqrt(np.mean(z*z))
torque=-1.5*23*psi*b['machine_iq']
mechanical=b['generator_torque']*b['shaft_speed']
pgen=b['machine_pgen'];pcu=b['machine_copper_loss']
lam=b['shaft_speed']*55/b['wind_speed']
lam_table=np.arange(.1,15.1+.01,.5)
inv_li=1/np.maximum(lam_table,.05)-.035
li=1/np.maximum(inv_li,1e-3)
cp_table=np.clip(.22*(116/li-5)*np.exp(-12.5/li),0,.5)
cp_table[0]=.001
cp=np.interp(lam,lam_table,cp_table)
turbine_torque=.5*1.225*np.pi*55**2*b['wind_speed']**3*cp/b['shaft_speed']
mechanical_residual=turbine_torque-b['generator_torque']-2.118e7*np.gradient(b['shaft_speed'],dt)
edot=np.gradient(b['dc_energy'],dt)
msc_loss=pgen-b['dc_voltage']*b['msc_dc_current']
gsc_loss=-b['dc_voltage']*b['gsc_dc_current']-b['pcc_power']
expected_gsc_loss=5000+1.5*9.522e-4*(b['grid_id']**2+b['grid_iq']**2)
vphase=np.hypot(b['machine_vd_actual'],b['machine_vq_actual'])
iline=np.hypot(b['machine_id'],b['machine_iq'])/np.sqrt(2)

checks=[]
def check(label,value,limit,unit,kind='max'):
    passed=value<=limit if kind=='max' else value>=limit
    checks.append([label,'PASS' if passed else 'FAIL',value,limit,unit])
check('PMSG d equation RMS residual',rms(rd[steady]),1e-2,'V')
check('PMSG q equation RMS residual',rms(rq[steady]),1e-2,'V')
check('Electrical speed identity RMS',rms(we[steady]-23*b['shaft_speed'][steady]),1e-10,'rad/s')
check('Electromagnetic torque maximum error',np.max(abs(torque[steady]-b['generator_torque'][steady])),1e-4,'N m')
check('Independent turbine shaft torque balance RMS',rms(mechanical_residual[steady]),200,'N m')
check('Mechanical electrical copper balance RMS',rms((mechanical-pgen-pcu)[steady]),100,'W')
check('DC capacitor energy balance RMS',rms((edot-b['dc_power_net'])[steady]),100,'W')
check('MSC fixed loss RMS error',rms((msc_loss-5000)[steady]),100,'W')
check('GSC plus filter loss RMS error',rms((gsc_loss-expected_gsc_loss)[steady]),100,'W')
check('Baseline DC late absolute error',abs(np.mean(b['dc_voltage'][t>=5.5])-1400),10,'V')
check('Baseline PLL late frequency error',abs(np.mean(b['pll_omega'][t>=5.5])-2*np.pi*50),0.1,'rad/s')
check('Baseline PCC q late RMS',rms(b['pcc_vq'][t>=5.5]),0.1,'V')
check('Machine RMS current under 5 kA',np.max(iline[steady]),5000,'A')
check('Machine line RMS voltage near 690 V',abs(np.mean(vphase[steady])*np.sqrt(3/2)-690),100,'V')
check('Machine q reference within 6.5 kA',max(np.max(abs(a['machine_iqref'])) for a in A.values()),6500.001,'A')
check('Grid d reference within 6.5 kA',max(np.max(abs(a['grid_idref'])) for a in A.values()),6500.001,'A')
check('Weak grid oscillation amplification',metrics[2][6]/metrics[1][6],1.5,'ratio','min')
check('Mitigation early q RMS reduction',metrics[2][6]/metrics[3][6],2,'ratio','min')
check('Mitigation late q RMS reduction',metrics[2][7]/metrics[3][7],2,'ratio','min')
check('All case signals finite',float(all(np.isfinite(v).all() for a in A.values() for v in a.values())),1,'boolean','min')
check('Baseline generator electrical output',np.mean(pgen[steady])/1e6,3,'MW','min')
check('Weak grid DC remains positive',np.min(A['weak_grid']['dc_voltage']),500,'V','min')
check('Mitigated DC remains positive',np.min(A['weak_grid_mitigated']['dc_voltage']),500,'V','min')
half=DATA/'weak_grid_half_step.csv'
if half.exists():
    h=read('weak_grid_half_step');w=A['weak_grid'];late=w['time_s']>=5.5
    check('Solver step DC late mean difference',abs(np.mean(h['dc_voltage'][late])-np.mean(w['dc_voltage'][late])),1,'V')
    check('Solver step PCC power late mean difference',abs(np.mean(h['pcc_power'][late])-np.mean(w['pcc_power'][late])),10000,'W')
write('engineering_checks.csv',['check','status','observed','threshold','unit'],checks)

plt.rcParams.update({'font.size':10,'axes.grid':True,'grid.alpha':0.25})
def save(name):
    plt.tight_layout();plt.savefig(FIG/name,dpi=180);plt.close()

fig,ax=plt.subplots(2,1,figsize=(9,6),sharex=True)
for name,color in [('wind_variation','#2b6cb0'),('weak_grid','#c05621'),('weak_grid_mitigated','#2f855a')]:
    a=A[name];ix=(a['time_s']>=1.8)&(a['time_s']<=4.5)
    ax[0].plot(a['time_s'][ix],a['pcc_vq'][ix],label=name.replace('_',' '),color=color,lw=1.1)
    ax[1].plot(a['time_s'][ix],a['dc_voltage'][ix],color=color,lw=1.1)
ax[0].set_ylabel('PCC q voltage [V]');ax[0].legend(loc='upper right')
ax[1].set_ylabel('DC voltage [V]');ax[1].set_xlabel('Time [s]')
save('01_pcc_and_dc_response.png')

fig,ax=plt.subplots(figsize=(8,4.3))
for name,color in [('wind_variation','#2b6cb0'),('weak_grid','#c05621'),('weak_grid_mitigated','#2f855a')]:
    a=A[name];ix=(a['time_s']>=2.05)&(a['time_s']<=4.5)
    f,p=periodogram(detrend(a['pcc_vq'][ix]),fs=100,nfft=16384)
    band=(f>=1)&(f<=15);ax.plot(f[band],10*np.log10(p[band]+1e-16),label=name.replace('_',' '),color=color)
ax.set_xlabel('Frequency [Hz]');ax.set_ylabel('PCC q periodogram [dB V²/Hz]');ax.legend()
save('02_pcc_frequency.png')

fig,ax=plt.subplots(2,1,figsize=(9,6),sharex=True)
for name,color in [('baseline','#2b6cb0'),('weak_grid','#c05621')]:
    a=A[name];ax[0].plot(a['time_s'],a['machine_pgen']/1e6,label=name.replace('_',' '),color=color)
    ax[1].plot(a['time_s'],a['machine_iq']/1000,label=name.replace('_',' '),color=color)
ax[0].set_ylabel('Generator electrical power [MW]');ax[0].legend()
ax[1].set_ylabel('Machine q current [kA]');ax[1].set_xlabel('Time [s]')
save('03_machine_electrical_dynamics.png')

fig,ax=plt.subplots(figsize=(9,4))
ax.plot(t[steady],(mechanical-pgen)[steady]/1000,label='Mechanical minus electrical power')
ax.plot(t[steady],pcu[steady]/1000,label='Stator copper loss')
ax.set_xlabel('Time [s]');ax.set_ylabel('Power [kW]');ax.legend()
save('04_power_balance.png')

linfile=DATA/'linearized_modes.csv'
if linfile.exists():
    with linfile.open(newline='') as f:
        poles=list(csv.DictReader(f))
    fig,ax=plt.subplots(figsize=(7.8,4.8))
    colors={'strong':'#2b6cb0','weak':'#c05621','weak_mitigated':'#2f855a'}
    for case in colors:
        for row in poles:
            if row['case']!=case or not 4.3<float(row['frequency_Hz'])<4.9:continue
            x=float(row['real_per_s']);y=float(row['imag_rad_s'])/(2*np.pi)
            ax.scatter(x,y,s=80,color=colors[case],label=case.replace('_',' '))
            offset={'strong':(8,11),'weak':(8,-15),'weak_mitigated':(8,5)}[case]
            ax.annotate(f"{float(row['damping_ratio'])*100:.1f}%",(x,y),
                        xytext=offset,textcoords='offset points',fontsize=9)
    handles,labels=ax.get_legend_handles_labels()
    ax.legend(dict(zip(labels,handles)).values(),dict(zip(labels,handles)).keys())
    ax.set_xlabel('Pole real part [1/s]');ax.set_ylabel('Oscillation frequency [Hz]')
    ax.set_xlim(-6.5,-0.6);ax.set_ylim(4.4,4.85)
    ax.set_title('Linearized physical model poles at 12 m/s')
    save('05_physical_eigenvalues.png')

print(f'{sum(r[1]=="PASS" for r in checks)}/{len(checks)} numerical checks passed')
print('Weak Prony pole',modes[2][2:],'mitigated',modes[3][2:])
