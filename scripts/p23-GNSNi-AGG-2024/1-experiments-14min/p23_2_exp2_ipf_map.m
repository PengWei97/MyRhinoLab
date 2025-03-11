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

% 设置绘图的坐标轴方向
setMTEXpref('xAxisDirection','east');
setMTEXpref('zAxisDirection','inOfPlane');

%% 指定文件路径和时间点
dataPath = 'H:\Github\MyRhinoLabData\p23_GNSNi_AGG_2024\ebsd\b1_GNSNi_EX_EBSD_14min_106_20241026\ctf2_stages_14mins\';
% Regions = {'1a2', '1a5', '2a3', '3a1', '3a3', '4a1', '5a1', '5a3', '6a3', '7a1'};  % 时间点（分钟）
% Regions = {'1a5', '2a1', '2a3', '3a1', '3a3', '4a1', '5a1', '5a3', '6a3', '7a1'};  % stage-1
% Regions = {'1a5', '2a1', '2a3', '3a1', '3a3', '4a1', '5a1', '5a3', '6a3', '7a1'};  % stage-2
% Regions = {'1a1', '1a3', '2a4', '4a2', '4a22', '7a3', '7a4'};  % stage-3
Regions = {'3a2', '5a2', '6a1', '6a2', '8a1'};  % stage-4
% 循环处理每个时间点的数据
for iStage = 4:4  % 从第2个时间点开始处理（跳过5min）
  
  if iStage == 3
    Regions = {'1a1', '1a3', '2a4', '4a2', '4a22', '7a3', '7a4'};  % stage-3
  elseif iStage == 4
    Regions = {'3a2', '5a2', '6a1', '6a2', '8a1'};  % stage-4
  end
    for iLocal = 1:3 % length(Regions)
      % 构造输入文件路径
      inputFile = fullfile(dataPath, sprintf('GNSNi2_14min_Stage%d_local%s.ctf', iStage, Regions{iLocal}));
      
      %% 导入数据
      ebsdData = EBSD.load(inputFile, crystalSymmetry, 'interface', 'ctf', ...
                          'convertEuler2SpatialReferenceFrame');

      % 标识和平滑晶粒
      [xmin, xmax, ~, ~] = ebsdData.extend();
      ebsdData = ebsdData(inpolygon(ebsdData, [xmin, 13, xmax-xmin, 600]));
      [grains, ebsdData] = identifyAndSmoothGrains(ebsdData, 2.0 * degree, 10, 3.0);
      
      % 绘制IPF图（根据时间点进行编号）
      idFigure = iLocal;  
      figure(idFigure) % meanOrientation + grain id + arrow
      plot(grains, grains.meanOrientation, 'micronbar','off', 'coordinates','off');
      hold on 
      bigGrains = grains(grains.grainSize>500); % (grainsLocal.grainSize>1000)
      dir = bigGrains.meanOrientation * Miller(1,0,0,bigGrains.CS);
      len = 0.5.*bigGrains.diameter;
    
      quiver(bigGrains,len.*dir,'autoScale','off','color','white');
      text(bigGrains,int2str(bigGrains.id),'color','black');
      hold on
      
      [xmin,xmax,ymin,ymax] = ebsdData.extend();
      totalArea = (xmax-xmin)*(ymax-ymin);
      totalPiax = length(ebsdData);
      grainRadius = sqrt(grains.grainSize .*totalArea ./totalPiax ./pi);
      AGG_grains = grains(grainRadius > 40);

      AGG_grains.meanOrientation
    end
end

% 脚本路径: H:\Github\MyRhinoLab\scripts\p23-GNSNi-AGG-2024\1-experiments-14min\p23_2_exp2_ipf_map.m

% H:\Github\MyRhinoLabData\p23_GNSNi_AGG_2024\ebsd\b1_GNSNi_EX_EBSD_14min_106_20241026\ctf2_stages_14mins\GNSNi2_14min_Stage1_local1a5.ctf
% H:\Github\MyRhinoLabData\p23_GNSNi_AGG_2024\ebsd\b1_GNSNi_EX_EBSD_14min_106_20241026\ctf2_stages_14mins\GNSNi2_14min_Stage1_local1a2.ctf



% grains(690).meanOrientation