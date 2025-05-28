%% Script Information
% 创建时间：2025年4月8日
% 创建人：Pengwei
% 功能概述：
% 本脚本用于处理 GNS-Ni 材料的原始 CTF 格式 EBSD 数据，具体功能包括：
% 1. 绘制原始 EBSD 的 IPF 图（Inverse Pole Figure map）；
% 应用背景：demo for QIS-EBSD

%% 初始化环境
close all;
clear;
clc;

%% 设置晶体对称性（以Ni为例）
cs = {
  'notIndexed', ...
  crystalSymmetry('m-3m', [3.6 3.6 3.6], ...
  'mineral', 'Ni-superalloy', ...
  'color', [0.53 0.81 0.98])
};

%% 设置绘图坐标方向（符合 EBSD 约定）
setMTEXpref('xAxisDirection', 'west');
setMTEXpref('zAxisDirection', 'outOfPlane');

%% 数据路径与时间点设置
inputDir = 'H:\Github\MyRhinoLabData\p23_GNSNi_AGG_2024\experiment2\14min_EBSD\a_ctf_initial\';

numLocals = 8;

%% 主循环：按时间点读取并绘图
for iLocal = 1:numLocals
    
    % 构造文件名
    fileName = sprintf('GNSNi_14min_20241025_R%d.ctf', iLocal);
    filePath = fullfile(inputDir, fileName);

    % 读取 EBSD 数据
    ebsd = EBSD.load(filePath,cs,'interface','ctf','convertEuler2SpatialReferenceFrame');

    % 晶粒识别与边界平滑：（识别最小的取向差，平滑度数，最小晶粒点数）
    [grains, ebsd] = identifyAndSmoothGrains(ebsd,2.0 * degree,10,3.0);

    % 绘制 IPF 图
    figure(iLocal);
    plotIPFMap(iLocal, ebsd, grains);

end

% 脚本路径: H:\Github\MyRhinoLab\scripts\p23-GNSNi-AGG-2024\20250409_14min_EBSD\step01_plot_initial_ipf_map_GNSNi_14min.m