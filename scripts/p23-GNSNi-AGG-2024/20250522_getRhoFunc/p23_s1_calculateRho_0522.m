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
dataPath = 'H:\Github\MyRhinoLabData\p23_GNSNi_AGG_2024\experiment2\PF_Initial\ctf_excerpt\Rho_func\';
outputDataPath1 = 'H:\Github\MyRhinoLabData\p23_GNSNi_AGG_2024\experiment2\PF_Initial\Rho_func\ang_excerpt\';
outputDataPath2 = 'H:\Github\MyRhinoLabData\p23_GNSNi_AGG_2024\experiment2\PF_Initial\Rho_func\png_GND\';

if ~exist(outputDataPath1, 'dir'), mkdir(outputDataPath1); end
if ~exist(outputDataPath2, 'dir'), mkdir(outputDataPath2); end

timePoints = [5.0, 10.0, 20.0, 30.0];  % 时间点（分钟）
numTypeFigures = 1;  % 每个时间点绘制的图像数量

maxAndMinGND = zeros(4,2);

baseName = 'Local1_Layer3_for_Rho';
% 循环处理每个时间点的数据
for iTime = 1:4
  % clear rho ebsd ebsdGrid grains
  % 文件路径
  inputFile = fullfile(dataPath, sprintf('GNSNi_%dmin_%s.ctf', timePoints(iTime), baseName));

  %% 导入数据
  ebsd = EBSD.load(inputFile, crystalSymmetry, 'interface', 'ctf', ...
                        'convertEuler2SpatialReferenceFrame');

  % 标识和平滑晶粒
  [xmin, xmax, ymin, ymax] = ebsd.extend();
  % ebsd = ebsd(inpolygon(ebsd, [xmin,ymin,50,50]));
  [grains, ebsd] = identifyAndSmoothGrains(ebsd, 2.0 * degree, 50, 3.0);

  %% 计算GND（几何必要位错）图
  ebsdGrid = ebsd('indexed').gridify;
  rho = calculatedFCCGNDs(ebsdGrid);
  
  mask = rho < 1.0e10;
  randomValues = 1.0e11 + (1.0e14 - 1.0e11) * rand(sum(mask(:)), 1);
  rho(mask) = randomValues;

  if iTime == 1
    rho1 = rho;
  elseif iTime == 2
    rho2 = rho;    
  elseif iTime == 3
    rho3 = rho;   
  else
    rho4 = rho;
  end  

  % 绘制GND图
  idFigure = numTypeFigures*(iTime - 1)+1;
  figure(idFigure)
  plotGNDsMap(ebsdGrid, grains, rho, 1.0e11, 3.0e15);   

  %% 导出数据 - 1
  % Step 1: 导出包含rho信息的CTF格式文件
  outputFile = fullfile(dataPath, sprintf('GNSNi_%dmin_%s_rho.ctf', timePoints(iTime), baseName));
  export_ctf(ebsdGrid, rho, outputFile); 

  % Step 2: 导出ANG格式文件供Dream3D使用
  outputFile = fullfile(outputDataPath1, sprintf('GNSNi_%dmin_%s.ang', timePoints(iTime), baseName));
  export_ang(ebsdGrid, outputFile);
end

% H:\Github\MyRhinoLab\scripts\p23-GNSNi-AGG-2024\20250522_getRhoFunc\p23_s1_calculateRho_0522.m


rho_temp = rho2(~isnan(rho2));
rho_temp = rho_temp(rho_temp<1.0e15);
rho_temp2 = rho_temp(rho_temp>1e4);
rho_mean = mean(rho_temp2)
figure(5)
hist(rho_temp2)

1.34e14
5.01e13
1.0e+12
0.7e12

grain_id = [90030,97443,61890,23709]
rho_select = rho3(grain_id)
mean(rho_select)

1.34e14, 5.01e13, 1.0e+12, 0.7e12 
a = 3.9231e+14, b = 3.6154e-03