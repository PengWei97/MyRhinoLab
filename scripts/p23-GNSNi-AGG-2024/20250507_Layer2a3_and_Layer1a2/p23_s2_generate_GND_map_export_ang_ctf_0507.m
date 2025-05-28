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
outputDataPath1 = 'H:\Github\MyRhinoLabData\p23_GNSNi_AGG_2024\experiment2\PF_Initial\ang_excerpt\';
outputDataPath2 = 'H:\Github\MyRhinoLabData\p23_GNSNi_AGG_2024\experiment2\PF_Initial\png_GND\';

if ~exist(outputDataPath1, 'dir'), mkdir(outputDataPath1); end
if ~exist(outputDataPath2, 'dir'), mkdir(outputDataPath2); end

timePoints = [5.0, 10.0, 20.0, 30.0];  % 时间点（分钟）
numTypeFigures = 1;  % 每个时间点绘制的图像数量

maxAndMinGND = zeros(4,2);

baseName = {'Layer2a3_f0p5', '1f3_Layer2a3_f0p5', '35p_Layer2a3_f0p5', 'c1_Layer2a3_f0p5', 'Layer1_40p_f0p5', 'Layer2a3_29p_f0p5'};

% 循环处理每个时间点的数据
for iBaseName = length(baseName):length(baseName)
  for iTime = 2:2
    % clear rho ebsd ebsdGrid grains
    % 文件路径
    inputFile = fullfile(dataPath, sprintf('GNSNi_%dmin_%s.ctf', timePoints(iTime), baseName{iBaseName}));

    %% 导入数据
    ebsd = EBSD.load(inputFile, crystalSymmetry, 'interface', 'ctf', ...
                          'convertEuler2SpatialReferenceFrame');

    % 标识和平滑晶粒
    [xmin, xmax, ymin, ymax] = ebsd.extend();
    ebsd = ebsd(inpolygon(ebsd, [xmin,50,xmax-xmin,200-50]));
    % ebsd = ebsd(inpolygon(ebsd, [220,ymin,50,50]));
    % ebsd = ebsd(inpolygon(ebsd, [220,ymin,420-220,ymax-ymin]));
    [grains, ebsd] = identifyAndSmoothGrains(ebsd, 2.0 * degree, 50, 3.0);

    
    % %% 计算GND（几何必要位错）图
    % ebsdGrid = ebsd('indexed').gridify;
    % rho = calculatedFCCGNDs(ebsdGrid);
    
    % mask = rho < 1.0e10;
    % randomValues = 1.0e11 + (1.0e14 - 1.0e11) * rand(sum(mask(:)), 1);
    % rho(mask) = randomValues;
    
    % % 绘制GND图
    % idFigure = numTypeFigures*(iTime - 1)+1;
    % figure(idFigure)
    % plotGNDsMap(ebsdGrid, grains, rho, 1.0e11, 3.0e15);  
    % outputFile = fullfile(outputDataPath2, sprintf('GNSNi_%dmin_%s_GND.png', timePoints(iTime), baseName{iBaseName}));
    % print(gcf, outputFile, '-dpng', '-r1200');     

    % rho_selet = rho(rho>1e3);
    % maxAndMinGND(iTime,1) = max(rho_selet);
    % maxAndMinGND(iTime,2) = min(rho_selet);

    % %% 导出数据 - 1
    % % Step 1: 导出包含rho信息的CTF格式文件
    % outputFile = fullfile(dataPath, sprintf('GNSNi_%dmin_%s_rho.ctf', timePoints(iTime), baseName{iBaseName}));
    % export_ctf(ebsdGrid, rho, outputFile); 

    % % Step 2: 导出ANG格式文件供Dream3D使用
    % outputFile = fullfile(outputDataPath1, sprintf('GNSNi_%dmin_%s.ang', timePoints(iTime), baseName{iBaseName}));
    % export_ang(ebsdGrid, outputFile);
  end
end

% H:\Github\MyRhinoLab\scripts\p23-GNSNi-AGG-2024\20250507_Layer2a3_and_Layer1a2\p23_s2_generate_GND_map_export_ang_ctf_0507.m


