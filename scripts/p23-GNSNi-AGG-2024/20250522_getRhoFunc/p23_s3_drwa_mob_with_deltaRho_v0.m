close all
scale_factor = 15.0;

mob_ij = 1.0;
mob_ij_high = mob_ij.*scale_factor;
trans_misori_rho = 150.0;
delta_rho = linspace(0,180,100);

B = 5;
n = 4;
mob_temp = mob_ij_high .* ((1- exp(-B .* power( delta_rho ./ trans_misori_rho, n)))); 

% 可视化参数设置
visParams = VisualizationParams();
% visParams.height = 12;
% visParams.width = 13;
% visParams.fontSizeLegend = 16;
initPlot(1, visParams);
iData = 1;
plot(delta_rho, mob_temp, ...
    'Color', visParams.colors{iData}, ...
    'LineWidth', visParams.lineWidth, ...
    'LineStyle', visParams.lineStyles{iData}, ...
    'DisplayName', sprintf('v%d-factor: %d and \n deltaRho: %d', iData, scale_factor, trans_misori_rho));

const_yLine = mob_ij_high .* ((1- exp(-B .* power( 90 ./ trans_misori_rho, n)))); 
yLine = linspace(const_yLine,const_yLine,100);
iData = 2;
plot(delta_rho, yLine, ...
    'Color', visParams.colors{iData}, ...
    'LineWidth', visParams.lineWidth, ...
    'LineStyle', visParams.lineStyles{iData}, ...
    'DisplayName', sprintf('deltaRho: %.2f', const_yLine));

const_yLine2 = mob_ij_high .* ((1- exp(-B .* power( 120 ./ trans_misori_rho, n)))); 
yLine2 = linspace(const_yLine2,const_yLine2,100);
iData = 3;
plot(delta_rho, yLine2, ...
    'Color', visParams.colors{iData}, ...
    'LineWidth', visParams.lineWidth, ...
    'LineStyle', visParams.lineStyles{iData}, ...
    'DisplayName', sprintf('deltaRho: %.2f', const_yLine2));
%% ============================ 设置轴标签和图例 ============================
% 设置坐标轴标签
xlim([0 180]);
ylim([-1 16]);
titles = {'\Delta \rho (1/m)', 'm'};
finalizePlot(visParams, titles);

% 显示图例
legend('Location', 'southeast');

% 完成通知
fprintf('✅ 图表绘制完成。\n');
% H:\Github\MyRhinoLab\scripts\p23-GNSNi-AGG-2024\20250522_getRhoFunc\p23_s3_drwa_mob_with_deltaRho_v0.m

