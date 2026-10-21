%GENERATE_ALL_FIGURES Regenerate all result and report figures from current MAT files.
root=fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(root,'scripts'));
generate_figures();
generate_report_figures();
