%% 脚本说明

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
dataPath = 'H:\Github\MyRhinoLabData\p23_GNSNi_AGG_2024\experiment2\PF_Initial\ctf_excerpt\';
outputDataPath1 = 'H:\Github\MyRhinoLabData\p23_GNSNi_AGG_2024\experiment2\PF_Initial\csv_AGG_data\';

if ~exist(outputDataPath1, 'dir'), mkdir(outputDataPath1); end

timePoints = [5.0, 10.0, 20.0, 30.0];  % 时间点（分钟）
numTypeFigures = 8;  % 每个时间点绘制的图像数量
baseName = 'Layer2a3_f0p5';

ID = [];
phi1 = [];
Phi = [];
phi2 = [];
grainSize = [];

% 循环处理每个时间点的数据
for iTime = 2:2
  % 文件路径
  inputFile = fullfile(dataPath, sprintf('GNSNi_%dmin_%s.ctf', timePoints(iTime), baseName));

  %% 导入数据
  ebsd = EBSD.load(inputFile, crystalSymmetry, 'interface', 'ctf', ...
                        'convertEuler2SpatialReferenceFrame');

  % 标识和平滑晶粒
  [xmin, xmax, ymin, ymax] = ebsd.extend();
  pixel2Area = (xmax - xmin) * (ymax - ymin) / length(ebsd);

  switch iTime
    case 2
      grainID = [352,260,302,246,190,189,218,135,139,168,142,237];
    case 3
      grainID = [692,543,498,478,670,669,624,526,488,497,480,625];
    case 4
      grainID = [607,579,364,174,372];
    case 5
      grainID = [421,638,464,431,373,486,361,422,399,510,584,503,576];
  end  

  [grains, ebsd] = identifyAndSmoothGrains(ebsd, 2.0 * degree, 50, 3.0);

  %% 绘图（用于快速查看）
  % Plot EBSD map of each extracted layer
  idFigure = numTypeFigures * (iTime - 1) + 1;
  figure(idFigure)
  plot(grains, grains.meanOrientation, 'coordinates', 'off', 'micronbar', 'off');
  hold on
  plot(grains.boundary, 'linewidth', 0.8);
    
  ID = grainID';
  phi1 = grains(grainID).meanOrientation.phi1./degree;
  Phi = grains(grainID).meanOrientation.Phi./degree;
  phi2 = grains(grainID).meanOrientation.phi2./degree;
  grainSize = grains(grainID).grainSize./pixel2Area;
 
  % 4. 创建表格并保存
  GrainData = [ID, phi1, Phi, phi2, grainSize];
  T = array2table(GrainData, 'VariableNames', {'grainID', 'phi1', 'Phi', 'phi2', 'grainSize'});   
  outputFile = fullfile(outputDataPath1, sprintf('GNSNi_%dmin_%s_AGG.ctf', timePoints(iTime), baseName));
  writetable(T, outputFile);
end

% H:\Github\MyRhinoLab\scripts\p23-GNSNi-AGG-2024\20250507_Layer2a3_and_Layer1a2\p23_s2_generate_maps_0507.m
