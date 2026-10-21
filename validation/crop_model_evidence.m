% Focused crops of the MATLAB/Simulink top-level export. No drawing is added.
repo=fileparts(fileparts(mfilename('fullpath')));
asset=fullfile(repo,'Final_Delivery','Presentation_Assets');
I=imread(fullfile(asset,'01_complete_system.png'));
[h,w,~]=size(I);
assert(w>9000&&h>5000,'Expected 300 DPI Simulink diagram export');
imwrite(I(650:3150,1:4500,:),fullfile(asset,'02_pmsg_dq_model.png'));
imwrite(I(650:3150,4300:w,:),fullfile(asset,'04_grid_pcc.png'));
imwrite(I(400:3200,1:w,:),fullfile(asset,'01_power_path_detail.png'));
fprintf('FOCUSED_SIMULINK_CROPS_PASS\n');
