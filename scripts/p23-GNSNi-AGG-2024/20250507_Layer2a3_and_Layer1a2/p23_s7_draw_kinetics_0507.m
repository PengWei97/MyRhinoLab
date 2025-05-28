% 清理环境
close all; clear; clc;

% Define directory and file information
inputDir1 = 'H:\Github\MyRhinoLabData\p23_GNSNi_AGG_2024\experiment2\PF_Initial\csv_kinetic\';
inputDir2 = 'H:\Github\MyRhinoLabData\p23_GNSNi_AGG_2024\simulation2\csv_kinetic\';
baseName = {'35p_Layer2a3_f0p5', 'c1_Layer2a3_f0p5'};
simuBaseNames = {'bk2_c7_t4','bk2_c7_t2','bk2_c7_t3','bk2_c8_t1'};
timePoints = [5.0, 10.0, 20.0, 30.0];  % 时间点（分钟）

legendNames = {'Exp', 'Simu\_t4', 'Simu\_t2', 'Simu\_t3', 'Simu\_c8t2'};

% 创建 VisualizationParams 类的实例
visParams = VisualizationParams();
visParams.fontSizeLabelTitle = 22;
visParams.height = 10;
visParams.width = 15;

iBaseName = 1;
iRegionType = iBaseName;
fileName = fullfile(inputDir1, sprintf('GNSNi_%s_kinetic.csv', baseName{iBaseName}));
inputData = readtable(fileName);

% 绘制误差棒图（加权平均晶粒半径）
initPlot(1, visParams); % Initialize the plot
errorbar(inputData.Time, inputData.weightGrainRadius.*2, sqrt(inputData.StdRadius), ...
      'Color', visParams.colors{iRegionType}, ...
      'LineStyle', visParams.lineStyles{iRegionType}, ...
      'LineWidth', visParams.lineWidth, ...
      'Marker',visParams.markers{iRegionType},...
      'MarkerSize', visParams.markerSize, ...
      'MarkerFaceColor', visParams.colors{iRegionType},...
      'DisplayName', legendNames{iRegionType});

% final
for iSimu = 1:length(legendNames)-1
  fileName = fullfile(inputDir2, sprintf('GNSNi_kinetic_%s.csv', simuBaseNames{iSimu}));
  inputData = readtable(fileName);

  x = inputData.Time./60 + 10;
  y = inputData.WeightedMeanRadius*2;

  plot(x(y>0), y(y>0), 'Color', visParams.colors{iSimu+1}, ...
    'LineWidth', visParams.lineWidth, 'LineStyle', visParams.lineStyles{iSimu+1}, ...
    'DisplayName', legendNames{iSimu+1});  
end

xlim([0,45]);
% ylim([0 150])
titles = {'Time (min)', 'Average diameter (\mum)'};
finalizePlot(visParams, titles);
% set(gca,'xaxislocation','top');
% legend off
fprintf('图表绘制完成。\n');

% H:\Github\MyRhinoLab\scripts\p23-GNSNi-AGG-2024\20250507_Layer2a3_and_Layer1a2\p23_s7_draw_kinetics_0507.m