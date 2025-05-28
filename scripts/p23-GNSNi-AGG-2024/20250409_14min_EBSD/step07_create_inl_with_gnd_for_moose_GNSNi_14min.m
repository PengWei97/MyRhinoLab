%% 脚本说明
% 创建时间：2024年4月20日
% 创建人：Pengwei
% 创建目的：该脚本用于处理降噪后的GNSNi数据，调整基于INL（内部局部误差）和CTF（晶体方位分布）数据的rho值，并将处理后的数据输出为CSV文件。
% 该脚本适用于GNS-Ni合金的实验数据分析，时间点包括5min、10min、20min和30min。

%% 代码开始
close all;
clear;
clc;

%% 设置文件路径和参数
inputDir = 'H:\Github\MyRhinoLabData\p23_GNSNi_AGG_2024\experiment\QIS_EBSD\temp\';

timePoints = [5.0, 10.0, 20.0, 30.0];  % 时间点数组
Layers = {'Layer1','Layer2','Layer3','Layer4','1f3_Layer1a2','1f3_Layer2a3'};

% 处理每个指定的时间点
for iTime = 1:length(timePoints)
  for iLayer = 1:length(Layers)

    % 读取INL和CTF数据
    dataINL = readtable(fullfile(inputDir, sprintf('GNSNi_%s_%dmin_inl.csv', Layers{iLayer}, timePoints(iTime))));
    dataCTF = readtable(fullfile(inputDir, sprintf('GNSNi_%s_%dmin_rho_ctf.csv', Layers{iLayer}, timePoints(iTime))));

    % 确定rho值的临界范围，用于过滤
    minCriticalRho = min(dataCTF.Rho(dataCTF.Rho > 100)) - 10;
    maxCriticalRho = max(dataCTF.Rho);

    % 可视化Rho分布
    plotRhoDistributions(dataINL, dataCTF);    

    % 基于特征调整rho值
    dataCTF = adjustRhoValues(dataINL, dataCTF, minCriticalRho, maxCriticalRho);

    % 可视化调整后的Rho分布
    plotRhoDistributions(dataINL, dataCTF);
    
    % 输出调整后的数据
    outputAdjustedData(dataINL, dataCTF, inputDir, Layers{iLayer}, timePoints(iTime));
  end
end

%% 函数：可视化Rho分布
function plotRhoDistributions(dataInl, dataCtf)
    % 绘制INL数据和CTF数据中的log-scaled Rho值分布图

    % 绘制INL数据的Rho分布
    figure;
    scatter(dataInl.x, dataInl.y, 20, log(dataCtf.Rho), 'filled');
    title('Log-scaled Rho values from INL data');
    colorbar;

    % 绘制CTF数据的Rho分布
    figure;
    scatter(dataCtf.X, dataCtf.Y, 20, log(dataCtf.Rho), 'filled');
    title('Log-scaled Rho values from CTF data');
    colorbar;
end

%% 函数：根据特征调整Rho值
function dataCtf = adjustRhoValues(dataInl, dataCtf, minCriticalRho, maxCriticalRho)
  % 根据晶粒特征调整 CTF 数据中的 Rho 值
  
  for iFeature = 1:max(dataInl.FeatureId)
      % 获取当前特征的所有 Rho 值
      indices = find(dataInl.FeatureId == iFeature);
      rhoGrain = dataCtf.Rho(indices);
      
      % 过滤有效 Rho（大于 minCriticalRho）
      rhoFiltered = rhoGrain(rhoGrain > minCriticalRho);
      
      % 计算 rhoAverage，避免除零
      if isempty(rhoFiltered)
          rhoAverage = maxCriticalRho;
      else
          rhoAverage = max(mean(rhoFiltered), minCriticalRho);
      end
      
      % 调整 Rho 值
      dataCtf.Rho(indices(rhoGrain < minCriticalRho | isnan(rhoGrain))) = rhoAverage;
  end

  return;
end

%% 函数：输出调整后的数据
function outputAdjustedData(dataInl, dataCtf, outputDir, iLayer, timePoint)
    % 输出调整后的数据为CSV文件

    dataOutput = dataInl;
    fieldsToConvert = {'phi1', 'PHI', 'phi2', 'x', 'y', 'z'};  % 需要转换的字段
    precisions = {'%.6f', '%.6f', '%.6f', '%.6f', '%.6f', '%.2f'};  % 输出精度

    % 将指定字段转换为字符串格式
    for iVariable = 1:length(fieldsToConvert)
        dataOutput.(fieldsToConvert{iVariable}) = strtrim(cellstr(num2str(dataInl.(fieldsToConvert{iVariable}), precisions{iVariable})));
    end

    % 将Rho列转换为科学计数法格式
    dataOutput.Rho = strtrim(cellstr(num2str(dataCtf.Rho,'%.6e')));

    % 设置输出文件名，并将数据写入CSV文件
    outputFilename = sprintf('GNSNi_%s_%dmin_rho_inl.csv',iLayer, timePoint); 
    writetable(dataOutput, fullfile(outputDir, outputFilename), 'Delimiter', ' ');
end

% 脚本路径：H:\Github\MyRhinoLab\scripts\p23-GNSNi-AGG-2024\20250328_PF_benchmark\p23_bm3_combine_inl_and_rho_step2.m
