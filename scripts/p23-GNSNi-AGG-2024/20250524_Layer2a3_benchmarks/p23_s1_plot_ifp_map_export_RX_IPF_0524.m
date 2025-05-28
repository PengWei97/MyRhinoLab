%% 脚本说明

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
dataPath = 'H:\Github\MyRhinoLabData\p23_GNSNi_AGG_2024\experiment\ctf_excpert\';
outputDataPath = 'H:\Github\MyRhinoLabData\p23_GNSNi_AGG_2024\experiment2\PF_Initial\Layer2a3_bk_t2\ctf_excerpt\';
outputDataPath2 = 'H:\Github\MyRhinoLabData\p23_GNSNi_AGG_2024\experiment2\PF_Initial\Layer2a3_bk_t2\csv_kinetic\';
outputDataPath3 = 'H:\Github\MyRhinoLabData\p23_GNSNi_AGG_2024\experiment2\PF_Initial\Layer2a3_bk_t2\png_IPF\';

if ~exist(outputDataPath, 'dir'), mkdir(outputDataPath); end
if ~exist(outputDataPath2, 'dir'), mkdir(outputDataPath2); end
if ~exist(outputDataPath3, 'dir'), mkdir(outputDataPath3); end

timePoints = [5.0, 10.0, 20.0, 30.0];  % 时间点（分钟）
numTypeFigures = 2;  % 每个时间点绘制的图像数量
baseName = 'Layer2a3';

% RegionPointCoord = [750,266,920,424; 572,207,780,410; 495,272,606,395; ...
%                     265,215,544,395; 93,285,238,447];

RegionPointCoord = [751, 266, 919, 481; 574, 207, 815, 542; 497, 273, 609, 394; ...
                    267, 215, 545, 542; 58, 287, 246, 517];
% GG kinetic
outputTabeGGKinetic = table;
outputTabeGGKinetic.Time = timePoints';
numTime = length(timePoints);
outputTabeGGKinetic.weightGrainRadius = zeros(numTime,1);
outputTabeGGKinetic.StdRadius = zeros(numTime,1);

for iTime = 3:3
  for iRegion = 5:5
    % 循环处理每个时间点的数据
    % 文件路径
    inputFile = fullfile(dataPath, sprintf('GNSNi_%dmin_excerpt.ctf', timePoints(iTime)));

    %% 导入数据
    ebsdData = EBSD.load(inputFile, crystalSymmetry, 'interface', 'ctf', ...
                          'convertEuler2SpatialReferenceFrame');

    % 标识和平滑晶粒
    xCoord = RegionPointCoord(iRegion,1);
    yCoord = RegionPointCoord(iRegion,2);
    xSize = RegionPointCoord(iRegion,3) - RegionPointCoord(iRegion,1);
    ySize = RegionPointCoord(iRegion,4) - RegionPointCoord(iRegion,2);
    ebsdDataLayerX = ebsdData(inpolygon(ebsdData,[xCoord,yCoord,xSize,ySize])); % for Layer 2 and 3 

    % idFigure = numTypeFigures*(iRegion - 1)+1;
    % figure(idFigure)
    % plot(ebsdDataLayerX, ebsdDataLayerX.orientations, 'coordinates', 'off', 'micronbar', 'off');

    [grains, ebsdDataLayerX] = identifyAndSmoothGrains(ebsdDataLayerX, 2.0 * degree, 50, 3.0);

    idFigure = numTypeFigures*(iRegion - 1)+1;
    figure(idFigure)
    plot(grains, grains.meanOrientation, 'coordinates', 'off', 'micronbar', 'off');   
    hold on
    plot(grains.boundary,'linewidth',0.8)
    hold off 
    outputFile = fullfile(outputDataPath3, sprintf('GNSNi_%dmin_%s_R%d.png', timePoints(iTime), baseName, iRegion));
    print(gcf, outputFile, '-dpng', '-r1200');     

    %% get grain kinetic
    % 计算区域尺寸并转换面积单位
    [xmin, xmax, ymin, ymax] = ebsdDataLayerX.extend();
    pixel2Area = (xmax - xmin) * (ymax - ymin) / length(ebsdDataLayerX);

    % 仅选择 'Ni-superalloy' 相关的晶粒
    grainID = grains('Ni-superalloy').id;
    grainArea = grains(grainID).grainSize.*pixel2Area;
    grainRadius = sqrt(grainArea./pi);
    outputTabeGGKinetic.weightGrainRadius(iTime,1) = sum(grainArea.*grainRadius)/sum(grainArea);   

    % 计算加权标准偏差
    variance = sum(grainArea .* (grainRadius - outputTabeGGKinetic.weightGrainRadius(iTime,1)).^2) / sum(grainArea);
    outputTabeGGKinetic.StdRadius(iTime,1) = sqrt(variance);
    
    ebsdToRefine = transformMesh(ebsdDataLayerX, 0.5);  % 变换网格 2
    
    outputFile = fullfile(outputDataPath, sprintf('GNSNi_%dmin_%s_R%d.ctf', timePoints(iTime), baseName, iRegion)); % scaleFactor ~ 0.5
    export_ctf(ebsdToRefine, outputFile);  % 导出处理后的CTF文件
  end
  %% 输出 GG kinetic
  outputFileKinetics = fullfile(outputDataPath2, sprintf('GNSNi_%dmin_%s_kinetic.csv', baseName, baseName));
  writetable(outputTabeGGKinetic, outputFileKinetics);
end

% H:\Github\MyRhinoLab\scripts\p23-GNSNi-AGG-2024\20250524_Layer2a3_benchmarks\p23_s1_plot_ifp_map_export_RX_IPF_0524.m


