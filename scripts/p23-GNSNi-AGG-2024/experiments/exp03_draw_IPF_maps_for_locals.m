close all;
clear;
clc;

% Define crystal symmetry
crystalSymmetry = {...
  'notIndexed',...
  crystalSymmetry('m-3m', [3.6 3.6 3.6], 'mineral', 'Ni-superalloy', 'color', [0.53 0.81 0.98])};

% Set plotting convention
setMTEXpref('xAxisDirection', 'west');
setMTEXpref('zAxisDirection', 'outOfPlane');

%% Specify File Names
dataPath = '.\data\p23_GMSNi_AGG_2024\exp_data\ebsd_ctf\';
timePoints = [5.0, 10.0, 20.0, 30.0];

boxSizes = [243.6548, 219.1445, 211.9289, 177.3210;
572.3350,  218.7275, 203.0457, 177.3323;
111.8170,  256.2368, 106.7344, 139.5349;
386.2770,  216.9133, 231.2579, 178.8584;
645.0, 218.0, 105, 105];

numTypeFigures = 2;
gbs_length = zeros(4, 6);
for iTime = 2:2 % 1:length(timePoints)
    % Path to files
    inputFile = fullfile(dataPath, sprintf('Ni_%dmin_excerpt.ctf', timePoints(iTime)));
    
    %% Import the Data
    ebsdData = EBSD.load(inputFile, crystalSymmetry, 'interface', 'ctf', ...
                         'convertEuler2SpatialReferenceFrame');

    for iLocals = 5:5
      ebsdLocal = ebsdData(inpolygon(ebsdData, [boxSizes(iLocals, 1), boxSizes(iLocals, 2), boxSizes(iLocals, 3), boxSizes(iLocals, 4)]))
      [grains, ebsdLocal] = identifyAndSmoothGrains(ebsdLocal, 2.0 * degree, 10, 3.0);
      
      idFigure = numTypeFigures*(iLocals-1)+1;
      plotIPFMap(idFigure, ebsdLocal, grains);

      deltaMisor = 5*degree;
      gB = grains.boundary('Ni-superalloy', 'Ni-superalloy');
      gB3 = gB(gB.isTwinning(CSL(3, ebsdLocal.CS), deltaMisor));
      gB5 = gB(gB.isTwinning(CSL(5,ebsdLocal.CS), deltaMisor));
      gB7 = gB(gB.isTwinning(CSL(7,ebsdLocal.CS), deltaMisor));
      gB9 = gB(gB.isTwinning(CSL(9,ebsdLocal.CS), deltaMisor));
      gB11 = gB(gB.isTwinning(CSL(11,ebsdLocal.CS), deltaMisor));
      
      idFigure = numTypeFigures*(iLocals-1)+2;
      figure(idFigure)
      plot(grains.boundary, 'lineColor', 'black', 'linewidth', 0.5, 'micronbar', 'off')
      hold on
      plot(gB3, 'lineColor', 'gold', 'linewidth', 2, 'DisplayName', 'CSL 3');
      hold on
      plot(gB5, 'lineColor', 'b', 'linewidth', 2, 'DisplayName', 'CSL 5');
      hold on
      plot(gB7, 'lineColor', 'g', 'linewidth', 2, 'DisplayName', 'CSL 7');
      hold on
      plot(gB9, 'lineColor', 'm', 'linewidth', 2, 'DisplayName', 'CSL 9');
      hold on
      plot(gB11, 'lineColor', 'c', 'linewidth', 2, 'DisplayName', 'CSL 11');    


      % gb length
      gB_length = sum(segLength(gB));
      gB3_length = sum(segLength(gB3));
      gB5_length = sum(segLength(gB5));
      gB7_length = sum(segLength(gB7));
      gB9_length = sum(segLength(gB9));
      gB11_length = sum(segLength(gB11));

      gbs_length(iTime, :) = [gB_length, gB3_length, gB5_length, gB7_length, gB9_length, gB11_length];
    end
end


% E:\Github\MyRhinoLab\scripts\p23-GNSNi-AGG-2024\experiments\exp03_draw_IPF_maps_for_locals.m