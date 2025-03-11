%% 脚本说明
% 创建时间：2024年4月20日
% 创建人：Pengwei
% 创建目的：该脚本用于加载经过降噪处理的EBSD数据，进行晶粒识别和平滑处理，并绘制IPF（Inverse Pole Figure）图。
% 该脚本适用于GNS-Ni合金的EBSD数据分析，时间点为10min、20min和30min的CTF数据。

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

% %% 指定文件路径和时间点 - 1
% dataPath = 'H:\Github\MyRhinoLabData\p23_GNSNi_AGG_2024\ebsd\a0_GNSNi_QIS_EBSD_guangzhou\ctf_excerpt\';
% timePoints = [5.0, 10.0, 20.0, 30.0];  % 时间点（分钟）

%% 指定文件路径 - 2
dataPath = 'H:\Github\MyRhinoLabData\p23_GNSNi_AGG_2024\ebsd\USRP5_17min_20250302\ctf_excerpt\';

% 循环处理每个时间点的数据
for iTime = 3:3 %length(timePoints)  % 从第2个时间点开始处理（跳过5min）
    % 构造输入文件路径
    % inputFile = fullfile(dataPath, sprintf('GNSNi_%dmin_Layer%d_denoising.ctf', timePoints(iTime), iTime)); % 1
    inputFile = fullfile(dataPath, sprintf('S1_20250302_USPR5_17min_R%d_excerpt.ctf', iTime)); % 2
    
    %% 导入数据
    ebsdData = EBSD.load(inputFile, crystalSymmetry, 'interface', 'ctf', ...
                         'convertEuler2SpatialReferenceFrame');

    % 标识和平滑晶粒
    % [xmin, xmax, ~, ~] = ebsdData.extend();
    % ebsdData = ebsdData(inpolygon(ebsdData, [0,0,100,100]));
    [grains, ebsdData] = identifyAndSmoothGrains(ebsdData, 2.0 * degree, 10, 3.0);
    
    % 绘制IPF图（根据时间点进行编号）
    idFigure = iTime;  
    plotIPFMap(idFigure, ebsdData, grains);

    % 绘制IPF图（根据时间点进行编号）
    idFigure = iTime;  
    figure(idFigure) % meanOrientation + grain id + arrow
    plot(grains, grains.meanOrientation, 'micronbar','off', 'coordinates','off');
    hold on 
    bigGrains = grains(grains.grainSize>500); % (grainsLocal.grainSize>1000)
    dir = bigGrains.meanOrientation * Miller(1,0,0,bigGrains.CS);
    len = 0.5.*bigGrains.diameter;
  
    quiver(bigGrains,len.*dir,'autoScale','off','color','white');
    text(bigGrains,int2str(bigGrains.id),'color','black');
    hold on    
end


% 脚本路径: H:\Github\MyRhinoLab\scripts\p23-GNSNi-AGG-2024\0-experients\p23_exp2_ipf_map.m
