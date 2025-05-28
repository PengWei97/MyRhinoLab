%% 脚本说明
% H:\Github\MyRhinoLab\scripts\p23-GNSNi-AGG-2024\20250507_Layer2a3_and_Layer1a2\p23_s5_generate_inl_with_rho_for_moose_0507.m

%% 代码开始
close all;
clear;
clc;

%% 设置文件路径和参数
dataPath = 'H:\Github\MyRhinoLabData\p23_GNSNi_AGG_2024\experiment2\PF_Initial\Layer2a3_bk_t2\temp\';
timePoints = [5.0, 10.0, 20.0, 30.0];  % 时间点数组
baseName = 'Layer2a3';

versionID = 1;
% 处理每个指定的时间点
for iRegion = 1:5 % length(baseName):length(baseName)
  for iTime = 2:2
    dataCSVInitial = readtable(fullfile(dataPath, sprintf('GNSNi_%dmin_%s_R%d_rho_inl.csv', timePoints(iTime), baseName, iRegion)));

    if iRegion == 2
      if versionID == 1
      % 情况1
      meanRho2 = mean(dataCSVInitial.Rho(ismember(dataCSVInitial.FeatureId, 434))); 
      dataCSVInitial.Rho(ismember(dataCSVInitial.FeatureId, 371)) = meanRho2*0.9;        

      meanRho2 = mean(dataCSVInitial.Rho(ismember(dataCSVInitial.FeatureId, 370))); 
      dataCSVInitial.Rho(ismember(dataCSVInitial.FeatureId, 281)) = meanRho2*0.9;       
      end
    elseif iRegion == 4 
      if versionID == 1 % 情况1  
        meanRho1 = mean(dataCSVInitial.Rho(ismember(dataCSVInitial.FeatureId, 592))); 
        dataCSVInitial.Rho(ismember(dataCSVInitial.FeatureId, 41)) = meanRho1 * 1.1;       
  
        meanRho2 = mean(dataCSVInitial.Rho(ismember(dataCSVInitial.FeatureId, 592))); 
        dataCSVInitial.Rho(ismember(dataCSVInitial.FeatureId, 203)) = meanRho1 * 1.1;       
      end
    elseif iRegion == 5
      if versionID == 1 % 情况1
        meanRho1 = mean(dataCSVInitial.Rho(ismember(dataCSVInitial.FeatureId, 12))); 
        dataCSVInitial.Rho(ismember(dataCSVInitial.FeatureId, 506)) = meanRho1;

        meanRho2 = mean(dataCSVInitial.Rho(ismember(dataCSVInitial.FeatureId, 390))); 
        dataCSVInitial.Rho(ismember(dataCSVInitial.FeatureId, 454)) = meanRho2*1.1;
        dataCSVInitial.Rho(ismember(dataCSVInitial.FeatureId, 276)) = meanRho2*0.9;       
      end
    else
      continue;
    end

    outputAdjustedData(dataCSVInitial, dataPath, timePoints(iTime), baseName, iRegion, versionID);
  end
end

%% 函数：输出调整后的数据
function outputAdjustedData(dataCSVInitial, outputPath, timePoint, baseName, iRegion, VsSeq)
  % 输出调整后的数据为CSV文件

  dataOutput = dataCSVInitial;
  fieldsToConvert = {'phi1', 'PHI', 'phi2', 'x', 'y', 'z', 'Rho'};  % 需要转换的字段
  precisions = {'%.6f', '%.6f', '%.6f', '%.6f', '%.6f', '%.2f', '%.6e'};  % 输出精度

  % 将指定字段转换为字符串格式
  for iVariable = 1:length(fieldsToConvert)
      dataOutput.(fieldsToConvert{iVariable}) = strtrim(cellstr(num2str(dataOutput.(fieldsToConvert{iVariable}), precisions{iVariable})));
  end

  % 设置输出文件名，并将数据写入CSV文件
  outputFilename = sprintf('GNSNi_%dmin_%s_R%d_rho_v%d_inl.csv', timePoint, baseName, iRegion, VsSeq);
  writetable(dataOutput, fullfile(outputPath, outputFilename), 'Delimiter', ' ');
end

% 脚本路径：H:\Github\MyRhinoLab\scripts\p23-GNSNi-AGG-2024\20250524_Layer2a3_benchmarks\p23_s5_modify_inl_with_rho_for_moose_0524.m