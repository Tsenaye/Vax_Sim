import fs from 'node:fs/promises';
import path from 'node:path';
import { pathToFileURL, fileURLToPath } from 'node:url';
const runtimeModules='C:/Users/Tsenaye/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules';
const { Presentation, PresentationFile }=await import(pathToFileURL(path.join(runtimeModules,'@oai','artifact-tool','dist','artifact_tool.mjs')).href);

const root=path.resolve(path.dirname(fileURLToPath(import.meta.url)),'..');
const assets=path.join(root,'Final_Delivery','Presentation_Assets');
const build=path.join(root,'tmp','presentation_build');
const dest=path.join(root,'Final_Delivery','Vataleni_PMSG_SSO_Three_Slide_Presentation.pptx');
const skill='C:/Users/Tsenaye/.codex/plugins/cache/openai-primary-runtime/presentations/26.1017.22135/skills/presentations';
await fs.mkdir(build,{recursive:true});
await fs.mkdir(path.dirname(dest),{recursive:true});
const imageData=new Map();
for(const name of ['01_complete_system.png','01_power_path_detail.png','02_msc_control.png','03_gsc_pll_control.png',
                   '06_sso_unmitigated.png','07_sso_mitigated.png','08_scenario_comparison.png']) {
  imageData.set(name,new Uint8Array(await fs.readFile(path.join(assets,name))));
}
const pres=Presentation.create({slideSize:{width:1280,height:720}});
const NAVY='#132B43', BLUE='#315D79', GREY='#4F5E68', LIGHT='#DCE4E9', ORANGE='#C46A28';

function rect(slide,x,y,w,h,fill){
  return slide.shapes.add({geometry:'rect',position:{left:x,top:y,width:w,height:h},fill,
    line:{style:'solid',fill:'none',width:0}});
}
function txt(slide,s,x,y,w,h,size=20,bold=false,color=NAVY){
  const sh=slide.shapes.add({geometry:'textbox',position:{left:x,top:y,width:w,height:h},
    fill:'none',line:{style:'solid',fill:'none',width:0}});
  sh.text=s;sh.text.style={fontSize:size,typeface:'Arial',bold,color};return sh;
}
function img(slide,name,x,y,w,h,alt){
  return slide.images.add({blob:imageData.get(name),contentType:'image/png',alt,fit:'contain',
    position:{left:x,top:y,width:w,height:h}});
}
function base(title,num){
  const s=pres.slides.add();s.background.fill='#FFFFFF';
  rect(s,0,0,1280,11,NAVY);
  txt(s,title,48,34,1180,62,35,true,NAVY);
  rect(s,48,105,1184,2,LIGHT);
  txt(s,`VATaleni PMSG–SSO  |  ${num}/3`,48,680,1180,24,13,false,GREY);
  return s;
}

