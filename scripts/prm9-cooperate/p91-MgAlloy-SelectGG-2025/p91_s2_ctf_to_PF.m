close all
clear
clc

%% Import Script for EBSD Data
%
% This script was automatically created by the import wizard. You should
% run the whoole script or parts of it in order to import your data. There
% is no problem in making any changes to this script.

%% Specify Crystal and Specimen Symmetries

% crystal symmetry
CS = {... 
  'notIndexed',...
  crystalSymmetry('6/mmm', [3.2 3.2 5.2], 'X||a*', 'Y||b', 'Z||c*', 'mineral', 'Magnesium', 'color', [0.53 0.81 0.98])};

% plotting convention
setMTEXpref('xAxisDirection','west');
setMTEXpref('zAxisDirection','outOfPlane');

%% Specify File Names

% path to files
inputDir = 'H:\Github\MyRhinoLabData\p91_MgAlloy_SelectGG_2025\ctf_excerpt\';
fileNames = {'400du_30min', '450du_30min', '500du_10min', '500du_120min','400du_30min_local2','400du_30min_local3_400a400'};

numType = 1;

% which files to be imported
for iFile = 6:6 % length(fileNames)
  inputFile = fullfile(inputDir, sprintf('c%d_%s.ctf', iFile, fileNames{iFile}));

  ebsd = EBSD.load(inputFile,CS,'interface','ctf', ...
    'convertEuler2SpatialReferenceFrame');

  figure(numType*(iFile-1)+1)
  plot(ebsd, ebsd.orientations)

  % %% 取向
  % figure(numType*(iFile-1)+2)
  % ori_ebsd = ebsd.orientations;
  % plotPDF(ebsd.orientations,Miller({1,0,-1,2},CS{2})); % ,{1,0,-1,0},{1,1,-2,0},{0,0,0,1},{1,0,-1,1},{1,0,-1,2} ,'contourf'
  % % plotPDF(ebsd.orientations,Miller({1,1,-2,0},CS{2}),'contourf'); % ,{1,0,-1,0},{1,1,-2,0},{0,0,0,1},{1,0,-1,1},{1,0,-1,2} contourf
  % mtexColorbar
  % set(gca, 'CLim', [0.3, 2.4]);
  % set(gcf, 'Unit', 'centimeters', 'Color', 'None');
  % set(gca, 'Color', 'None'); % Set axes background color to transparent

  % figure(numType*(iFile-1)+2)
  % odf = calcDensity(ebsd.orientations);
  % plotPDF(odf, Miller({0,0,0,1},{1,0,-1,0},{1,1,-2,0},CS{2}),'contourf')
  % mtexColorbar

  [grains, ebsd] = identifyAndSmoothGrains(ebsd, 2.0 * degree, 10, 3.0);
  figure(numType*(iFile-1)+2)
  plot(grains, grains.meanOrientation, 'microbar', 'on', 'linewidth', 1);
  hold on
  plot(grains.boundary, 'linewidth', 0.5);  

  % ori_grain = grains.meanOrientation;
  % plotPDF(ori_grain,Miller({1,0,-1,2},CS{2})) % ,'contourf'
  % mtexColorbar  

  % %% GOS
  % [grains, ebsd] = identifyAndSmoothGrains(ebsd, 2.0 * degree, 10, 3.0);
  % mis2mean = calcGROD(ebsd, grains);
  % GOS = ebsd.grainMean(mis2mean.angle);
  % % draw GOS distribution
  % figure(numType*(iFile-1)+3)
  % plot(grains, GOS ./ degree, 'micronbar', 'on', 'coordinates', 'off'); % 
  % mtexColorbar('title','GOS in degree');
  % set(gca, 'CLim', [0 5]);
  % hold on;
  % plot(grains.boundary, 'linewidth', 0.8);
  % hold off;

  % %% GB type
  % [twinBoundary1, twinBoundary2, csl3, csl7, lowAngleGB, highAngleGB] = identifyGBsMg(grains, ebsd);
  % % 绘制GB maps
  % plotGrainBoundaryMaps(lowAngleGB, highAngleGB, twinBoundary1, twinBoundary2, csl3, csl7, numType*(iFile-1)+4);
end

% ipfKey=ipfColorKey(ebsd('Magnesium'));
% plot(ipfKey)
% set(gcf, 'Unit', 'centimeters', 'Color', 'None');
% set(gca, 'Color', 'None'); % Set axes background color to transparent

function plotGrainBoundaryMaps(lowAngleGB, highAngleGB, twinBoundary1, twinBoundary2, csl3, csl7, figureIndex)
  figure(figureIndex);
  plot(highAngleGB, 'linecolor', 'Black', 'linewidth', 1, 'displayName', 'High angle grain boundary');
  hold on;
  plot(lowAngleGB, 'linecolor', 'blue', 'linewidth', 1.5, 'displayName', 'Low angle grain boundary');
  plot(twinBoundary1, 'linecolor', 'gold', 'linewidth', 3, 'displayName', 'Tensile twin boundary');
  plot(twinBoundary2, 'linecolor', 'g', 'linewidth', 3, 'displayName', 'Compression twin boundary');
  plot(csl3, 'linecolor', 'm', 'linewidth', 3, 'displayName', 'CSL3');
  plot(csl7, 'linecolor', 'c', 'linewidth', 3, 'displayName', 'CSL7');
  hold off;

  lgd = legend('FontSize', 18, 'TextColor', 'black', 'Location', 'southeast', 'NumColumns', 1, 'FontName', 'Times New Roman');
  set(lgd, 'Visible', 'on');
end


% H:\Github\MyRhinoLab\scripts\prm9-cooperate\p91-MgAlloy-SelectGG-2025\p91_s2_ctf_to_PF.m

