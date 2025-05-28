close all
clear
clc

inputFileDir = 'H:\Github\MyRhinoLabData\p23_GNSNi_AGG_2024\experiment2\PF_Initial\csv_AGG_data\';
timePoints = [5.0, 10.0, 20.0, 30.0];  % 时间点（分钟）

for iTime = 3:3
  inputFile = fullfile(inputFileDir, sprintf('GNSNi_%dmin_%s_AGG.ctf', timePoints(iTime), baseName));
  tableData = readtable(inputFile);
end

%% disp(global_AGG_data)
phi1 = global_AGG_data.phi1;
Phi = global_AGG_data.Phi;
phi2 = global_AGG_data.phi2;

cs = crystalSymmetry('m-3m');
ss = specimenSymmetry('orthorhombic');

ori = orientation.byEuler(phi1 * degree, Phi * degree, phi2 * degree, cs, ss);

odf = calcDensity(ori);
figure(1)
plotPDF(odf, Miller({1,0,0},{1,1,0},{1,1,1},{3,1,1}, cs));
figure(2)
plotIPDF(odf,[xvector,yvector,zvector])

% plotSection(odf,'contourf');
% mtexColorMap WhiteJet
% mtexColorbar

% plot(odf)
% set(gcf, 'Unit', 'centimeters', 'Color', 'None');
% set(gca, 'Color', 'None'); % Set axes background color to transparent

% H:\Github\MyRhinoLab\scripts\p23-GNSNi-AGG-2024\20250507_Layer2a3_and_Layer1a2\p23_s4_plot_pole_figure_from_agg_0507.m