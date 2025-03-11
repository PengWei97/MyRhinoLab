%% 脚本说明
% 创建时间：2024年4月20日
% 创建人：Pengwei
% 创建目的：该脚本用于加载经过降噪处理的EBSD数据，计算晶粒的几何必要位错（GND），并将结果导出为CTF和ANG格式文件，供MOOSE-PF模拟和Dream3D分析使用。
% 该脚本适用于GNS-Ni合金的EBSD数据分析，时间点包括5min、10min、20min和30min。

%% 代码开始
close all;
clear;
clc;

% 定义晶体对称性
crystalSymmetry = {...
  'notIndexed',... 
  crystalSymmetry('m-3m', [3.6 3.6 3.6], 'mineral', 'Ni-superalloy', 'color', [0.53 0.81 0.98])};

% 设置绘图坐标轴方向
setMTEXpref('xAxisDirection', 'west');
setMTEXpref('zAxisDirection', 'outOfPlane');

%% 指定文件路径和时间点
dataPath = 'H:\Github\MyRhinoLabData\p23_GNSNi_AGG_2024\ebsd\USRP5_17min_20250302\ctf_excerpt\';
outputDataPath1 = 'H:\Github\MyRhinoLabData\p23_GNSNi_AGG_2024\ebsd\USRP5_17min_20250302\ctf_excerpt_with_rho\';
outputDataPath2 = 'H:\Github\MyRhinoLabData\p23_GNSNi_AGG_2024\ebsd\USRP5_17min_20250302\ang_excerpt\';

numTypeFigures = 2;  % 每个时间点绘制的图像数量
numRegions = 8;

% openFile 
rhoData = zeros(numRegions, 3);

for iRegion = 3:3 % numRegions    
    % 构造输入文件路径 - 1
    inputFile = fullfile(dataPath, sprintf('S1_20250302_USPR5_17min_R%d_excerpt.ctf', iRegion));

    %% 导入EBSD数据
    ebsdData = EBSD.load(inputFile, crystalSymmetry, 'interface', 'ctf', ...
                         'convertEuler2SpatialReferenceFrame');
    
    % 对数据进行晶粒识别和平滑处理
    [xmin, xmax, ymin, ymax] = ebsdData.extend;
    ebsdData = ebsdData(inpolygon(ebsdData, [500, 0, xmax-500, ymax-ymin])); % xmax-xmin
    ebsdData = transformMesh(ebsdData, 1.0);  % 变换网格 2
    [grains, ebsdData] = identifyAndSmoothGrains(ebsdData, 2.0 * degree, 10, 3.0);

    % 绘制IPF图（逆极图）
    idFigure = numTypeFigures * (iRegion - 1) + 1;
    plotIPFMap(idFigure, ebsdData, grains);

    %% 计算GND（几何必要位错）图
    ebsdGrid = ebsdData('indexed').gridify;
    rho = calculatedFCCGNDs(ebsdGrid);
    
    % 绘制GND图
    idFigure = numTypeFigures * (iRegion - 1) + 2;
    plotGNDsMap(idFigure, ebsdGrid, grains, rho);

    %% 导出数据
    % Step 1: 导出包含rho信息的CTF格式文件
    outputFile = fullfile(outputDataPath1, sprintf('S1_20250302_USPR5_17min_R%d_excerpt_with_rho_bm2.ctf', iRegion)); % dmin_benchmark2_denoising 
    export_ctf(ebsdGrid, rho, outputFile); 

    % Step 2: 导出ANG格式文件供Dream3D使用
    outputFile = fullfile(outputDataPath2, sprintf('S1_20250302_USPR5_17min_R%d_excerpt_bm2.ang', iRegion)); % 
    export_ang(ebsdGrid, outputFile);

    rhoData(iRegion, :) = [iRegion, max(rho), min(rho)];
end

% 创建表格
T = array2table(rhoData, 'VariableNames', {'RegionId', 'max_rho', 'min_rho'});

% 保存 CSV 文件
outputFile = fullfile(outputDataPath1, 'rho_limit.csv');
writetable(T, outputFile);
% 输出成功信息
disp(['数据已成功保存到 ', outputFile]);

% 脚本路径: H:\Github\MyRhinoLab\scripts\p23-GNSNi-AGG-2024\0b-experiments-17min-USRP5\p23_0b_exp3_GND_map_and_ctf2INL_step1.m