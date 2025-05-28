close all
clear
clc

% ===================== 数据初始化 =====================
data = {
    [6.8292,3.0142; 16.712,7.0039; 38.8324,16.4147;  53.984,22.921],        % Global Grain
    [7.5493,3.2974; 17.442,7.6151; 40.741,16.7737; 55.1184,22.9785],      % Red Grain
    [6.4595,2.6429; 15.7919,6.3188; 36.1638,16.0316; 51.5305,23.1888],      % Green Grain
    [6.5336,3.1404; 16.6433,6.148; 33.5653,12.2155; 52.6075,21.3096]       % Other Grain
};

legendNames = {'Global Grain', 'Red Grain', 'Green Grain', 'Others'};
x = [30;60;90;120];

% ===================== 可视化参数 =====================
visParams = VisualizationParams();
initPlot(1, visParams); % 初始化绘图

% ===================== 绘图循环 =====================
for i = 1:length(data)
    errorbar(x, data{i}(:,1).*2, data{i}(:,2), ...
        'Color', visParams.colors{i}, ...
        'LineStyle', visParams.lineStyles{i}, ...
        'LineWidth', visParams.lineWidth, ...
        'Marker', visParams.markers{i}, ...
        'MarkerSize', visParams.markerSize, ...
        'MarkerFaceColor', visParams.colors{i}, ...
        'DisplayName', legendNames{i});
    hold on
end

% ===================== 轴和标题设置 =====================
xlim([25,125]);
titles = {'Time (min)', 'Average diameter (\mum)'};
finalizePlot(visParams, titles);

% H:\Github\MyRhinoLab\scripts\prm9-cooperate\p91-MgAlloy-SelectGG-2025\p91_s4_plot_kinetics.m