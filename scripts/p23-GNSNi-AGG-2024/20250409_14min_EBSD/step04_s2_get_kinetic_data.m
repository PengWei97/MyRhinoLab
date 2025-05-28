%% 脚本说明
% 创建时间：2024年4月20日
% 创建人：Pengwei
% 创建目的：该脚本用于处理并分析EBSD数据，具体功能包括：计算晶粒结构 + 各类统计信息
% 1. 各自的IPF map，GB map以及GB type map，
% 2. 晶粒数据信息（包括Grain ID，欧拉角，以及晶粒面积），
% 3. 计算输出每个区域中每个时间的平均晶粒半径以及残差，计算输出每个区域中每个时间取向差分布，晶界类型长度

close all;
clear;
clc;

% 定义晶体对称性
crystalSymmetry = {... 
  'notIndexed',... 
  crystalSymmetry('m-3m', [3.6 3.6 3.6], 'mineral', 'Ni-superalloy', 'color', [0.53 0.81 0.98])};

% 设置绘图的坐标轴方向
setMTEXpref('xAxisDirection', 'west');
setMTEXpref('zAxisDirection', 'outOfPlane');

%% 指定文件路径
inputDir = 'H:\Github\MyRhinoLabData\p23_GNSNi_AGG_2024\experiment2\14min_EBSD\f_csv_statistic\';
outputDir1 = 'H:\Github\MyRhinoLabData\p23_GNSNi_AGG_2024\experiment2\14min_EBSD\h_csv_kinetic\';

Locals = linspace(14,14,4);
numLocals = length(Locals);

numTypeFigures = 2;  % 每个时间点绘制的图像数量

regionType = {'global', 'Layer1', 'Layer2'};


% 循环处理每个时间点的数据
for iRegionType = 1:length(regionType)
  % GG kinetic
  outputTabeGGKinetic = table;
  outputTabeGGKinetic.Time = 14;
  outputTabeGGKinetic.weightGrainRadius = zeros(1,1);
  outputTabeGGKinetic.StdRadius = zeros(1,1);

  grainDataAll= table();
  for iLocal = 1:numLocals
    inputFile = fullfile(inputDir, sprintf('GNSNi_14min_R%d_%s_grain_data.csv',iLocal,regionType{iRegionType}));

    grainData = readtable(inputFile);
    grainDataAll = [grainDataAll; grainData];
  end

  %% get grain kinetic
  grainArea = grainDataAll.grainSize;
  grainRadius = sqrt(grainArea./pi);
  outputTabeGGKinetic.weightGrainRadius(1,1) = sum(grainArea.*grainRadius)/sum(grainArea);    
  % 计算加权标准偏差
  variance = sum(grainArea .* (grainRadius - outputTabeGGKinetic.weightGrainRadius(1,1)).^2) / sum(grainArea);
  outputTabeGGKinetic.StdRadius(1,1) = sqrt(variance);

  %% 输出 GG kinetic
  outputFileKinetics = fullfile(outputDir1, sprintf('GNSNi_14min_%s_kinetic.csv', regionType{iRegionType}));
  writetable(outputTabeGGKinetic, outputFileKinetics);
end
% H:\Github\MyRhinoLab\scripts\p23-GNSNi-AGG-2024\20250409_14min_EBSD\step04_s2_get_kinetic_data.m