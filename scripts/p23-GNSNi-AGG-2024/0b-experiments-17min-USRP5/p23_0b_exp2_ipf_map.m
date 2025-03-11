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

%% 指定文件路径 - 2
dataPath = 'H:\Github\MyRhinoLabData\p23_GNSNi_AGG_2024\ebsd\USRP5_17min_20250302\ctf_excerpt\';

for iRegion = 8:8

    inputFile = fullfile(dataPath, sprintf('S1_20250302_USPR5_17min_R%d_excerpt.ctf', iRegion));
    
    %% 导入数据
    ebsdData = EBSD.load(inputFile, crystalSymmetry, 'interface', 'ctf', ...
                         'convertEuler2SpatialReferenceFrame');

    % 标识和平滑晶粒
    % [xmin, xmax, ~, ~] = ebsdData.extend();
    % ebsdData = ebsdData(inpolygon(ebsdData, [0,0,100,100]));
    [grains, ebsdData] = identifyAndSmoothGrains(ebsdData, 2.0 * degree, 10, 3.0);
    
    % 绘制IPF图（根据时间点进行编号）
    idFigure = iRegion;  
    plotIPFMap(idFigure, ebsdData, grains);

    % 绘制IPF图（根据时间点进行编号）
    idFigure = iRegion;  
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

% 脚本路径: H:\Github\MyRhinoLab\scripts\p23-GNSNi-AGG-2024\0b-experiments-17min-USRP5\p23_0b_exp2_ipf_map.m
