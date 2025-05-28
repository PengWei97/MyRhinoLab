% 清理环境
close all; clear; clc;

% 输入路径及基础信息
inputDir = 'H:\Github\MyRhinoLabData\p23_GNSNi_AGG_2024\experiment\QIS_EBSD\bmp_gb\';
outputDir1 = 'H:\Github\MyRhinoLabData\p23_GNSNi_AGG_2024\experiment\QIS_EBSD\csv_d_depth\';
if ~exist(outputDir1, 'dir'), mkdir(outputDir1); end

timePoints = [5.0, 10.0, 20.0, 30.0];  % 时间点（单位：分钟）

%% 需要提前获取的参数
% EBSD图像对应的实际物理尺寸（单位：μm）
ebsdWidth = 998.5;
ebsdHeight = 1278.9;

% 白色像素开始处的空白区域宽度（单位：像素）
blankSize = 17;

% 遍历不同时间点的数据
for iTime = 1:length(timePoints)
  % 构建图像文件路径
  fileName = fullfile(inputDir, sprintf('GNSNi_global_%dmin_gb.bmp', timePoints(iTime)));

  % 读取图像并转为灰度
  inputImage = imread(fileName);
  grayImage = rgb2gray(inputImage);

  % 图像尺寸
  [imgHeight, imgWidth] = size(grayImage);

  % 初始化变量
  grainDiameter = zeros(imgHeight, 1);
  depthPosition = zeros(imgHeight, 1);

  % 沿纵向遍历，统计每一行的晶粒数量
  for j = blankSize:(imgHeight - blankSize)
      grainCount = 0;

      for i = 1:(imgWidth - 1)
          if grayImage(j, i) == 255 && grayImage(j, i + 1) ~= 255
              grainCount = grainCount + 1;
          end
      end

      grainCount = grainCount - 1;  % 间隙计数修正

      % 计算晶粒尺寸
      if grainCount >= 1
          grainDiameter(j) = ...
              (imgWidth - 2 * blankSize) / grainCount * ...
              (ebsdWidth / (imgWidth - 2 * blankSize));
      end

      % 计算当前深度位置
      depthPosition(j) = (j - blankSize) / imgHeight * ebsdHeight;
  end

  % 提取有效数据（去除零值）
  validMask = grainDiameter > 0;
  validDepth = depthPosition(validMask);
  validDiameter = grainDiameter(validMask);

  % 保存为表格
  resultTable = table(validDepth, validDiameter, ...
    'VariableNames', {'depth', 'averageGrainDiameter'});

  outputFile = fullfile(outputDir1, ...
    sprintf('GNSNi_QIS_global_%dmin_diameter_vs_depth.csv', timePoints(iTime)));
  writetable(resultTable, outputFile);
end

% H:\Github\MyRhinoLab\scripts\p23-GNSNi-AGG-2024\20250327_QIS_EBSD\p23_EBSD9_s1_get_ave_R_with_depth_QIS.m