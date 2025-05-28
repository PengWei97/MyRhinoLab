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
for iFile = 3:3 % length(fileNames)
  inputFile = fullfile(inputDir, sprintf('c%d_%s.ctf', iFile, fileNames{iFile}));

  ebsd = EBSD.load(inputFile,CS,'interface','ctf', ...
    'convertEuler2SpatialReferenceFrame');

  [grains, ebsd] = identifyAndSmoothGrains(ebsd, 2.0 * degree, 10, minGrainSize);

  figure(iFile)
  plot(grains, grains.meanOrientation, 'microbar', 'on', 'linewidth', 1);
  hold on
  plot(grains.boundary, 'linewidth', 0.5);  

  %% 晶粒识别 - red
  planeNormal = Miller({1,0,-1,2},CS{2});
  zDir = vector3d.Z; % ND方向，也可以用 vector3d(0,1,0) 表示 TD，vector3d.X 表示 RD
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

  %% 计算平均晶粒尺寸
  [xmin, xmax, ymin, ymax] = ebsd.extend();
  pixel2Area = (xmax - xmin) * (ymax - ymin) / length(ebsd);
  grainArea = grains.grainSize.*pixel2Area;
  redGrainArea = redGrain.grainSize.*pixel2Area;
  greenGrainArea = greenGrain.grainSize.*pixel2Area;
  otherGrainArea = otherGrain.grainSize.*pixel2Area;

  [RaidusGrain, RGrain] = calculatedMeanRadius(grainArea);
  [RaidusRedGrain, RRedGrain] = calculatedMeanRadius(redGrainArea);
  [RaidusGreenGrain, RGreenGrain] = calculatedMeanRadius(greenGrainArea);
  [RaidusOtherGrain, ROtherGrain] = calculatedMeanRadius(otherGrainArea);

  % disp(['the R and std of grain: ', num2str(RaidusGrain), ',', num2str(RGrain)]);
  % disp(['the R and std of the red grain: ', num2str(RaidusRedGrain), ',', num2str(RRedGrain)]);
  % disp(['the R and std of the green grain: ', num2str(RaidusGreenGrain), ',', num2str(RGreenGrain)]);   
  % disp(['the R and std of the other grain: ', num2str(RaidusOtherGrain), ',', num2str(ROtherGrain)]);   
  
  %% 计算各自面积占比
  TotalArea = sum(grainArea);
  grainFraction = 1.0;
  redGrainFraction = sum(redGrainArea)/TotalArea;
  greenGrainFraction = sum(greenGrainArea)/TotalArea;
  disp(['the are fraction: ', num2str(grainFraction), ',', num2str(redGrainFraction), ',', num2str(greenGrainFraction)]);
end

% H:\Github\MyRhinoLab\scripts\prm9-cooperate\p91-MgAlloy-SelectGG-2025\p91_s3_three_type_grains_and_get_kinetics_data.m
