%% 脚本说明
% 创建时间：2024年4月20日
% 创建人：Pengwei
% 创建目的：该脚本用于处理并分析 EBSD 数据，具体功能包括：
% 区域/分层输出 EBSD 数据（将整体 EBSD 数据分割为多个深度区域并分别导出）

close all;
clear;
clc;

%% 定义晶体对称性
% Define crystal symmetry for the EBSD dataset
crystalSymmetry = {
  'notIndexed', ...
  crystalSymmetry('m-3m', [3.6 3.6 3.6], 'mineral', 'Ni-superalloy', 'color', [0.53 0.81 0.98])};

%% 设置绘图坐标轴方向
% Set plotting coordinate directions
setMTEXpref('xAxisDirection', 'east');
setMTEXpref('zAxisDirection', 'intoPlane');

%% 指定文件路径
% Define the input data directory
inputDir = 'H:\Github\MyRhinoLabData\p23_GNSNi_AGG_2024\experiment2\14min_EBSD\b_ctf_figs\';

numLocals = 4;
numTypeFigures = 4;

% 定义分层深度位置（单位：微米）
% Define depth positions (in microns) for layer segmentation
deepLayer = 170;

%% 循环处理每个时间点的数据
% Loop over each time point for processing
for iLocal = 1:numLocals

  % 构建当前时间点的 CTF 文件路径
  % Construct the input filename for current time point
  inputFile = fullfile(inputDir, sprintf('GNSNi_14min_R%d.ctf', iLocal));
  %% 导入 EBSD 数据
  % Import EBSD dataset using MTEX
  ebsdData = EBSD.load(inputFile, crystalSymmetry, 'interface', 'ctf', ...
                        'convertEuler2SpatialReferenceFrame');

  % 获取数据边界信息
  % Get boundary extent of the dataset
  [xmin, xmax, ymin, ymax] = ebsdData.extend();

  for iLayer = 2:2
    if iLayer == 1
      ebsdDataLayerX = ebsdData(inpolygon(ebsdData, [xmin, ymin, xmax - xmin, deepLayer]));
    elseif iLayer == 2
      ebsdDataLayerX = ebsdData(inpolygon(ebsdData, [xmin, deepLayer, xmax - xmin, ymax-deepLayer]));      
    end

    %% 绘图（用于快速查看）
    % Plot EBSD map of each extracted layer
    idFigure = numTypeFigures * (iLocal - 1) + iLayer;
    figure(idFigure)
    plot(ebsdDataLayerX, ebsdDataLayerX.orientations, 'coordinates', 'off', 'micronbar', 'off');

    %% 导出分层后的数据为 CTF 文件
    % Export the layer as a separate CTF file
    outputFile = fullfile(inputDir, sprintf('GNSNi_14min_R%d_Layer%d.ctf', iLocal, iLayer));
    export_ctf(ebsdDataLayerX, outputFile);
  end
end 

%% 脚本路径（用于记录与追踪）
% Script path: 
% H:\Github\MyRhinoLab\scripts\p23-GNSNi-AGG-2024\20250409_14min_EBSD\step03_split_ebsd_by_layer_GNSNi_14min.m