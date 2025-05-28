%% 脚本说明
% H:\Github\MyRhinoLab\scripts\p23-GNSNi-AGG-2024\20250507_Layer2a3_and_Layer1a2\p23_s5_generate_inl_with_rho_for_moose_0507.m

%% 代码开始
close all;
clear;
clc;

%% 设置文件路径和参数
dataPath = 'H:\Github\MyRhinoLabData\p23_GNSNi_AGG_2024\experiment2\PF_Initial\temp\';
timePoints = [5.0, 10.0, 20.0, 30.0];  % 时间点数组
baseName = {'Layer2a3_f0p5', '1f3_Layer2a3_f0p5', '35p_Layer2a3_f0p5', 'c1_Layer2a3_f0p5', 'Layer1_40p_f0p5', 'Layer2a3_29p_f0p5'};

% 处理每个指定的时间点
for iBaseName = length(baseName):length(baseName)
for iTime = 2:2
  % 读取INL和CTF数据
  dataINL = readtable(fullfile(dataPath, sprintf('GNSNi_%dmin_%s_inl.csv', timePoints(iTime), baseName{iBaseName})));

  dataCTF = readtable(fullfile(dataPath, sprintf('GNSNi_%dmin_%s_rho_ctf.csv', timePoints(iTime), baseName{iBaseName})));

  % 确定rho值的临界范围，用于过滤
  minCriticalRho = min(dataCTF.Rho(dataCTF.Rho > 100)) - 10;
  maxCriticalRho = max(dataCTF.Rho);

%   % 可视化Rho分布
%   plotRhoDistributions(dataINL, dataCTF);    

  % 基于特征调整rho值
  dataCTF = adjustRhoValues(dataINL, dataCTF, minCriticalRho, maxCriticalRho);

  % 可视化调整后的Rho分布
  plotRhoDistributions(dataINL, dataCTF);
  
  % 输出调整后的数据
  outputAdjustedData(dataINL, dataCTF, dataPath, timePoints(iTime), baseName{iBaseName});
end
end

%% 函数：可视化Rho分布
function plotRhoDistributions(dataInl, dataCtf)
    % 绘制INL数据和CTF数据中的log-scaled Rho值分布图

    % % 绘制INL数据的Rho分布
    % figure;
    % scatter(dataInl.x, dataInl.y, 20, log(dataCtf.Rho), 'filled');
    % title('Log-scaled Rho values from INL data');
    % colorbar;

    % 绘制CTF数据的Rho分布
    figure;
    scatter(dataCtf.X, dataCtf.Y, 20, log10(dataCtf.Rho), 'filled');
    title('Log-scaled Rho values from CTF data');
    colorbar;
end

%% 函数：根据特征调整Rho值
% 由于mtex计算的ctf中rho无效数值都是NaN，包括识别和没有识别为晶粒的，所以在step1中无法设定NaN应该为什么样的
% 在step2中，统一通过识别后平均晶粒值来确定，对于小于min*10的晶粒，将NaN值设定为最大值，对弈mean_rho在合理区间内的，在非合理区间的Rho设定为平均值
function dataCtf = adjustRhoValues(dataInl, dataCtf, minCriticalRho, maxCriticalRho)
  % 根据晶粒特征调整 CTF 数据中的 Rho 值
  
  for iFeature = 1:max(dataInl.FeatureId) % 遍历所有grain ID
      % 获取当前特征的所有 Rho 值
      indices = find(dataInl.FeatureId == iFeature);
      rhoGrain = dataCtf.Rho(indices);
      
      % 过滤有效 Rho（大于 minCriticalRho）
      rhoFiltered = rhoGrain(rhoGrain > minCriticalRho);
      
      % 计算 rhoAverage，避免除零
      if isempty(rhoFiltered) % 如果所有晶粒内部，没有有效的rho值，平均值为max
          rhoAverage = maxCriticalRho;
      else % 否则，其晶粒的平均值为所有有效数据的平均值
          rhoAverage = max(mean(rhoFiltered), minCriticalRho);
      end
      
      % 调整 Rho 值 ~ 针对该晶粒内所有数据中符合下面三个条件之一的，赋予其平均值
      dataCtf.Rho(indices(rhoGrain < minCriticalRho | isnan(rhoGrain) | rhoGrain > maxCriticalRho)) = rhoAverage;
  end

  dataCtf.Rho(dataCtf.Rho<minCriticalRho) = maxCriticalRho;
  return;
end

%% 函数：输出调整后的数据
function outputAdjustedData(dataInl, dataCtf, outputPath, timePoint, baseName)
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
    outputFilename = sprintf('GNSNi_%dmin_%s_rho_inl.csv', timePoint, baseName);
    writetable(dataOutput, fullfile(outputPath, outputFilename), 'Delimiter', ' ');
end

% 脚本路径：H:\Github\MyRhinoLab\scripts\p23-GNSNi-AGG-2024\20250507_Layer2a3_and_Layer1a2\p23_s5_generate_inl_with_rho_for_moose_0507.m