{
 const s=base('PMSG-Based Wind Turbine System: Simulink Model Architecture',1);
 txt(s,'ACTUAL SIMULINK POWER PATH',48,122,750,25,17,true,BLUE);
 img(s,'01_power_path_detail.png',40,153,846,429,'Focused MATLAB export of the actual wind-to-grid top-level power path');
 txt(s,'COMPLETE MODEL',922,125,300,25,17,true,BLUE);
 img(s,'01_complete_system.png',916,157,312,172,'Complete top-level Simulink model including controls and telemetry');
 txt(s,'Wind > shaft > PMSG > MSC > DC link > GSC > filter > PCC > grid',924,348,295,106,19,false,NAVY);
 txt(s,'The MSC controls generator torque and current. The GSC regulates the DC link and grid current through the PLL.',924,475,295,116,17,false,GREY);
 txt(s,'Native equipment; averaged converters',924,603,295,48,15,true,ORANGE);
 s.speakerNotes.text='Both model views are direct crops of the actual final saved Simulink model exported at high resolution. The lower controller subsystems are visible in the complete model inset. The machine is a native PMSM with full d/q electrical dynamics. Sources: project technical report and MathWorks block documentation.';
}
{
 const s=base('Converter Control, Grid Interaction and Subsynchronous Oscillation',2);
 txt(s,'MACHINE-SIDE SPEED + d/q CURRENT LOOPS',50,127,560,27,17,true,BLUE);
 txt(s,'GRID-SIDE DC + d/q CURRENT + PLL LOOPS',652,127,560,27,17,true,BLUE);
 img(s,'02_msc_control.png',45,163,565,341,'Actual Simulink MSC control subsystem');
 img(s,'03_gsc_pll_control.png',650,163,565,341,'Actual Simulink GSC and PLL subsystem');
 img(s,'06_sso_unmitigated.png',49,520,565,145,'Measured unmitigated PCC q-axis voltage from weak-grid physical run');
 txt(s,'At nominal external SCR 5, the same wind step excites a decaying 4.6–4.7 Hz network/controller mode. No oscillation is injected into the plant.',646,529,570,104,19,false,NAVY);
 txt(s,'Measured peak: 4.681 Hz  •  Snapshot damping: 5.24%',646,635,570,27,17,true,ORANGE);
 s.speakerNotes.text='The control images are genuine exports from the saved Simulink model. The lower graph is a native MATLAB figure generated from the final physical-model weak-grid run. The wind step at 2 s is the disturbance. External SCR refers to the separately modelled grid impedance. Reference: Wang et al., DOI 10.1109/EI247390.2019.9061793; project technical report.';
}
{
 const s=base('Simulation Results and SSO Mitigation Performance',3);
 txt(s,'WEAK GRID — UNMITIGATED',50,124,540,25,17,true,BLUE);
 txt(s,'WEAK GRID — PLL RETUNED',50,371,540,25,17,true,BLUE);
 img(s,'06_sso_unmitigated.png',47,151,535,207,'Unmitigated PCC q-axis voltage at external SCR 5');
 img(s,'07_sso_mitigated.png',47,398,535,207,'Mitigated PCC q-axis voltage at external SCR 5');
 img(s,'08_scenario_comparison.png',608,137,625,375,'Measured common-axis comparison of strong, weak and mitigated grid runs');
 txt(s,'Early PCC q-voltage variation (2.25–3.25 s)',622,525,580,26,18,true,NAVY);
 txt(s,'SCR 10: 1.788 V   •   SCR 5: 3.997 V   •   mitigated: 0.554 V',622,556,583,64,20,false,NAVY);
 txt(s,'PLL Kp 0.00558 → 0.02 rad/(s·V); matched 4.6 Hz mode damping 5.24% → 18.99%. The response decays in all tested runs.',622,623,585,53,16,false,GREY);
 s.speakerNotes.text='Both left plots have identical axes and are native MATLAB exports from the final saved physical SLX. The comparison is from identical 12 to 13 m/s wind steps at 2 s. Early values are standard deviations of PCC q-axis voltage over 2.25–3.25 s. The 4.6 Hz mode is the matched snapshot linearization mode, not the least-damped mitigated mode overall. No unstable SSO or site-specific prediction is claimed. Source: project technical and verification reports.';
}

for(let i=0;i<3;i++){
 const blob=await pres.export({slide:pres.slides.items[i],format:'png',scale:1});
 await fs.writeFile(path.join(build,`slide-${i+1}.png`),new Uint8Array(await blob.arrayBuffer()));
}
const candidate=path.join(build,'candidate.pptx');
await (await PresentationFile.exportPptx(pres)).save(candidate);
const {finalizePresentation}=await import(pathToFileURL(path.join(skill,'container_tools','artifact_tool_utils.mjs')).href);
const result=await finalizePresentation({
 workspaceDir:root,candidatePath:candidate,finalPath:dest,
 pythonExecutable:'C:/Users/Tsenaye/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe',
 integrityValidatorPath:path.join(skill,'container_tools','inspect_presentation_package_integrity.py'),
 layoutValidatorPath:path.join(skill,'container_tools','inspect_presentation_layout_geometry.py'),
 layoutArgs:['--expected-slide-size-emu','12192000,6858000','--validate-heading-fit'],
 explicitTotalSlideCount:3,
 requiredNativeTableOwnerSlides:[],requiredNativeChartOwnerSlides:[],
 fontPolicy:{basis:'design',families:['Arial']},
 verifyArtifactToolImport:true,
 receiptPath:path.join(build,'validation-final.json'),
});
console.log(JSON.stringify({output:dest,result},null,2));
