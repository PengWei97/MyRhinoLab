close all
scale_factor = [10.0, 15.0, 20.0];

mob_ij = 1.0;
mob_ij_high = mob_ij.*scale_factor;
trans_misori_rho = [90, 120, 150];

B = 5;
n = 4;

% 可视化参数设置
visParams = VisualizationParams();
% visParams.height = 12;
% visParams.width = 13;
% visParams.fontSizeLegend = 16;
initPlot(1, visParams);
for iData = 1:3
  delta_rho = linspace(0,trans_misori_rho(iData)+10,100);
  mob_temp = mob_ij_high(1) .* ((1- exp(-B .* power( delta_rho ./ trans_misori_rho(iData), n)))); 
  plot(delta_rho, mob_temp, ...
      'Color', visParams.colors{iData}, ...
      'LineWidth', visParams.lineWidth, ...
      'LineStyle', visParams.lineStyles{iData}, ...
      'DisplayName', sprintf('v%d-deltaRho: %d', iData, trans_misori_rho(iData)));
end
%% ============================ 设置轴标签和图例 ============================
% 设置坐标轴标签
% xlim([0 110]);
ylim([-1 11]);
titles = {'\Delta \rho (1/m)', 'm'};
finalizePlot(visParams, titles);

% 显示图例
legend('Location', 'southeast');

% 完成通知
fprintf('✅ 图表绘制完成。\n');
% H:\Github\MyRhinoLab\scripts\p23-GNSNi-AGG-2024\20250522_getRhoFunc\p23_s3_drwa_mob_with_deltaRho_v2.m

