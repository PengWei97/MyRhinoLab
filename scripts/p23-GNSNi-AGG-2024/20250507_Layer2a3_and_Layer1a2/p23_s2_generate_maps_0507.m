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

% if ~exist(outputDataPath1, 'dir'), mkdir(outputDataPath); end

timePoints = [5.0, 10.0, 20.0, 30.0];  % 时间点（分钟）
numTypeFigures = 8;  % 每个时间点绘制的图像数量
baseName = {'Layer2a3_f0p5', '1f3_Layer2a3_f0p5', '35p_Layer2a3_f0p5'};

% 循环处理每个时间点的数据
for ibaseName = 3:3
  for iTime = 3:3
    % 文件路径
    inputFile = fullfile(dataPath, sprintf('GNSNi_%dmin_%s.ctf', timePoints(iTime),baseName{ibaseName}));

    %% 导入数据
    ebsd = EBSD.load(inputFile, crystalSymmetry, 'interface', 'ctf', ...
                          'convertEuler2SpatialReferenceFrame');

    % 标识和平滑晶粒
    [xmin, xmax, ymin, ymax] = ebsd.extend();
    % ebsd = ebsd(inpolygon(ebsd, [0,0,50,50]));
    [grains, ebsd] = identifyAndSmoothGrains(ebsd, 2.0 * degree, 50, 3.0);

    %% 1 - IPF map
    idFigure = numTypeFigures*(iTime - 1)+1;
    figure(idFigure)
    plot(ebsd, ebsd.orientations, 'coordinates', 'off', 'micronbar', 'off');
    hold on
    plot(grains.boundary, 'linewidth', 0.8);
    hold off

    %% 2 - IPF map with Grain ID
    bigGrains = grains(grains.grainSize>500);
    dir = bigGrains.meanOrientation * Miller(1,0,0,bigGrains.CS);
    len = 0.5.*bigGrains.diameter;

    idFigure = numTypeFigures*(iTime - 1)+2;
    figure(idFigure)
    plot(grains, grains.meanOrientation, 'coordinates', 'off', 'micronbar', 'off');
    hold on
    quiver(bigGrains,len.*dir,'autoScale','off','color','white');
    text(bigGrains,int2str(bigGrains.id),'color','black');

    plot(grains.boundary, 'linewidth', 0.8);
    hold off
    
    %% 3 - GB map
    deltaMisor = 5 * degree;
    % Identify different types of grain boundaries
    gB = grains.boundary('Ni-superalloy', 'Ni-superalloy');  % All boundaries
    lAGB = gB(angle(gB.misorientation) < 15.0 * degree);     % Low-angle GBs (< 15°)
    hAGB = gB(angle(gB.misorientation) >= 15.0 * degree);    % High-angle GBs (≥ 15°)

    % Identify CSL boundaries with misorientation tolerance
    gB3 = gB(gB.isTwinning(CSL(3, ebsd.CS), deltaMisor)); % CSL Σ3
    gB9 = gB(gB.isTwinning(CSL(9, ebsd.CS), deltaMisor)); % CSL Σ9

    % Boundary types and corresponding plot settings
    boundaries = {hAGB, lAGB, gB3, gB9};
    colors = {'black', 'Indigo', 'red', 'blue'};
    widths = [2.0, 3.5, 3.0, 3.0];
    names = {'High-angle GBs', 'Low-angle GBs', 'CSL 3', 'CSL 9'};

    % Draw GB type map
    idFigure = numTypeFigures * (iTime - 1) + 3;
    figure(idFigure);

    % Loop through each boundary type and plot if not empty
    for i = 1:length(boundaries)
      hold on
      if ~isempty(boundaries{i})
          plot(boundaries{i}, 'lineColor', colors{i}, 'linewidth', widths(i), ...
              'DisplayName', names{i}, 'micronbar', 'off');
      end
    end
    legend off

    %% 4 - KAM map
    ebsdGrid = ebsd.gridify;
    kam = ebsdGrid.KAM / degree;
    idFigure = numTypeFigures * (iTime - 1) + 4;
    figure(idFigure);
    plot(ebsdGrid, kam,'micronbar', 'off')
    mtexColorbar
    mtexColorMap WhiteJet
    set(gca, 'CLim', [0 5]);
    hold on
    plot(grains.boundary,'lineWidth',1.5)
    hold off  

    %% 5 - GOS distribution
    mis2mean = calcGROD(ebsd, grains);
    GOS = ebsd.grainMean(mis2mean.angle);
    % draw GOS distribution
    idFigure = numTypeFigures * (iTime - 1) + 5;
    figure(idFigure);
    plot(grains, GOS ./ degree, 'micronbar', 'off', 'coordinates', 'off'); % 
    % mtexColorbar('title','GOS in degree');
    set(gca, 'CLim', [0 10]);
    mtexColorMap WhiteJet
    mtexColorbar
    hold on;
    plot(grains.boundary, 'linewidth', 0.8);
    hold off;

    %% 6 - PF for EBSD
    odf = calcDensity(ebsd.orientations);
    idFigure = numTypeFigures * (iTime - 1) + 6;
    figure(idFigure);
    plotPDF(odf, Miller({1,0,0},{1,1,0},{1,1,1},crystalSymmetry{2})); % ,{3,1,1}

    %% 7 - IPF for EBSD
    idFigure = numTypeFigures * (iTime - 1) + 7;
    figure(idFigure);
    plotIPDF(odf,[xvector,yvector,zvector]);

    %% 8 - PF for EBSD
    odfGrain = calcDensity(grains.meanOrientation);
    idFigure = numTypeFigures * (iTime - 1) + 8;
    figure(idFigure);
    plotPDF(odfGrain, Miller({1,0,0},{1,1,0},{1,1,1},crystalSymmetry{2})); % ,{3,1,1}

    %% 9 - IPF for EBSD
    idFigure = numTypeFigures * (iTime - 1) + 9;
    figure(idFigure);
    plotIPDF(odfGrain,[xvector,yvector,zvector]);  
  end
end
% H:\Github\MyRhinoLab\scripts\p23-GNSNi-AGG-2024\20250507_Layer2a3_and_Layer1a2\p23_s2_generate_maps_0507.m


