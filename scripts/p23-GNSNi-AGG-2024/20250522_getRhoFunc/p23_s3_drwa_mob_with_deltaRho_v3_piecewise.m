close all
delta_rho = [0, 70, 90 130, 150];
scale_factor = [1.0, 1.0, 4.0, 15.0, 15.0];

% delta_rho = [0, 70, 79.999, 80.0, 90 130, 150];
% scale_factor = [1.0, 1.0, 1.0, 4.0, 8.0, 15.0, 15.0];

% 可视化参数设置
visParams = VisualizationParams();

initPlot(1, visParams);
iType = 1;
for iData = 1:1
  x = delta_rho(iData, :);
  y = scale_factor(iData, :);
  plot(x, y, ...
      'Color', visParams.colors{iType}, ...
      'Marker', visParams.markers{iData},...
      'MarkerSize', visParams.markerSize,...
      'MarkerFaceColor', visParams.colors{iType}, ...
      'LineWidth', visParams.lineWidth, ...
      'LineStyle', visParams.lineStyles{iData}, ...      
      'DisplayName', sprintf("v%d", iType));
end
%% ============================ 设置轴标签和图例 ============================
% 设置坐标轴标签
% ylim([0 16]);
% ylim([-1 11]);
titles = {'\Delta \rho (1/m)', '\alpha_m'};
finalizePlot(visParams, titles);

% 显示图例
legend('Location', 'southeast');

% 完成通知
fprintf('✅ 图表绘制完成。\n');
% H:\Github\MyRhinoLab\scripts\p23-GNSNi-AGG-2024\20250522_getRhoFunc\p23_s3_drwa_mob_with_deltaRho_v3_piecewise.m

% [750.538,	266.035, 919.355,	481.497;
% 574.194,	207.152, 815.054,	541.859;
% 496.774,	272.951, 608.602,	394.331;
% 266.667,	215.237, 545.161,	542.228;
% 58.0645,	286.691, 246.237,	518.55;]