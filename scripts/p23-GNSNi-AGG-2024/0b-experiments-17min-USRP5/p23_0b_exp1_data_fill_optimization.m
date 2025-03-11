%% 脚本说明
% 创建时间：2024年4月20日
% 创建人：Pengwei
% 创建目的：该脚本用于处理并分析EBSD数据，具体功能包括：
% 1. 导入原始CTF格式的EBSD数据；
% 2. 进行晶粒的标识、平滑和填充操作；
% 3. 绘制IPF（Inverse Pole Figure）图，并根据平滑后的数据生成新的图；
% 4. 导出经过降噪处理后的CTF数据文件；
%
% 该脚本应用于GNS-Ni合金的EBSD数据分析，并在广州QIS-EBSD实验中使用，
% 时间点为5min、10min、20min和30min的CTF数据。

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
dataPath = 'H:\Github\MyRhinoLabData\p23_GNSNi_AGG_2024\ebsd\USRP5_17min_20250302\ctf_initial\';
outputDataPath = 'H:\Github\MyRhinoLabData\p23_GNSNi_AGG_2024\ebsd\USRP5_17min_20250302\ctf_excerpt\';

numTypeFigures = 2;  % 每个时间点绘制的图像数量

% 循环处理每个时间点的数据
for iTime = 2:8 % length(timePoints)
    % 文件路径
    % inputFile = fullfile(dataPath, sprintf('Ni_%dmin_excerpt.ctf', timePoints(iTime))); % 1
    inputFile = fullfile(dataPath, sprintf('S1-20250302-USPR5-R%d.ctf', iTime)); % 2 % R1 iTime - Region-X

    %% 导入数据
    ebsdData = EBSD.load(inputFile, crystalSymmetry, 'interface', 'ctf', ...
                         'convertEuler2SpatialReferenceFrame');

    % 标识并平滑晶粒
    [grains, ebsdData] = identifyAndSmoothGrains(ebsdData, 2.0 * degree, 10, 3.0);
    
    % 绘制IPF图
    idFigure = numTypeFigures * (iTime - 1) + 1;
    plotIPFMap(idFigure, ebsdData, grains);

    % break;
    %% 细化、填充，降噪等处理
    ebsdToRefine = transformMesh(ebsdData, 4.0);  % 变换网格

    % 迭代不同的平滑参数
    alphaValues = [0.0, 0.0];  % alpha值控制填充的强度
    for iFill = 1:length(alphaValues)
        % 标识并平滑晶粒
        [grainsToRefine, ebsdToRefine] = identifyAndSmoothGrains(ebsdToRefine, 2.0 * degree, 60, 60.0);
        
        % 使用二次滤波器进行平滑
        F = halfQuadraticFilter;
        F.alpha = alphaValues(iFill);
        ebsdToRefine = smooth(ebsdToRefine, F, 'fill', grainsToRefine);
        
        % 只保留已标记的晶粒
        ebsdToRefine = ebsdToRefine('indexed');
    end
    
    ebsdToRefine = transformMesh(ebsdToRefine, 2.0);  % 变换网格 2
    % 最终的平滑和晶粒识别
    [grainsToRefine, ebsdToRefine] = identifyAndSmoothGrains(ebsdToRefine, 2.0 * degree, 60, 0.0);
    
    % 绘制平滑后的IPF图
    idFigure = numTypeFigures * (iTime - 1) + 2;
    plotIPFMap(idFigure, ebsdToRefine, grainsToRefine);

    % %% 导出降噪后的CTF文件 - 1
    % outputFile = fullfile(outputDataPath, sprintf('GNSNi_%dmin_Layer%d_denoising.ctf', timePoints(iTime), iTime));
    % export_ctf(ebsdToRefine, outputFile);  % 导出处理后的CTF文件

    %% 导出降噪后的CTF文件 - 2
    outputFile = fullfile(outputDataPath, sprintf('S1_20250302_USPR5_17min_R%d_excerpt.ctf', iTime));
    export_ctf(ebsdToRefine, outputFile);  % 导出处理后的CTF文件

    % % calculate the average grain size
    % [xmin, xmax, ymin, ymax] = ebsdToRefine.extend();
    % totalGrainArea = [xmax-xmin]*[ymax-ymin];
    % totalPixelNum = sum(grainsToRefine.grainSize);
    % grainAreas = grainsToRefine.grainSize .* totalGrainArea ./ totalPixelNum;
    % GrainRadius = sqrt(grainAreas./pi);
    % AveGrainRaidus = sum(GrainRadius .* grainAreas) / totalGrainArea;
end

% 脚本路径: H:\Github\MyRhinoLab\scripts\p23-GNSNi-AGG-2024\0-experients\p23_exp1_data_fill_optimization.m
