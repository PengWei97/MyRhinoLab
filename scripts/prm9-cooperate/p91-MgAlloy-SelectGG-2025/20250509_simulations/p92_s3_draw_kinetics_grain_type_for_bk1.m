%% 清理环境
clc; clear; close all;

%% 设置数据路径和相关参数
outputDataDir = 'H:\Github\MyRhinoLabData\p91_MgAlloy_SelectGG_2025\csv_kinetic\';
simu_case = {'bk2_c1_GBIsotropy','bk2_c2_GBEAniso','bk2_c3_GBEAniso','bk3_c3_GBEAniso', 'bk2_c2_GBMAniso', 'bk2_c3_GBMAniso'}; 
baseName = 'Mg_Gd_alloy';
grain_types = {'Red', 'Green', 'Others'};
simu_cases = {'GB isotropy', 'GBEAniso1: A-A*0.5', 'GBEAniso3: B-B*0.1', 'GBEAniso4: B-B*0.1', 'GBMAniso5: A-A*0.1', 'GBMAniso5: B-B*0.1'}; %  'GBEAniso2: A-A*0.1',
colors = {'r', 'g', 'b'};

%% 可视化参数
visParams = VisualizationParams2();
visParams.height = 6.3;
visParams.width = 8.0;
visParams.fontSizeXY = 10;
visParams.fontSizeLegend = 12;
visParams.fontSizeLabelTitle = 12;
visParams.lineWidth = 1.0;

% 绘制面积演化
initPlot(1, visParams); % Initialize the plot
for iCase = length(simu_case):length(simu_case)
  
  % for iRegion = 1:length(grain_types)
  %   dataFile = sprintf('%s_%s_type%d_kinetic.csv', baseName, simu_case{iCase}, iRegion);
  %   data = readtable(fullfile(outputDataDir, dataFile));
  %   if iRegion == 1
  %     x = data.Time;
  %     totalArea = zeros(length(x),1);
  %   end

  %   totalArea = totalArea + sum(data.grainArea);
  % end
  
  for iRegion = 1:3 % length(grain_types)
    dataFile = sprintf('%s_%s_type%d_kinetic.csv', baseName, simu_case{iCase}, iRegion);
    data = readtable(fullfile(outputDataDir, dataFile));

    x = data.Time;
    y = data.grainArea;
    plot(x(y>0), y(y>0), 'Color', visParams.colors{iRegion}, ...
      'LineWidth', visParams.lineWidth, 'LineStyle', visParams.lineStyles{iCase}, ...
      'DisplayName', sprintf("%s", simu_cases{iCase}));
  end
end
xlim([0,700]);
% ylim([0, 12].*10000);
titles = {'Time (s)', 'Grain Area (\mum^2)'};
finalizePlot(visParams, titles);
% legend('Location', 'eastoutside');
% legend off
fprintf('曲线绘制完成\n');

% 绘制面积演化
initPlot(2, visParams); % Initialize the plot
for iCase = length(simu_case):length(simu_case)
  for iRegion = 1:3 % length(grain_types)
    dataFile = sprintf('%s_%s_type%d_kinetic.csv', baseName, simu_case{iCase}, iRegion);
    data = readtable(fullfile(outputDataDir, dataFile));

    x = data.Time(data.WeightedMeanRadius>0);
    y = data.WeightedMeanRadius(data.WeightedMeanRadius>0).*2;
    plot(x, y, 'Color', visParams.colors{iRegion}, ...
      'LineWidth', visParams.lineWidth, 'LineStyle', visParams.lineStyles{iCase}, ...
      'DisplayName', sprintf("%s", simu_cases{iCase}));
  end
end
xlim([0,700]);
% ylim([10, 40]);
titles = {'Time (s)', 'Grain Diameter (\mum)'};
finalizePlot(visParams, titles);
% legend('Location', 'eastoutside');
legend off

fprintf('曲线绘制完成\n');

% scripts/prm9-cooperate/p91-MgAlloy-SelectGG-2025/20250509_simulations/p92_s3_draw_kinetics_grain_type_for_bk1.m