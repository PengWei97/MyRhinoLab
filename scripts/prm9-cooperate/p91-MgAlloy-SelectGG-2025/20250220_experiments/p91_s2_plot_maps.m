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
  inputFile = fullfile(inputDir, sprintf('c%d_%s.ctf', iFile, fileNames{iFile}));

  ebsd = EBSD.load(inputFile,CS,'interface','ctf', ...
    'convertEuler2SpatialReferenceFrame');

  % %% test
  % ebsd = ebsd(inpolygon(ebsd, [0,0,100,100]));

  [grains, ebsd] = identifyAndSmoothGrains(ebsd, 2.0 * degree, 10, minGrainSize);

  %% ebsd.orientation
  figure(numType*(iFile-1)+1)
  plot(ebsd, ebsd.orientations, 'microbar', 'on', 'linewidth', 1);
  hold on
  plot(grains.boundary, 'linewidth', 0.5);

  %% grain.meanOrientation
  figure(numType*(iFile-1)+2)
  plot(grains, grains.meanOrientation, 'microbar', 'on', 'linewidth', 1);
  hold on
  plot(grains.boundary, 'linewidth', 0.5);

  %% KAM map
  ebsdGrid = ebsd.gridify;
  kam = ebsdGrid.KAM / degree;
  figure(numType*(iFile-1)+3)
  plot(ebsdGrid, kam,'micronbar', 'off')
  mtexColorbar
  mtexColorMap WhiteJet
  hold on
  plot(grains.boundary,'lineWidth',0.8)
  hold off  

  %% GOS map
  mis2mean = calcGROD(ebsd, grains);
  GOS = ebsd.grainMean(mis2mean.angle);
  figure(numType*(iFile-1)+4)
  plot(grains, GOS ./ degree, 'micronbar', 'on', 'coordinates', 'off'); % 
  mtexColorbar('title','GOS in degree');
  set(gca, 'CLim', [0 5]);
  hold on;
  plot(grains.boundary, 'linewidth', 0.8);
  hold off;
end

% H:\Github\MyRhinoLab\scripts\prm9-cooperate\p91-MgAlloy-SelectGG-2025\20250220_experiments\p91_s2_plot_maps.m
