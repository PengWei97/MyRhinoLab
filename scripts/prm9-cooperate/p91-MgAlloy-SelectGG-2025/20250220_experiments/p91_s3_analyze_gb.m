% p91_s2_plot_maps.m
% 功能：绘制 IPF map、KAM map 和 GOS map
% 作者：Wei
% 创建时间：2025-05-20 20:12:50
% -------------------------------------------

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
fileNames = {'400du_30min', '450du_30min', '500du_10min', '500du_120min'};

numType = 5;
thresholdDegree = 25;
minGrainSize = 10.0;

% which files to be imported
for iFile = 1:1 % length(fileNames)
  if iFile == 2 || iFile == 3
    continue
  end

  inputFile = fullfile(inputDir, sprintf('c%d_%s.ctf', iFile, fileNames{iFile}));

  ebsd = EBSD.load(inputFile,CS,'interface','ctf', ...
    'convertEuler2SpatialReferenceFrame');

  % %% test
  % ebsd = ebsd(inpolygon(ebsd, [0,0,100,100]));
  
  [grains, ebsd] = identifyAndSmoothGrains(ebsd, 2.0 * degree, 10, minGrainSize);
  gb_MgMg = grains.boundary('Magnesium', 'Magnesium');
  CS_MgMg = grains.CS; % extract crystal symmetry

  %% GB type identify and draw
  [twinBoundary1, twinBoundary2, csl3, csl7, lowAngleGB, highAngleGB] = identifyGBsMg(grains, ebsd);
  plotGrainBoundaryMaps(lowAngleGB, highAngleGB, twinBoundary1, twinBoundary2, csl3, csl7, numType*(iFile-1)+1);  

  %% misorientation distribution
  figure(2)
  hold on
  plotAngleDistribution(gb_MgMg.misorientation)

  odf = calcDensity(ebsd.orientations);
  mdf = calcMDF(odf);
  figure(3)
  hold on
  plotAngleDistribution(mdf)
end

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

% H:\Github\MyRhinoLab\scripts\prm9-cooperate\p91-MgAlloy-SelectGG-2025\20250220_experiments\p91_s3_analyze_gb.m
