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

% %% 指定文件路径和时间点 - 1
% dataPath = 'H:\Github\MyRhinoLabData\p23_GNSNi_AGG_2024\ebsd\a0_GNSNi_QIS_EBSD_guangzhou\ctf_excerpt\';
% outputDataPath1 = 'H:\Github\MyRhinoLabData\p23_GNSNi_AGG_2024\ebsd\a0_GNSNi_QIS_EBSD_guangzhou\ctf_excerpt_with_rho\';
% outputDataPath2 = 'H:\Github\MyRhinoLabData\p23_GNSNi_AGG_2024\ebsd\a0_GNSNi_QIS_EBSD_guangzhou\ang_excerpt\';

% timePoints = [5.0, 10.0, 20.0, 30.0];  % 时间点数组

%% 指定文件路径和时间点 - 2
dataPath = 'H:\Github\MyRhinoLabData\p23_GNSNi_AGG_2024\ebsd\USRP5_17min_20250302\ctf_excerpt\';
outputDataPath1 = 'H:\Github\MyRhinoLabData\p23_GNSNi_AGG_2024\ebsd\USRP5_17min_20250302\ctf_excerpt_with_rho\';
outputDataPath2 = 'H:\Github\MyRhinoLabData\p23_GNSNi_AGG_2024\ebsd\USRP5_17min_20250302\ang_excerpt\';

numTypeFigures = 2;  % 每个时间点绘制的图像数量

% openFile 
rho_max = zeros

for iTime = 3:3 % length(timePoints)
    % % 构造输入文件路径 - 1
    % inputFile = fullfile(dataPath, sprintf('GNSNi_%dmin_Level1_local2_denoising.ctf', timePoints(iTime)));
    
    % 构造输入文件路径 - 2
    inputFile = fullfile(dataPath, sprintf('S1_20250302_USPR5_17min_R%d_excerpt.ctf', iTime)); % 2

    %% 导入EBSD数据
    ebsdData = EBSD.load(inputFile, crystalSymmetry, 'interface', 'ctf', ...
                         'convertEuler2SpatialReferenceFrame');
    
    % 对数据进行晶粒识别和平滑处理
    [xmin, xmax, ~, ~] = ebsdData.extend;
    ebsdData = ebsdData(inpolygon(ebsdData, [0, 0, 100, 100])); % xmax-xmin
    [grains, ebsdData] = identifyAndSmoothGrains(ebsdData, 2.0 * degree, 10, 3.0);

    % 绘制IPF图（逆极图）
    idFigure = numTypeFigures * (iTime - 1) + 1;
    plotIPFMap(idFigure, ebsdData, grains);

    %% 计算GND（几何必要位错）图
    ebsdGrid = ebsdData('indexed').gridify;
    rho = calculatedFCCGNDs(ebsdGrid);
    
    % 绘制GND图
    idFigure = numTypeFigures * (iTime - 1) + 2;
    plotGNDsMap(idFigure, ebsdGrid, grains, rho);

    % %% 导出数据 - 1
    % % Step 1: 导出包含rho信息的CTF格式文件
    % outputFile = fullfile(outputDataPath1, sprintf('GNSNi_%dmin_Level1_local2_denoising_with_rho.ctf', timePoints(iTime))); % dmin_benchmark2_denoising 
    % export_ctf(ebsdGrid, rho, outputFile); 

    % % Step 2: 导出ANG格式文件供Dream3D使用
    % outputFile = fullfile(outputDataPath2, sprintf('GNSNi_%dmin_Level1_local2_denoising.ang', timePoints(iTime))); % 
    % export_ang(ebsdGrid, outputFile);

    %% 导出数据 - 2
    % Step 1: 导出包含rho信息的CTF格式文件
    outputFile = fullfile(outputDataPath1, sprintf('S1_20250302_USPR5_17min_R%d_excerpt_with_rho.ctf', iTime)); % dmin_benchmark2_denoising 
    export_ctf(ebsdGrid, rho, outputFile); 

    % Step 2: 导出ANG格式文件供Dream3D使用
    outputFile = fullfile(outputDataPath2, sprintf('S1_20250302_USPR5_17min_R%d_excerpt.ang', iTime)); % 
    export_ang(ebsdGrid, outputFile);

    disp(sprintf('Region %d: rho 的最大值 = %.4e, 最小值 = %.4e', iTime, max(rho), min(rho)));
end

% Region 3: rho 的最大值 = 6.4634e+14, 最小值 = 1.1647e-05



% 脚本路径: H:\Github\MyRhinoLab\scripts\p23-GNSNi-AGG-2024\0-experients\p23_exp3_GND_map_and_ctf2INL_step1.m
