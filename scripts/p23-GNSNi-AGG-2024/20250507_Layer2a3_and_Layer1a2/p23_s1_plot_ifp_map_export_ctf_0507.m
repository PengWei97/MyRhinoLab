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
outputDataPath = 'H:\Github\MyRhinoLabData\p23_GNSNi_AGG_2024\experiment2\PF_Initial\ctf_excerpt\';
outputDataPath2 = 'H:\Github\MyRhinoLabData\p23_GNSNi_AGG_2024\experiment2\PF_Initial\csv_kinetic\';

if ~exist(outputDataPath, 'dir'), mkdir(outputDataPath); end
if ~exist(outputDataPath2, 'dir'), mkdir(outputDataPath2); end

timePoints = [5.0, 10.0, 20.0, 30.0];  % 时间点（分钟）
numTypeFigures = 4;  % 每个时间点绘制的图像数量
baseName = {'Layer2a3_f0p5', '1f3_Layer2a3_f0p5', '35p_Layer2a3_f0p5', 'c1_Layer2a3_f0p5', 'Layer1_40p_f0p5', 'Layer2a3_29p_f0p5'};

% GG kinetic
outputTabeGGKinetic = table;
outputTabeGGKinetic.Time = timePoints';
numTime = length(timePoints);
outputTabeGGKinetic.weightGrainRadius = zeros(numTime,1);
outputTabeGGKinetic.StdRadius = zeros(numTime,1);

for iBaseName = 4:4 % length(baseName):length(baseName)
  % 循环处理每个时间点的数据
  for iTime = 2:2
    % 文件路径
    inputFile = fullfile(dataPath, sprintf('GNSNi_%dmin_excerpt.ctf', timePoints(iTime)));

    %% 导入数据
    ebsdData = EBSD.load(inputFile, crystalSymmetry, 'interface', 'ctf', ...
                          'convertEuler2SpatialReferenceFrame');

    % 标识和平滑晶粒
    [xmin, xmax, ymin, ymax] = ebsdData.extend();
    % ebsdDataLayerX = ebsdData;
    % ebsdDataLayerX = ebsdData(inpolygon(ebsdData, [xmin,ymin,330,260])); % for 1/3 Layer 1 and 2
    % ebsdDataLayerX = ebsdData(inpolygon(ebsdData, [xmin,160,330,530-160])); % for 1/3 Layer 2 and 3
    % ebsdDataLayerX = ebsdData(inpolygon(ebsdData, [250,160,330,600-250])); % for 35 percent Layer 2 and 3
    % ebsdDataLayerX = ebsdData(inpolygon(ebsdData, [xmin,150,xmax-xmin,600-150])); % for global Layer 2 and 3 in case 1
    % ebsdDataLayerX = ebsdData(inpolygon(ebsdData, [xmin,xmin,400,160])); % benchmark0 for get Hmob, Layer1_p40

    ebsdDataLayerX = ebsdData(inpolygon(ebsdData, [xmin,160,xmax-xmin,530-160])); % for Layer 2 and 3 
    % ebsdDataLayerX = ebsdData(inpolygon(ebsdData, [550,150,840-550,540-150])); % for global Layer 2 and 3 in case 2, 29p

    % idFigure = numTypeFigures*(iTime - 1)+1;
    % figure(idFigure)
    % plot(ebsdDataLayerX, ebsdDataLayerX.orientations, 'coordinates', 'off', 'micronbar', 'off');

    [grains, ebsdDataLayerX] = identifyAndSmoothGrains(ebsdDataLayerX, 2.0 * degree, 50, 3.0);

    idFigure = numTypeFigures*(iTime - 1)+1;
    figure(idFigure)
    plot(grains, grains.meanOrientation, 'coordinates', 'off', 'micronbar', 'off');   
    hold on
    plot(grains.boundary,'linewidth',0.8)
    hold off 
    
    % %% get grain kinetic
    % % 计算区域尺寸并转换面积单位
    % [xmin, xmax, ymin, ymax] = ebsdDataLayerX.extend();
    % pixel2Area = (xmax - xmin) * (ymax - ymin) / length(ebsdDataLayerX);

    % % 仅选择 'Ni-superalloy' 相关的晶粒
    % grainID = grains('Ni-superalloy').id;
    % grainArea = grains(grainID).grainSize.*pixel2Area;
    % grainRadius = sqrt(grainArea./pi);
    % outputTabeGGKinetic.weightGrainRadius(iTime,1) = sum(grainArea.*grainRadius)/sum(grainArea);    
    % % 计算加权标准偏差
    % variance = sum(grainArea .* (grainRadius - outputTabeGGKinetic.weightGrainRadius(iTime,1)).^2) / sum(grainArea);
    % outputTabeGGKinetic.StdRadius(iTime,1) = sqrt(variance);
    
    % ebsdToRefine = transformMesh(ebsdDataLayerX, 0.5);  % 变换网格 2
    
    % % outputFile = fullfile(outputDataPath, 'GNSNi_10min_1f3_Layer1a2_f0p5.ctf'); % scaleFactor ~ 0.5
    % outputFile = fullfile(outputDataPath, sprintf('GNSNi_%dmin_%s.ctf', timePoints(iTime), baseName{iBaseName})); % scaleFactor ~ 0.5
    % export_ctf(ebsdToRefine, outputFile);  % 导出处理后的CTF文件
  end
  % %% 输出 GG kinetic
  % outputFileKinetics = fullfile(outputDataPath2, sprintf('GNSNi_%s_kinetic.csv', baseName{iBaseName}));
  % writetable(outputTabeGGKinetic, outputFileKinetics);
end

% H:\Github\MyRhinoLab\scripts\p23-GNSNi-AGG-2024\20250507_Layer2a3_and_Layer1a2\p23_s1_plot_ifp_map_export_ctf_0507.m


