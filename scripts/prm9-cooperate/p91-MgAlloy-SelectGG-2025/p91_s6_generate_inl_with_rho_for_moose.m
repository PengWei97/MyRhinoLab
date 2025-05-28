%% 脚本说明
% H:\Github\MyRhinoLab\scripts\prm9-cooperate\p91-MgAlloy-SelectGG-2025\p91_s6_generate_inl_with_rho_for_moose.m

%% 代码开始
close all;
clear;
clc;

%% 设置文件路径和参数
inputDir = 'H:\Github\MyRhinoLabData\p91_MgAlloy_SelectGG_2025\temp\';
fileNames = {'400du_30min', '450du_30min', '500du_10min', '500du_120min', '400du_30min_local2', '400du_30min_local3_400a400'};

% 处理每个指定的时间点
for iTime = 6:6
  % 读取INL和CTF数据
  dataINL = readtable(fullfile(inputDir, sprintf('c%d_%s_inl.csv', iTime, fileNames{iTime})));

  dataCTF = readtable(fullfile(inputDir, sprintf('c%d_%s_grainType_ctf.csv', iTime, fileNames{iTime})));

  GrainType = dataCTF.Rho;
  GrainType(GrainType == 0) = 3;

  % 可视化调整后的Rho分布
  plotRhoDistributions(dataINL, GrainType);
  
  % 输出调整后的数据
  outputAdjustedData(dataINL, GrainType, inputDir, fileNames{iTime}, iTime);
end
% H:\Github\MyRhinoLab\scripts\prm9-cooperate\p91-MgAlloy-SelectGG-2025\p91_s6_generate_inl_with_rho_for_moose.m

%% 函数：可视化Rho分布
function plotRhoDistributions(dataInl, value)

  % 绘制CTF数据的Rho分布
  figure;
  scatter(dataInl.x, dataInl.y, 20, value, 'filled');
  title('Log-scaled Rho values from CTF data');
  colorbar;
end

%% 函数：输出调整后的数据
function outputAdjustedData(dataInl, GrainType, outputPath, baseName, iTime)
  % 输出调整后的数据为CSV文件

  dataOutput = dataInl;
  fieldsToConvert = {'phi1', 'PHI', 'phi2', 'x', 'y', 'z'};  % 需要转换的字段
  precisions = {'%.6f', '%.6f', '%.6f', '%.6f', '%.6f', '%.2f'};  % 输出精度

  % 将指定字段转换为字符串格式
  for iVariable = 1:length(fieldsToConvert)
      dataOutput.(fieldsToConvert{iVariable}) = strtrim(cellstr(num2str(dataInl.(fieldsToConvert{iVariable}), precisions{iVariable})));
  end

  % 将Rho列转换为科学计数法格式
  dataOutput.Rho = strtrim(cellstr(num2str(GrainType,'%.0f')));

  % 设置输出文件名，并将数据写入CSV文件
  outputFilename = sprintf('c%d_%s_grainType_inl.csv', iTime, baseName);
  writetable(dataOutput, fullfile(outputPath, outputFilename), 'Delimiter', ' ');
end

% 脚本路径：H:\Github\MyRhinoLab\scripts\p23-GNSNi-AGG-2024\20250507_Layer2a3_and_Layer1a2\p23_s5_generate_inl_with_rho_for_moose_0507.m