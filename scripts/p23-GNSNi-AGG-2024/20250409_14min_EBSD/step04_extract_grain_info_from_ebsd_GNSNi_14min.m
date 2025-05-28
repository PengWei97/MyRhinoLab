%% 脚本说明
% 创建时间：2024年4月20日
% 创建人：Pengwei
% 创建目的：该脚本用于处理并分析EBSD数据，具体功能包括：计算晶粒结构 + 各类统计信息
% 1. 各自的IPF map，GB map以及GB type map，
% 2. 晶粒数据信息（包括Grain ID，欧拉角，以及晶粒面积），
% 3. 计算输出每个区域中每个时间的平均晶粒半径以及残差，计算输出每个区域中每个时间取向差分布，晶界类型长度

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
inputDir = 'H:\Github\MyRhinoLabData\p23_GNSNi_AGG_2024\experiment2\14min_EBSD\b_ctf_figs\';
outputDir1 = 'H:\Github\MyRhinoLabData\p23_GNSNi_AGG_2024\experiment2\14min_EBSD\c_png_IPF\';
outputDir2 = 'H:\Github\MyRhinoLabData\p23_GNSNi_AGG_2024\experiment2\14min_EBSD\d_bmp_gb\';
outputDir3 = 'H:\Github\MyRhinoLabData\p23_GNSNi_AGG_2024\experiment2\14min_EBSD\e_png_gb\';
outputDir4 = 'H:\Github\MyRhinoLabData\p23_GNSNi_AGG_2024\experiment2\14min_EBSD\f_csv_statistic\';
outputDir5 = 'H:\Github\MyRhinoLabData\p23_GNSNi_AGG_2024\experiment2\14min_EBSD\g_csv_misori\';
outputDir6 = 'H:\Github\MyRhinoLabData\p23_GNSNi_AGG_2024\experiment2\14min_EBSD\h_csv_kinetic\';
outputDir7 = 'H:\Github\MyRhinoLabData\p23_GNSNi_AGG_2024\experiment2\14min_EBSD\i_csv_gb_kinetic\';

if ~exist(outputDir1, 'dir'), mkdir(outputDir1); end
if ~exist(outputDir2, 'dir'), mkdir(outputDir2); end
if ~exist(outputDir3, 'dir'), mkdir(outputDir3); end
if ~exist(outputDir4, 'dir'), mkdir(outputDir4); end
if ~exist(outputDir5, 'dir'), mkdir(outputDir5); end
if ~exist(outputDir6, 'dir'), mkdir(outputDir6); end
if ~exist(outputDir7, 'dir'), mkdir(outputDir7); end

Locals = linspace(14,14,4);
numLocals = length(Locals);

numTypeFigures = 2;  % 每个时间点绘制的图像数量

regionType = {'global', 'Layer1', 'Layer2'};

