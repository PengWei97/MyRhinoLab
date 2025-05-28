close all
clear
clc

data30min = [0.32514,0.47213,0.2027]; % A,B
data30min2 = [0.48864,0.37785,0.1335];
data10min = [0.48864,0.37785,0.1335];
data120min = [0.65326,0.24491,0.1018];

%% 可视化参数
% 创建 VisualizationParams 类的实例
visParams = VisualizationParams2();
% % visParams.height = 6.8;
% visParams.height = 12.1;
% visParams.width = 10.65;
% visParams.fontSizeLegend = 16;
legendName = {'Red Grain', 'Green Grain', 'others'};

initPlot(1, visParams); % Initialize the plot
x = [30,60,90,120];
iRegionType = 1;
initPlot(1, visParams); % Initialize the plot
for iRegion = 1:3
  y(1) =  data30min(iRegion);
  y(4) =  data120min(iRegion);
  y(2) =  data30min2(iRegion);
  y(3) =  data10min(iRegion);

  plot(x, y.*100, 'Color', visParams.colors{iRegion}, ...
    'LineWidth', visParams.lineWidth, 'LineStyle', visParams.lineStyles{iRegion}, ...
    'DisplayName', legendName{iRegion},...
    'Marker',visParams.markers{iRegion},...
    'MarkerSize', visParams.markerSize, ...
    'MarkerFaceColor', visParams.colors{iRegion},...
    'DisplayName', legendName{iRegion});

end

xlim([25,125]);
% ylim([0.2, 1.2].*100);
titles = {'Time (min)', 'Area Fraction (%)'};
finalizePlot(visParams, titles);

% H:\Github\MyRhinoLab\scripts\prm9-cooperate\p91-MgAlloy-SelectGG-2025\p91_s5_plot_kinetics_Areafraction.m