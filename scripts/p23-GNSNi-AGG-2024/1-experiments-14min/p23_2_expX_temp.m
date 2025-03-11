clear grainIDs Euler_anges
%% stage 3
% grainIDs = [407, 403, 436, 442];
% grainIDs = [424, 432, 426, 396, 412, 423];
% grainIDs = [406, 409, 410, 411, 362];
% grainIDs = [866, 879, 845, 881, 823, 776, 871, 759, 864, 861];
% grainIDs = [444, 459, 401, 427, 460];
% grainIDs = [502, 503, 490, 456, 505, 507];
grainIDs = [253, 258, 245, 260];

%% stage 4
% grainIDs = [424, 432, 426, 396, 412, 423];
% grainIDs = [316, 309, 288];
% grainIDs = [342, 343, 344, 236, 288, 195];
% grainIDs = [1058, 1062, 1063, 1064, 1067, 1071, 1073, 1077, 1078];

%% QIS-EBSD, 20min
grainIDs = [20, 52, 111, 49, 27, 139, 47, 46, 98, 69, 51, 37, 22];
Euler_anges = zeros(length(grainIDs), 3);
for igrainIDs = 1:length(grainIDs)
  grainID = grainIDs(igrainIDs);
  Euler_anges(igrainIDs, 1) = grains(grainID).meanOrientation.phi1/degree;
  Euler_anges(igrainIDs, 2) = grains(grainID).meanOrientation.Phi/degree;
  Euler_anges(igrainIDs, 3) = grains(grainID).meanOrientation.phi2/degree;
end
Euler_anges

% H:\Github\MyRhinoLab\scripts\p23-GNSNi-AGG-2024\1-experiments-14min\p23_2_expX_temp.m