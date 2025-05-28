% 清理环境
close all; clear; clc;

% Define directory and file information
inputDir = 'H:\Github\MyRhinoLabData\p23_GNSNi_AGG_2024\simulation2\csv_kinetic_bk0\';
baseName = {'Exp_Layer2', 'bk0_c3_t1','bk0_c7_t1'};

legendNames = {'Exp.', 'bk0\_c3\_t1', 'bk0\_c7\_t1', 'Simu\_t3', 'Simu\_c8t2'};

% 创建 VisualizationParams 类的实例
visParams = VisualizationParams();
visParams.fontSizeLabelTitle = 22;
visParams.height = 10;
visParams.width = 13;

iBaseName = 1;
iRegionType = iBaseName;

initPlot(1, visParams); % Initialize the plot
for iFile = 1:length(baseName)
%% 获取数据
fileName = fullfile(inputDir, sprintf('GNSNi_kinetic_%s.csv', baseName{iFile}));
inputData = readtable(fileName);

if iFile == 1
  x = inputData.Time.*60;
  y = inputData.WeightedMeanRadius.*2;
  % 绘制误差棒图（加权平均晶粒半径）
  errorbar(x, y, sqrt(inputData.StdRadius), ...
        'Color', visParams.colors{iFile}, ...
        'LineStyle', visParams.lineStyles{iFile}, ...
        'LineWidth', visParams.lineWidth, ...
        'Marker',visParams.markers{iFile},...
        'MarkerSize', visParams.markerSize, ...
        'MarkerFaceColor', visParams.colors{iFile},...
        'DisplayName', legendNames{iFile});
  continue;
end

  x = inputData.Time + 600;
  y = inputData.WeightedMeanRadius*2;

  plot(x(y>0), y(y>0), 'Color', visParams.colors{iFile}, ...
    'LineWidth', visParams.lineWidth, 'LineStyle', visParams.lineStyles{iFile}, ...
    'DisplayName', legendNames{iFile});  
end

xlim([200,1900]);
% ylim([0 150])
titles = {'Time (min)', 'Average diameter (\mum)'};
finalizePlot(visParams, titles);
% set(gca,'xaxislocation','top');
% legend off
fprintf('图表绘制完成。\n');

% H:\Github\MyRhinoLab\scripts\p23-GNSNi-AGG-2024\20250517_benchmark0_SimuParas\s2_draw_exp_simu_kinetics_for_Layer1_40p.m