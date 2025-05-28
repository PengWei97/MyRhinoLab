%% 脚本说明
% 创建时间：2024年4月20日
% 创建人：Pengwei
% 脚本功能：
% 1. 批量读取 GNS-Ni EBSD 原始 CTF 数据；
% 2. 对数据进行晶粒识别、填充、降噪和平滑处理；
% 3. 输出处理后的新 CTF 文件；
% 4. 绘制平滑处理后的 IPF 图；
%
% 适用实验数据：广州QIS实验，时间点包括 5min、10min、20min、30min。

close all;
clear;
clc;

%% 设置晶体对称性
crystalSymmetryList = { ...
    'notIndexed', ...
    crystalSymmetry('m-3m', [3.6 3.6 3.6], ...
    'mineral', 'Ni-superalloy', ...
    'color', [0.53 0.81 0.98])};

% 设置绘图坐标轴方向
setMTEXpref('xAxisDirection', 'west');
setMTEXpref('zAxisDirection', 'outOfPlane');

%% 设置路径与参数
inputDir = 'H:\Github\MyRhinoLabData\p23_GNSNi_AGG_2024\experiment2\14min_EBSD\a_ctf_initial\';
outputDir = 'H:\Github\MyRhinoLabData\p23_GNSNi_AGG_2024\experiment2\14min_EBSD\b_ctf_excerpt\';
if ~exist(outputDir, 'dir'), mkdir(outputDir); end

numLocals = 8;
numFiguresPerTime = 2;  % 每个时间点绘图数

%% 主循环：依次处理每个时间点的数据
for iLocal = 1:numLocals
    sprintf('GNSNi_14min_20241025_R%d.ctf', iLocal);
    % 构建输入文件路径
    inputFile = fullfile(inputDir, sprintf('GNSNi_14min_20241025_R%d.ctf', iLocal));

    %% Step 1: 读取EBSD数据
    ebsd = EBSD.load(inputFile, crystalSymmetryList, ...
                     'interface', 'ctf', ...
                     'convertEuler2SpatialReferenceFrame');

    %% Step 2: 初始晶粒识别和平滑
    [grains, ebsd] = identifyAndSmoothGrains(ebsd, 2.0 * degree, 10, 3.0);

    %% Step 3: 网格细化与迭代降噪
    ebsdRefined = transformMesh(ebsd, 3.0);  % 放大至3倍网格精度
    
    alphaVals = [0.0, 0.0];  % 填充强度参数
    for jFill = 1:length(alphaVals)
        [grainsRefined, ebsdRefined] = identifyAndSmoothGrains(ebsdRefined, ...
                                                2.0 * degree, 60, 20.0);
        
        % 应用半二次滤波器进行数据平滑填充
        hqFilter = halfQuadraticFilter;
        hqFilter.alpha = alphaVals(jFill);
        ebsdRefined = smooth(ebsdRefined, hqFilter, 'fill', grainsRefined);

        % 移除未识别区域（未索引）
        ebsdRefined = ebsdRefined('indexed');
    end

    %% Step 4: 最终晶粒识别 + 网格粗化
    [grainsRefined, ebsdRefined] = identifyAndSmoothGrains(ebsdRefined, ...
                                            2.0 * degree, 60, 20.0);
    
    ebsdRefined = transformMesh(ebsdRefined, 2.0);  % 网格粗化回原始尺寸

    %% Step 5: 绘制最终 IPF 图
    figId = numFiguresPerTime * (iLocal - 1) + 2;
    plotIPFMap(figId, ebsdRefined, grainsRefined);

    %% Step 6: 导出处理后的 CTF 文件
    outputFile = fullfile(outputDir, ...
                    sprintf('GNSNi_14min_20241025_R%d.ctf', iLocal));
    export_ctf(ebsdRefined, outputFile);
end

%% [可选] 后处理：计算平均晶粒尺寸（暂未启用）
%{
[xmin, xmax, ymin, ymax] = ebsdRefined.extend();
totalArea = (xmax - xmin) * (ymax - ymin);
pixelCount = sum(grainsRefined.grainSize);
grainAreas = grainsRefined.grainSize .* totalArea .* pixelCount;
grainRadii = sqrt(grainAreas ./ pi);
averageGrainRadius = sum(grainRadii .* grainAreas) / totalArea;
%}

%% [可选] 合并EBSD data
% {
  xtd_l=ebsd_l.extend;
  ebsd_r2=shift(ebsd_r,[xtd_l(2)-11,-12]);
  ebsd_r2_new=ebsd_r2(ebsd_r2.prop.x>=xtd_l(2));
  ebsd_new=[ebsd_l, ebsd_r2_new];
% }

% 脚本路径: H:\Github\MyRhinoLab\demo\mtex_EBSD_GG\postprocess\step1_plot_ipf_map_from_raw.m