% 循环处理每个时间点的数据
for iRegionType = 2:length(regionType)
  close all

  % GB type length
  gB_length = zeros(numLocals, 1);
  lAGB_length = zeros(numLocals, 1);
  HAGB_length = zeros(numLocals, 1);
  gB3_length = zeros(numLocals, 1);
  gB5_length = zeros(numLocals, 1);
  gB7_length = zeros(numLocals, 1);
  gB9_length = zeros(numLocals, 1);
  gB11_length = zeros(numLocals, 1);
  gB15_length = zeros(numLocals, 1);

  % GG kinetic
  outputTabeGGKinetic = table;
  outputTabeGGKinetic.Time = Locals';
  outputTabeGGKinetic.weightGrainRadius = zeros(numLocals,1);
  outputTabeGGKinetic.StdRadius = zeros(numLocals,1);

  for iLocal = 1:numLocals
    clear ebsdData ebsdToRefine grainsToRefine
    % 文件路径
    inputFile = fullfile(inputDir, sprintf('GNSNi_14min_R%d_%s.ctf', iLocal, regionType{iRegionType}));

    %% 导入数据
    ebsdData = EBSD.load(inputFile, crystalSymmetry, 'interface', 'ctf', ...
                          'convertEuler2SpatialReferenceFrame');

    ebsdToRefine = ebsdData;  % 变换网格
    [grainsToRefine, ebsdToRefine] = identifyAndSmoothGrains(ebsdToRefine, 2.0 * degree, 60, 20.0);
    gB = grainsToRefine.boundary;
    gB_NiNi = gB('Ni-superalloy', 'Ni-superalloy');

    %% IPF map
    figure(numTypeFigures*(iLocal-1)+1)
    plot(ebsdToRefine, ebsdToRefine.orientations, 'coordinates', 'off', 'micronbar', 'off');
    hold on
    plot(grainsToRefine.boundary, 'linewidth', 0.8);
    hold off;
    outputFile = fullfile(outputDir1, sprintf('GNSNi_14min_R%d_%s_IPF.png', iLocal, regionType{iRegionType}));
    print(gcf, outputFile, '-dpng', '-r1200');

    %% GB map
    figure(numTypeFigures*(iLocal-1)+2)
    plot(gB_NiNi,'linewidth',0.5,'linecolor','Black', 'micronbar', 'off')
    outputFile = fullfile(outputDir2, sprintf('GNSNi_14min_R%d_%s_gb.bmp', iLocal, regionType{iRegionType}));
    print(gcf, outputFile, '-dbmp', '-r1200');

    %% GB type
    deltaMisor = 5 * degree;
    gB = grainsToRefine.boundary('Ni-superalloy', 'Ni-superalloy');  % All boundaries
    lAGB = gB(angle(gB.misorientation) < 15.0 * degree);     % Low-angle GBs (< 15°)
    hAGB = gB(angle(gB.misorientation) >= 15.0 * degree);    % High-angle GBs (≥ 15°)
    gB3 = gB(gB.isTwinning(CSL(3, ebsdData.CS), deltaMisor)); % CSL Σ3 (twin boundaries)
    gB5 = gB(gB.isTwinning(CSL(5, ebsdData.CS), deltaMisor)); % CSL Σ5
    gB7 = gB(gB.isTwinning(CSL(7, ebsdData.CS), deltaMisor)); % CSL Σ7
    gB9 = gB(gB.isTwinning(CSL(9, ebsdData.CS), deltaMisor)); % CSL Σ9    
    gB11 = gB(gB.isTwinning(CSL(11, ebsdData.CS), deltaMisor)); % CSL Σ11
    gB15 = gB(gB.isTwinning(CSL(15, ebsdData.CS), deltaMisor)); % CSL Σ15

    % Plot grain boundaries for the current time point
    figure(numTypeFigures*(iLocal-1)+3)
    plot(hAGB, 'lineColor', 'black', 'linewidth', 2.0, 'micronbar', 'off'); % High-angle GBs
    hold on
    plot(lAGB, 'lineColor', 'Indigo', 'linewidth', 2.5, 'micronbar', 'off'); % Low-angle GBs
    plot(gB3, 'lineColor', 'red', 'linewidth', 3.0, 'DisplayName', 'CSL 3'); % Σ3 Twin boundaries gold
    plot(gB9, 'lineColor', 'blue', 'linewidth', 2, 'DisplayName', 'CSL 9');
    outputFile = fullfile(outputDir3, sprintf('GNSNi_14min_R%d_%s_gb_type.png', iLocal, regionType{iRegionType}));
    print(gcf, outputFile, '-dpng', '-r1200');

    %% GB length
    gB_length(iLocal) = sum(segLength(gB));
    lAGB_length(iLocal) = sum(segLength(lAGB));
    HAGB_length(iLocal) = sum(segLength(hAGB));
    gB3_length(iLocal) = sum(segLength(gB3));
    gB5_length(iLocal) = sum(segLength(gB5));
    gB7_length(iLocal) = sum(segLength(gB7));
    gB9_length(iLocal) = sum(segLength(gB9));
    gB11_length(iLocal) = sum(segLength(gB11));
    gB15_length(iLocal) = sum(segLength(gB15));

    %% get grain statistic
    % 计算区域尺寸并转换面积单位
    [xmin, xmax, ymin, ymax] = ebsdToRefine.extend();
    pixel2Area = (xmax - xmin) * (ymax - ymin) / length(ebsdToRefine);

    % 仅选择 'Ni-superalloy' 相关的晶粒
    grainID = grainsToRefine('Ni-superalloy').id;
    numGrains = length(grainID);
    phi1 = grainsToRefine(grainID).meanOrientation.phi1./degree;
    Phi = grainsToRefine(grainID).meanOrientation.Phi./degree;
    phi2 = grainsToRefine(grainID).meanOrientation.phi2./degree;
    grainSize = grainsToRefine(grainID).grainSize.*pixel2Area;

    % 4. 创建表格并保存
    GrainData = [grainID, phi1, Phi, phi2, grainSize];
    T = array2table(GrainData, 'VariableNames', {'grainID', 'phi1', 'Phi', 'phi2', 'grainSize'});   
    outputFile = fullfile(outputDir4, sprintf('GNSNi_14min_R%d_%s_grain_data.csv', iLocal, regionType{iRegionType}));   
    writetable(T, outputFile);

    % 5. 获取晶粒尺寸分布 GSD
    [tempGSD, edges] = createGrainSizeDistribution(31, 3.0); % 2.5 for stage 1; 2-
    [tempGSD.numFraction, tempGSD.areaFraction, aveGrainRadius, bigGrainIDs] = getGrainSizeDistribution(grainSize, edges, grainID);
    tempGSD.grainRadius = tempGSD.xSegm.*aveGrainRadius;
  
    outputFileGSD = fullfile(outputDir4, sprintf('GNSNi_14min_R%d_%s_GSD.csv', iLocal, regionType{iRegionType}));
    writetable(tempGSD, outputFileGSD);    

    %% get grain kinetic
    grainArea = grainSize;
    grainRadius = sqrt(grainArea./pi);
    outputTabeGGKinetic.weightGrainRadius(iLocal,1) = sum(grainArea.*grainRadius)/sum(grainArea);    
    % 计算加权标准偏差
    variance = sum(grainArea .* (grainRadius - outputTabeGGKinetic.weightGrainRadius(iLocal,1)).^2) / sum(grainArea);
    outputTabeGGKinetic.StdRadius(iLocal,1) = sqrt(variance);

    %% 取向差分布 cvs data
    figure(3*(iLocal-1)+4)
    misoriData = plotAngleDistribution(gB.misorientation);
    ouputDataTableMisori = table;
    ouputDataTableMisori.misorientation = misoriData.XData';
    ouputDataTableMisori.y_frequency = misoriData.YData';
    outputDataFile = fullfile(outputDir5, sprintf("GNSNi_14min_R%d_%s_misori_distribution.csv", regionType{iRegionType}));
    writetable(ouputDataTableMisori,outputDataFile);
  end

  %% 输出 GG kinetic
  outputFileKinetics = fullfile(outputDir6, sprintf('GNSNi_QIS_%s_kinetic.csv', regionType{iRegionType}));
  writetable(outputTabeGGKinetic, outputFileKinetics);
  
  %% 输出 GB 类型长度的csv
  outputData2File = fullfile(outputDir7, sprintf('GNSNi_%s_gb_type_QIS.csv', regionType{iRegionType}));
  writetable(table(Locals', gB_length, lAGB_length, HAGB_length, gB3_length, gB5_length, gB7_length, gB9_length, gB11_length, gB15_length, ...
            'VariableNames', {'Time', 'GB', 'LAGB', 'HAGB', 'CSL3', 'CSL5', 'CSL7', 'CSL9', 'CSL11', 'CSL15'}), ...
              outputData2File);
  fprintf('数据集计算完成\n');
end
% H:\Github\MyRhinoLab\scripts\p23-GNSNi-AGG-2024\20250409_14min_EBSD\step04_extract_grain_info_from_ebsd_GNSNi_14min.m