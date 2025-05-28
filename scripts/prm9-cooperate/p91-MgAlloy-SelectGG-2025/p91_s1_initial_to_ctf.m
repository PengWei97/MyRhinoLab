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
inputDir = 'H:\Github\MyRhinoLabData\p91_MgAlloy_SelectGG_2025\';
outputDir = 'H:\Github\MyRhinoLabData\p91_MgAlloy_SelectGG_2025\ctf_excerpt\';

if ~exist(outputDir, 'dir'), mkdir(outputDir); end
fileNames = {'400du_30min', '450du_30min', '500du_10min', '500du_120min'};
minGrainSize = 10;

% which files to be imported
for iFile = 3:4 % length(fileNames)
  inputFile = fullfile(inputDir, sprintf('c%d_%s.ctf', iFile, fileNames{iFile}));

  ebsd = EBSD.load(inputFile,CS,'interface','ctf', ...
    'convertEuler2SpatialReferenceFrame');

  % figure(iFile)
  % plot(ebsd, ebsd.orientations)
  
  % [~, ebsd] = identifyAndSmoothGrains(ebsd, 2.0 * degree, 10, minGrainSize);
  % [xmin,xmax,ymin,ymax] =  ebsd.extend();
  % ebsd = ebsd(inpolygon(ebsd, [0,200,400,400]));

  %% 细化、填充，降噪等处理
  ebsdToRefine = transformMesh(ebsd, 2.0);  % 变换网格

  % 迭代不同的平滑参数
  alphaValues = [0.0, 0.0];  % alpha值控制填充的强度
  for iFill = 1:length(alphaValues)
      % 标识并平滑晶粒
      [grainsToRefine, ebsdToRefine] = identifyAndSmoothGrains(ebsdToRefine, 2.0 * degree, 60, 20.0);
      
      % 使用二次滤波器进行平滑
      F = halfQuadraticFilter;
      F.alpha = alphaValues(iFill);
      ebsdToRefine = smooth(ebsdToRefine, F, 'fill', grainsToRefine);
      
      % 只保留已标记的晶粒
      ebsdToRefine = ebsdToRefine('indexed');
  end

  % [grains, ebsdToRefine] = identifyAndSmoothGrains(ebsdToRefine, 2.0 * degree, 10, minGrainSize);

  % 导出CTF格式文件
  outputFile = fullfile(outputDir, sprintf('c%d_%s.ctf', iFile, fileNames{iFile}));
  export_ctf(ebsdToRefine, outputFile);
end
% H:\Github\MyRhinoLab\scripts\prm9-cooperate\p91-MgAlloy-SelectGG-2025\p91_s1_initial_to_ctf.m

