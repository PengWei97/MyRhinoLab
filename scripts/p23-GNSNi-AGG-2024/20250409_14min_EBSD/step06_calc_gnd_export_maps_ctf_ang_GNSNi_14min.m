%% 脚本说明
% 创建时间：2024年4月20日
% 创建人：Pengwei
% 创建目的：该脚本用于处理并分析global-EBSD数据，具体功能包括：
% 1. 计算GND，将GND map输出为png格式保存，
% 2. 输入GND 随depth的csv文件，
% 3. 最后保存EBSD data为ang和包含GND 的ctf格式

close all;
clear;
clc;

% 定义晶体对称性
crystalSymmetry = {... 
  'notIndexed',... 
  crystalSymmetry('m-3m', [3.6 3.6 3.6], 'mineral', 'Ni-superalloy', 'color', [0.53 0.81 0.98])};

% 设置绘图的坐标轴方向
setMTEXpref('xAxisDirection', 'west');
setMTEXpref('zAxisDirection', 'outOfPlane');

%% 指定文件路径
inputDir = 'H:\Github\MyRhinoLabData\p23_GNSNi_AGG_2024\experiment\QIS_EBSD\ctf_excerpt\';
outputDir1 = 'H:\Github\MyRhinoLabData\p23_GNSNi_AGG_2024\experiment\QIS_EBSD\png_GND\';
outputDir2 = 'H:\Github\MyRhinoLabData\p23_GNSNi_AGG_2024\experiment\QIS_EBSD\csv_GND_depth\';
outputDir3 = 'H:\Github\MyRhinoLabData\p23_GNSNi_AGG_2024\experiment\QIS_EBSD\ctf_excerpt_GND\';
outputDir4 = 'H:\Github\MyRhinoLabData\p23_GNSNi_AGG_2024\experiment\QIS_EBSD\ang_excerpt\';

if ~exist(outputDir1, 'dir'), mkdir(outputDir1); end
if ~exist(outputDir2, 'dir'), mkdir(outputDir2); end
if ~exist(outputDir3, 'dir'), mkdir(outputDir3); end
if ~exist(outputDir4, 'dir'), mkdir(outputDir4); end

timePoints = [5.0, 10.0, 20.0, 30.0];  % 时间点（分钟）
numTypeFigures = 2;  % 每个时间点绘制的图像数量

% 循环处理每个时间点的数据
for iTime = 1:length(timePoints)
  clear ebsdData ebsdToRefine ebsdGrid rho
  % 文件路径
  inputFile = fullfile(inputDir, sprintf('GNSNi_%dmin_global.ctf', timePoints(iTime)));

  %% 导入数据
  ebsdData = EBSD.load(inputFile, crystalSymmetry, 'interface', 'ctf', ...
                        'convertEuler2SpatialReferenceFrame');

  ebsdToRefine = ebsdData; % 变换网格
  [grainsToRefine, ebsdToRefine] = identifyAndSmoothGrains(ebsdToRefine, 2.0 * degree, 60, 20.0);

  %% 计算GND（几何必要位错）图
  ebsdGrid = ebsdToRefine('indexed').gridify;
  rho = calculatedFCCGNDs(ebsdGrid);

  % 绘制GND map
  idFigure = numTypeFigures * (iTime-1)+1;
  figure(idFigure)
  plot(ebsdToRefine, rho, 'coordinates', 'off', 'micronbar', 'off');
  hold on;
  mtexColorMap('jet');
  set(gca, 'ColorScale', 'log');
  set(gca, 'CLim', [1.0e+11,3.0e15]); % 需要更具情况来调整
  plot(grainsToRefine.boundary, 'linewidth', 0.8);
  hold off;
  outputFile = fullfile(outputDir1, sprintf('GNSNi_global_%dmin_GND.png', timePoints(iTime)));
  print(gcf, outputFile, '-dpng', '-r1200');

  %% 获取 rho with depth
  rho_ave = zeros(length(ebsdGrid.id(:,1)),1);
  for j = 1:length(ebsdGrid.id(:,1))
    rho_squence = rho(ebsdGrid.id(j,:)); % 获取 rho 值序列
    rho_filtered = rho_squence(~isnan(rho_squence)); % 去除 NaN 值

    % 计算去除异常值后的平均值
    if ~isempty(rho_filtered)
      rho_ave(j,1) = mean(rho_filtered);
    else
      rho_ave(j,1) = NaN; % 避免计算空数据导致错误
    end
  end
  % rho_ave = flip(rho_ave);  % 翻转数据

  % 保存csv文件，rho with depth
  deep = linspace(0,ymax,length(ebsdGrid.id(:,1)))';
  outputData = table;
  outputData.depth = deep;
  outputData.rho_ave_depth = rho_ave;
  outputFile = fullfile(outputDir2, sprintf('GNSNi_global_%dmin_rho_with_depth.csv', timePoints(iTime)));
  writetable(outputData, outputFile);

  %% Step 3: 导出包含rho信息的CTF格式文件
  outputFile = fullfile(outputDir3, sprintf('GNSNi_global_%dmin_rho.ctf',timePoints(iTime))); 
  export_ctf(ebsdGrid, rho, outputFile); 

  %% Step 4: 导出ANG格式文件供Dream3D使用
  outputFile = fullfile(outputDir4, sprintf('GNSNi_global_%dmin.ang',timePoints(iTime))); 
  export_ang(ebsdGrid, outputFile);  
end

% H:\Github\MyRhinoLab\demo\mtex_EBSD_GG\postprocess\step5_calc_gnd_export_maps_ctf_ang.m