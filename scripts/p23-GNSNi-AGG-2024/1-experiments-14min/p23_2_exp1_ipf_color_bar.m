% 

close all;
clear;
clc;


% 定义晶体对称性
crystalSymmetry = {... 
  'notIndexed',... 
  crystalSymmetry('m-3m', [3.6 3.6 3.6], 'mineral', 'Ni-superalloy', 'color', [0.53 0.81 0.98])};


% 设置绘图的坐标轴方向
setMTEXpref('xAxisDirection','east');
setMTEXpref('zAxisDirection','inOfPlane');

dataPath = 'H:\Github\MyRhinoLabData\p23_GNSNi_AGG_2024\ebsd\b1_GNSNi_EX_EBSD_14min_106_20241026\ctf2_stages_14mins\';
inputFile = fullfile(dataPath, 'GNSNi2_14min_Stage1_local1a5.ctf');

%% 导入数据
ebsdData = EBSD.load(inputFile, crystalSymmetry, 'interface', 'ctf', ...
                    'convertEuler2SpatialReferenceFrame');

% 
ipfKey=ipfColorKey(ebsdData('Ni-superalloy'));
plot(ipfKey)

% H:\Github\MyRhinoLab\scripts\p23-GNSNi-AGG-2024\1-experiments-14min\p23_2_exp1_ipf_color_bar.m