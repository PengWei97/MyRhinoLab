%% 脚本说明
% H:\Github\MyRhinoLab\scripts\p23-GNSNi-AGG-2024\20250507_Layer2a3_and_Layer1a2\p23_s5_generate_inl_with_rho_for_moose_0507.m

%% 代码开始
close all;
clear;
clc;

%% 设置文件路径和参数
dataPath = 'H:\Github\MyRhinoLabData\p23_GNSNi_AGG_2024\experiment2\PF_Initial\temp\';
timePoints = [5.0, 10.0, 20.0, 30.0];  % 时间点数组
baseName = {'Layer2a3_29p_f0p5'};

versionID = 2;
% 处理每个指定的时间点
for iBaseName = length(baseName):length(baseName)
  for iTime = 2:2
    % 读取INL和CTF数据
    dataINL = readtable(fullfile(dataPath, sprintf('GNSNi_%dmin_%s_inl.csv', timePoints(iTime), baseName{iBaseName})));

    dataCSVInitial = readtable(fullfile(dataPath, sprintf('GNSNi_%dmin_%s_rho_inl_v0.csv', timePoints(iTime), baseName{iBaseName})));

    if versionID == 1
    % 情况1
    meanRho1 = mean(dataCSVInitial.Rho(ismember(dataCSVInitial.FeatureId, 312))); 
    dataCSVInitial.Rho(ismember(dataCSVInitial.FeatureId, 809)) = meanRho1*0.99;
    dataCSVInitial.Rho(ismember(dataCSVInitial.FeatureId, 220)) = meanRho1*0.98;

    % 情况2:
    meanRho2 = mean(dataCSVInitial.Rho(ismember(dataCSVInitial.FeatureId, 44))); 
    dataCSVInitial.Rho(ismember(dataCSVInitial.FeatureId, 199)) = meanRho2*0.9;

    elseif versionID == 2
      % 情况1
      meanRho1 = mean(dataCSVInitial.Rho(ismember(dataCSVInitial.FeatureId, 44))); 
      dataCSVInitial.Rho(ismember(dataCSVInitial.FeatureId, 199)) = meanRho1*0.9;   
      
      % 情况2
      dataCSVInitial.Rho(ismember(dataCSVInitial.FeatureId, 300)) = dataCSVInitial.Rho(ismember(dataCSVInitial.FeatureId, 300))./3;
      dataCSVInitial.Rho(ismember(dataCSVInitial.FeatureId, 231)) = dataCSVInitial.Rho(ismember(dataCSVInitial.FeatureId, 231))./3;
      
      % 情况3
      meanRho3 = mean(dataCSVInitial.Rho(ismember(dataCSVInitial.FeatureId, 312))); 
      dataCSVInitial.Rho(ismember(dataCSVInitial.FeatureId, 809)) = meanRho3*0.9;
      dataCSVInitial.Rho(ismember(dataCSVInitial.FeatureId, 220)) = meanRho3*0.8;
    elseif versionID == 3
      % 情况1
      meanRho1 = mean(dataCSVInitial.Rho(ismember(dataCSVInitial.FeatureId, 44))); 
      dataCSVInitial.Rho(ismember(dataCSVInitial.FeatureId, 199)) = meanRho1*0.9;   
      
      
    end
    % 情况2:
    % dataCSVInitial.Rho(ismember(dataCSVInitial.FeatureId, 300))
    % hist(dataCSVInitial.Rho(ismember(dataCSVInitial.FeatureId, 300)))
    outputAdjustedData(dataCSVInitial, dataPath, timePoints(iTime), baseName{iBaseName}, versionID);
  end
end

%% 函数：输出调整后的数据
function outputAdjustedData(dataCSVInitial, outputPath, timePoint, baseName, VsSeq)
  % 输出调整后的数据为CSV文件

  dataOutput = dataCSVInitial;
  fieldsToConvert = {'phi1', 'PHI', 'phi2', 'x', 'y', 'z', 'Rho'};  % 需要转换的字段
  precisions = {'%.6f', '%.6f', '%.6f', '%.6f', '%.6f', '%.2f', '%.6e'};  % 输出精度

  % 将指定字段转换为字符串格式
  for iVariable = 1:length(fieldsToConvert)
      dataOutput.(fieldsToConvert{iVariable}) = strtrim(cellstr(num2str(dataOutput.(fieldsToConvert{iVariable}), precisions{iVariable})));
  end

  % 设置输出文件名，并将数据写入CSV文件
  outputFilename = sprintf('GNSNi_%dmin_%s_rho_v%d_inl.csv', timePoint, baseName, VsSeq);
  writetable(dataOutput, fullfile(outputPath, outputFilename), 'Delimiter', ' ');
end

% 脚本路径：H:\Github\MyRhinoLab\scripts\p23-GNSNi-AGG-2024\20250507_Layer2a3_and_Layer1a2\p23_s5_modify_inl_with_rho_for_moose_0507.m