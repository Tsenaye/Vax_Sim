"""Render the matching three-page explainer PDF with fixed, reviewable pages."""
from pathlib import Path
from PIL import Image
from reportlab.lib import colors
from reportlab.lib.pagesizes import A4, landscape
from reportlab.lib.styles import ParagraphStyle
from reportlab.lib.utils import ImageReader
from reportlab.pdfbase.pdfmetrics import stringWidth
from reportlab.pdfgen import canvas
from reportlab.platypus import Paragraph

ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'Final_Delivery'
ASSET=OUT/'Presentation_Assets'
SCOPE=OUT/'Results'/'05_Scope_Captures'
DEST=OUT/'Vataleni_PMSG_SSO_Three_Page_Explainer.pdf'
PAGE_W,PAGE_H=landscape(A4)
NAVY=colors.HexColor('#132B43');GREY=colors.HexColor('#4F5E68')
BODY=ParagraphStyle('body',fontName='Helvetica',fontSize=9.5,leading=13.2,textColor=NAVY)
SMALL=ParagraphStyle('small',fontName='Helvetica',fontSize=8.2,leading=11,textColor=GREY)
CAP=ParagraphStyle('cap',fontName='Helvetica-Oblique',fontSize=8,leading=10,textColor=GREY)
IMGDIR=ROOT/'tmp'/'three_page_images';IMGDIR.mkdir(parents=True,exist_ok=True)

def prepared(path,limit=3200):
    img=Image.open(path).convert('RGB')
    if img.width>limit:
        target=IMGDIR/(path.stem+'_pdf.jpg')
        img.thumbnail((limit,limit*2),Image.Resampling.LANCZOS)
        img.save(target,quality=92,optimize=True)
        return target
    return path
def para(c,s,x,top,w,style=BODY):
    p=Paragraph(s,style);_,h=p.wrap(w,2000);p.drawOn(c,x,top-h);return top-h
def title(c,s,n):
    c.setFillColor(NAVY);c.rect(0,PAGE_H-10,PAGE_W,10,fill=1,stroke=0)
    c.setFont('Helvetica-Bold',18);c.drawString(42,PAGE_H-43,s)
    c.setFont('Helvetica',8);c.setFillColor(GREY)
    c.drawRightString(PAGE_W-42,25,f'Vataleni PMSG-SSO  |  {n}/3')
def image(c,path,x,y,w,h):
    assert path.is_file(),path
    c.drawImage(ImageReader(str(prepared(path))),x,y,w,h,preserveAspectRatio=True,anchor='c',mask='auto')
def line(c,x,y,w):
    c.setStrokeColor(colors.HexColor('#DCE4E9'));c.setLineWidth(.5);c.line(x,y,x+w,y)

c=canvas.Canvas(str(DEST),pagesize=(PAGE_W,PAGE_H))
c.setTitle('Vataleni PMSG-SSO - Three-page explainer')

# Page 1: architecture.
title(c,'1  Physical model architecture',1)
image(c,ASSET/'01_complete_system.png',42,128,PAGE_W-84,410)
para(c,'Figure 1. Full top-level model exported directly from Simulink. Power conversion runs left to right; grouped MSC and GSC/PLL controls sit below the physical network.',42,117,PAGE_W-84,CAP)
line(c,42,92,PAGE_W-84)
para(c,'The saved model connects a wind turbine and shaft to a native PMSG, machine-side converter (MSC), DC capacitor, grid-side converter (GSC), RL filter, PCC and three-phase grid. The PMSM integrates stator d/q current states; both converters are averaged. The 5 MW rating follows Wang et al. (2019); other parameter values are project engineering assumptions.',42,83,PAGE_W-84,BODY)
c.showPage()

# Page 2: control and mechanism.
title(c,'2  Converter controls and weak-grid response',2)
para(c,'The MSC regulates rotor speed and machine d/q current. The GSC regulates DC-link voltage and grid current in a PLL-aligned frame. Figure 2 shows the actual control subsystems; measurement paths are separate from the physical power path.',42,PAGE_H-61,PAGE_W-84,BODY)
image(c,ASSET/'02_msc_control.png',45,236,350,259)
image(c,ASSET/'03_gsc_pll_control.png',421,236,285,259)
para(c,'Figure 2. Machine-side control (left) and GSC/PLL control (right), exported from the saved Simulink model.',42,226,PAGE_W-84,CAP)
line(c,42,205,PAGE_W-84)
para(c,'A 12 to 13 m/s wind step at 2 s changes turbine torque and converter power. Reducing nominal external short-circuit ratio (SCR) from 10 to 5 under that same step produces a larger, decaying PCC q-axis voltage oscillation. No sinusoid is injected into the model.',42,193,PAGE_W-84,BODY)
para(c,'The weak-grid FFT peak is 4.681 Hz. The near-equilibrium physical-model snapshot mode is 4.638 Hz with 5.24% damping. The tested mitigation changes PLL proportional gain from 0.00558 to 0.02 rad/(s V) while integral gain remains 1.56 rad/(s^2 V).',42,140,PAGE_W-84,BODY)
para(c,'Wang et al., DOI 10.1109/EI247390.2019.9061793, motivates Prony-based SSO analysis. Frequencies and gains above are measurements or assumptions of this project, not values copied from that paper.',42,82,PAGE_W-84,SMALL)
c.showPage()

# Page 3: evidence.
title(c,'3  Results and interpretation',3)
para(c,'Figure 3 compares identical wind steps with common voltage and time axes. Figure 4 shows an actual native Scope display after the weak-grid simulation.',42,PAGE_H-61,PAGE_W-84,BODY)
image(c,ASSET/'08_scenario_comparison.png',43,236,518,280)
scope=SCOPE/'weak_grid_11.png'
image(c,scope,580,293,217,135)
para(c,'Figure 3. Measured PCC q-axis voltage comparison. Figure 4. Weak-grid Scope response from the saved physical model.',42,224,PAGE_W-84,CAP)
line(c,42,201,PAGE_W-84)
headers=['Case','Early PCC q std','Late DC voltage','Late PCC power']
values=['SCR 10 / SCR 5 / mitigated','1.788 / 3.997 / 0.554 V','1405.27 / 1405.42 / 1405.42 V','4.916 / 4.916 / 4.916 MW']
xs=[45,273,459,627];widths=[220,178,160,167]
for i,(head,val) in enumerate(zip(headers,values)):
    c.setFillColor(NAVY);c.setFont('Helvetica-Bold',8);c.drawString(xs[i],183,head)
    c.setFillColor(GREY);c.setFont('Helvetica',7.5);c.drawString(xs[i],168,val)
para(c,'The early standard deviation uses 2.25-3.25 s. PLL retuning reduces the unmitigated weak-grid metric by a factor of 7.21. Damping of the matched 4.6 Hz linearized mode rises from 5.24% to 18.99%. The mitigated least-damped mode overall is a different 1.843 Hz mode. All four scenarios and 25 physical/numerical checks pass.',42,146,PAGE_W-84,BODY)
para(c,'The response decays. This assumed, averaged single-turbine model does not establish a sustained instability, a site-calibrated SCR threshold, PWM harmonics or shaft torsion. Full methods and parameter provenance are in the accompanying reports.',42,73,PAGE_W-84,SMALL)
c.showPage();c.save()
print(DEST)
