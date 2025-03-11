%% 脚本说明
% 创建时间：2024年4月20日
% 创建人：Pengwei
% 创建目的：该脚本用于加载经过降噪处理的EBSD数据，进行晶粒识别和平滑处理，并绘制IPF（Inverse Pole Figure）图。
% 该脚本适用于GNS-Ni合金的EBSD数据分析，时间点为10min、20min和30min的CTF数据。

close all;
clear;
clc;

inputDataPath = 'H:\Github\MyRhinoLabData\p23_GNSNi_AGG_2024\ebsd\b1_GNSNi_EX_EBSD_14min_106_20241026\2_csv_AGG_grains_Eulers\';
iData = 4;
inputFile2 = fullfile(inputDataPath, sprintf('stage%d_AGG_grains_Eulers.csv', iData));
dataTable = readtable(inputFile2);

phi1 = dataTable.phi1;
Phi = dataTable.Phi;
phi2 = dataTable.phi2;
CS = crystalSymmetry('m-3m', [3.6 3.6 3.6], 'mineral', 'Ni-superalloy', 'color', [0.53 0.81 0.98]);
SS = specimenSymmetry('orthorhombic');
ori = orientation.byEuler(phi1 * degree, Phi * degree, phi2 * degree, CS, SS);
odf = calcDensity(ori);
plotSection(odf,'contourf');
mtexColorMap WhiteJet
mtexColorbar

% 脚本路径: H:\Github\MyRhinoLab\scripts\p23-GNSNi-AGG-2024\1-experiments-14min\p23_2_exp5_odf_analysis_Eulers.m