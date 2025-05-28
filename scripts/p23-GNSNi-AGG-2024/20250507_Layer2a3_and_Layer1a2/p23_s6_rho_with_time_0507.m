%% ============================ 清理环境 ============================
close all; clear; clc;

%% ============================ 数据准备 ============================
% 实验数据 (时间步长, 浓度, 误差)
rhoData = [5, 2.8158e+13, 7.0147e+12;
           10, 1.1958e+13, 1.3059e+12;
           20, 5.1683e+12, 7.7874e+11;
           30, 3.0e+12, 7.3243e+11]; 
       
% 时间转换为秒
x = rhoData(:, 1) * 60; 
y = rhoData(:, 2);
stdRadiusList = rhoData(:, 3);

% 图例名称
legendName = {'Experiment Data', 'Fitting Function'};

% 可视化参数设置
visParams = VisualizationParams();
visParams.height = 12;
visParams.width = 13;
visParams.fontSizeLegend = 16;

%% ============================ 绘制误差棒 ============================
initPlot(1, visParams);

% 设置绘图索引
iData = 1;
errorbar(x, y, stdRadiusList, ...
    'Color', visParams.colors{iData}, ...
    'LineStyle', 'none', ...          % 去除连线
    'LineWidth', visParams.lineWidth, ...
    'Marker', visParams.markers{iData}, ...
    'MarkerSize', visParams.markerSize, ...
    'MarkerFaceColor', visParams.colors{iData}, ...
    'DisplayName', legendName{iData});

%% ============================ 绘制拟合曲线 ============================
% 定义拟合曲线范围
x_fit = linspace(230, 2e3 - 10, 1000); 

% 拟合函数参数
% a = 1.0244e+14; 
% b = 4.4276e-03;
% c = 3.0e+12;

a = 7.0540e+13;
b = 3.30e-03;
c = 3.0e+12;
% 拟合曲线计算
fit_result = (a - c) .* exp(-b .* x_fit) + c;

% 绘制拟合曲线
iData = 2;
plot(x_fit, fit_result, ...
    'Color', visParams.colors{iData}, ...
    'LineWidth', visParams.lineWidth - 1.0, ...
    'LineStyle', visParams.lineStyles{1}, ...
    'DisplayName', legendName{iData});

%% ============================ 设置轴标签和图例 ============================
% 设置坐标轴标签
xlim([0 2000]);
ylim([0 4e13]);
titles = {'Time (s)', '\rho (1/m)'};
finalizePlot(visParams, titles);

% 显示图例
legend('Location', 'best');

% 完成通知
fprintf('✅ 图表绘制完成。\n');


% H:\Github\MyRhinoLab\scripts\p23-GNSNi-AGG-2024\20250507_Layer2a3_and_Layer1a2\p23_s6_rho_with_time_0507.m