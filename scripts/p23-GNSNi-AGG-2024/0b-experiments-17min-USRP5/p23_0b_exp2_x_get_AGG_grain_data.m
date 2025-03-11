close all
clc

outputFileDir = 'H:\Github\MyRhinoLabData\p23_GNSNi_AGG_2024\ebsd\USRP5_17min_20250302\csv_AGG_data\';

for iRegion = 8:8

  switch iRegion
    case 1
      selects_AGG_grains = [506, 442, 516, 514, 554, 575, 450, 655];
    case 2
      selects_AGG_grains = [378, 612, 425, 421, 511, 371, 578, 673, 589];
    case 3
      selects_AGG_grains = [328, 269, 210, 209, 240, 146, 150, 187, 153, 280, 260];
    case 4
      selects_AGG_grains = [626, 592, 572, 549, 810, 775, 709, 604, 561, 571, 551, 771];
    case 5
      selects_AGG_grains = [408, 625, 398, 290, 339];
    case 6
      selects_AGG_grains = [968, 975, 942, 1033, 862, 1321, 989, 870, 908, 1087];
    case 7
      selects_AGG_grains = [447, 594, 432, 444, 511, 485, 625, 813, 617, 725];
    case 8
      selects_AGG_grains = [1084, 1331, 1063, 1048, 935, 972, 1150, 936, 1009, 1778, 1065];
  end

  numGrains = length(selects_AGG_grains);
  AGGData = zeros(numGrains, 5);

  [xmin, xmax, ymin, ymax] = ebsdData.extend();
  pixel2Area = (xmax - xmin) * (ymax - ymin) / length(ebsdData);

  for iGrain = 1:numGrains
    grainID = selects_AGG_grains(iGrain);
    phi1 = grains(grainID).meanOrientation.phi1 / degree;
    Phi = grains(grainID).meanOrientation.Phi / degree;
    phi2 = grains(grainID).meanOrientation.phi2 / degree;
    grainSize = grains(grainID).grainSize / pixel2Area;

    AGGData(iGrain, :) = [grainID, phi1, Phi, phi2, grainSize];
  end

  % 创建表格
  T = array2table(AGGData, 'VariableNames', {'grainID', 'phi1', 'Phi', 'phi2', 'grainSize'});

  outputFile = fullfile(outputFileDir, sprintf('R%d_AGG_data.csv', iRegion));
  % 保存为CSV文件
  writetable(T, outputFile);
end

% H:\Github\MyRhinoLab\scripts\p23-GNSNi-AGG-2024\0b-experiments-17min-USRP5\p23_0b_exp2_x_get_AGG_grain_data.m