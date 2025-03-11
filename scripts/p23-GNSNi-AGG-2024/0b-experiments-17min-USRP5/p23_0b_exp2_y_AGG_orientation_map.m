close all
clear
clc

inputFileDir = 'H:\Github\MyRhinoLabData\p23_GNSNi_AGG_2024\ebsd\USRP5_17min_20250302\csv_AGG_data\';
global_AGG_data = table();

for iRegion = 1:8
  inputFile = fullfile(inputFileDir, sprintf('R%d_AGG_data.csv', iRegion));

  if exist(inputFile, 'file') == 2
    currentTable = readtable(inputFile);
    global_AGG_data = [global_AGG_data; currentTable];

    fprintf('已成功读取并合并文件： %s\n', sprintf('R%d_AGG_data.csv', iRegion));
  else
    warning('文件不存在: %s', sprintf('R%d_AGG_data.csv', iRegion));
  end
end

%% disp(global_AGG_data)
phi1 = global_AGG_data.phi1;
Phi = global_AGG_data.Phi;
phi2 = global_AGG_data.phi2;

% CS = crystalSymmetry('m-3m', [3.6 3.6 3.6], 'mineral', 'Ni-superalloy', 'color', [0.53 0.81 0.98]);
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

% H:\Github\MyRhinoLab\scripts\p23-GNSNi-AGG-2024\0b-experiments-17min-USRP5\p23_0b_exp2_y_AGG_orientation_map.m