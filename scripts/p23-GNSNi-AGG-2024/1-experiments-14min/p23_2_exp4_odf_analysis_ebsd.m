%% 脚本说明
% 创建时间：2024年4月20日
% 创建人：Pengwei
% 创建目的：该脚本用于加载经过降噪处理的EBSD数据，进行晶粒识别和平滑处理，并绘制IPF（Inverse Pole Figure）图。
% 该脚本适用于GNS-Ni合金的EBSD数据分析，时间点为10min、20min和30min的CTF数据。

close all;
clear;
clc;

% 定义晶体对称性
crystalSymmetry = {... 
  'notIndexed',... 
  crystalSymmetry('m-3m', [3.6 3.6 3.6], 'mineral', 'Ni-superalloy', 'color', [0.53 0.81 0.98])};

% Set plotting preferences: x-axis direction as east, z-axis as into the plane
setMTEXpref('xAxisDirection','east');
setMTEXpref('zAxisDirection','inOfPlane');  

SS = specimenSymmetry('orthorhombic');

%% 指定文件路径和时间点
dataPath = 'H:\Github\MyRhinoLabData\p23_GNSNi_AGG_2024\ebsd\b1_GNSNi_EX_EBSD_14min_106_20241026\ctf_initial_14mins\';

% 循环处理每个时间点的数据
for iLocal = 1:1 % length(Regions)
  % 构造输入文件路径
  inputFile = fullfile(dataPath, sprintf('GNSNi_14min_20241026_local%d.ctf', iLocal)); % 
  
  %% 导入数据
  ebsdData = EBSD.load(inputFile, crystalSymmetry, 'interface', 'ctf', ...
                      'convertSpatial2EulerReferenceFrame');

  % %
  % figure(iLocal)
  % plot(ebsdData, ebsdData.orientations);

  [grains, ebsdData] = identifyAndSmoothGrains(ebsdData, 2.0 * degree, 10, 20.0);

  CS = crystalSymmetry{2};
  SS = specimenSymmetry('orthorhombic');

  % phi1 = ebsdData('Ni-superalloy').orientations.phi1;
  % Phi = ebsdData('Ni-superalloy').orientations.Phi;
  % phi2 = ebsdData('Ni-superalloy').orientations.phi2;
  % oris = orientation.byEuler(phi1, Phi, phi2, CS, SS);

  % phi1 = grains('Ni-superalloy').meanOrientation.phi1;
  % Phi = grains('Ni-superalloy').meanOrientation.Phi;
  % phi2 = grains('Ni-superalloy').meanOrientation.phi2;
  % oris = orientation.byEuler(phi1, Phi, phi2, CS, SS);

  % odf
  % odf = calcDensity(oris);
  odf = calcDensity(grains('Ni-superalloy').meanOrientation);
  % odf = calcDensity(ebsdData('Ni-superalloy').orientations);
  % ss = specimenSymmetry('222');
  ss = specimenSymmetry('orthorhombic');
  odf.SS = ss;

  figure(iLocal)
  plot(odf);
  % plotSection(odf,'contourf', 'maxPhi1',pi/2);
  % plot(odf)

  % figure(iLocal)
  % plotSection(odf,'contourf',...
  % 'phi2', [0 10 20 30 40 50 60 70 80].*degree,...
  % 'layout',[5 2]);

  mtexColorMap WhiteJet
  mtexColorbar


  
end
% 脚本路径: H:\Github\MyRhinoLab\scripts\p23-GNSNi-AGG-2024\1-experiments-14min\p23_2_exp4_odf_analysis_ebsd.m