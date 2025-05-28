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
fileNames = {'400du_30min', '450du_30min', '500du_10min', '500du_120min', '400du_30min_local2', '400du_30min_local3_400a400'};

outputDataPath1 = 'H:\Github\MyRhinoLabData\p91_MgAlloy_SelectGG_2025\ctf_excerpt\';
outputDataPath2 = 'H:\Github\MyRhinoLabData\p91_MgAlloy_SelectGG_2025\ang_excerpt\';

if ~exist(outputDataPath1, 'dir'), mkdir(outputDataPath1); end
if ~exist(outputDataPath2, 'dir'), mkdir(outputDataPath2); end

numType = 5;
thresholdDegree = 25;
minGrainSize = 10.0;

% which files to be imported
for iFile = 6:6 % length(fileNames)
  inputFile = fullfile(inputDir, sprintf('c%d_%s.ctf', iFile, fileNames{iFile}));

  ebsd = EBSD.load(inputFile,CS,'interface','ctf', ...
    'convertEuler2SpatialReferenceFrame');

  [grains, ebsd] = identifyAndSmoothGrains(ebsd, 2.0 * degree, 10, minGrainSize);

  %% 晶粒识别 - red
  planeNormal = Miller({1,0,-1,2},CS{2});
  zDir = vector3d.Z;
  angles = zeros(length(grains),1);
  for iGrain = 1:length(grains)
    crystalDirections = grains(iGrain).meanOrientation * symmetrise(planeNormal);
    angles(iGrain) = min(angle(crystalDirections, zDir)./degree);
  end
  redGrain = grains(angles < thresholdDegree);

  %% 晶粒识别 - gree
  planeNormal = Miller({1,1,-2,0},CS{2});
  zDir = vector3d.Z; % ND方向，也可以用 vector3d(0,1,0) 表示 TD，vector3d.X 表示 RD
  angles = zeros(length(grains),1);
  for iGrain = 1:length(grains)
    crystalDirections = grains(iGrain).meanOrientation * symmetrise(planeNormal);
    angles(iGrain) = min(angle(crystalDirections, zDir)./degree);
  end
  greenGrain = grains(angles < thresholdDegree);

  % 构建未分类的晶粒集合
  combinedIndices = [redGrain.id; greenGrain.id];
  allGrainIds = [grains.id];  % 获取所有晶粒的 ID
  otherGrainIds = setdiff(allGrainIds, combinedIndices);  % 求差集
  otherGrain = grains(ismember(allGrainIds, otherGrainIds));
  
  %% 使用逻辑索引来筛选
  ebsdGrid = ebsd('indexed').gridify;
  
  % 初始化 grainType 为 3，假设默认是其他晶粒
  grainTypes = ones(length(ebsdGrid), 1) * 3;

  isRed = ismember(ebsdGrid.grainId, redGrain.id);
  isGreen = ismember(ebsdGrid.grainId, greenGrain.id);

  % 直接赋值对应的类型
  grainTypes(isRed) = 1;
  grainTypes(isGreen) = 2;

  %% 导出数据 - 1
  % Step 1: 导出包含rho信息的CTF格式文件
  outputFile = fullfile(outputDataPath1, sprintf('c%d_%s_grainType.ctf', iFile, fileNames{iFile}));
  export_ctf(ebsdGrid, grainTypes, outputFile); 

  % Step 2: 导出ANG格式文件供Dream3D使用
  outputFile = fullfile(outputDataPath2, sprintf('c%d_%s.ang', iFile, fileNames{iFile}));
  export_ang(ebsdGrid, outputFile);  
end

% p91_s3_three_type_grains
