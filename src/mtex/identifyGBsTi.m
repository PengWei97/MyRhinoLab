% identifyGBs.m
%
% Purpose:
% This function identifies various types of grain boundaries within a given grains and EBSD dataset.
% It identifies twin boundaries, low angle grain boundaries, and high angle grain boundaries.
%
% Inputs:
% - grains: The grains dataset
% - ebsd: The EBSD dataset
%
% Outputs:
% - twinBoundary1: Identified twin boundaries of the first type
% - twinBoundary2: Identified twin boundaries of the second type
% - LowAngleGB: Identified low angle grain boundaries
% - highAngleGB: Identified high angle grain boundaries

function [twinBoundary1, twinBoundary2, twinBoundary3, twinBoundary4, LowAngleGB, highAngleGB] = identifyGBsTi(grains, ebsd)
  % Extract grain boundaries
  gB = grains.boundary;
  
  % Filter grain boundaries for specific phase
  gB_TiTi = gB('Ti-Hex', 'Ti-Hex');
  
  % Define twinning orientations
  twinning1 = orientation.byAxisAngle(Miller({1 1 -2 0}, ebsd.CS), 85 * degree); % tensile twin
  twinning2 = orientation.byAxisAngle(Miller({1 0 -1 0}, ebsd.CS), 65 * degree); % compression twin
  twinning3 = orientation.byAxisAngle(Miller({1 0 -1 0},ebsd.CS), 35.10*degree); % tensile twin - v2
  twinning4 = orientation.byAxisAngle(Miller({1 1 -2 0},ebsd.CS), 57.05*degree); % compression twin - v2
  twinning = [twinning1, twinning2, twinning3, twinning4];
  
  % Define tolerance for misorientation
  toleranceMis = 3.90 * degree;
  
  % Identify twin boundaries
  isTwinning1 = angle(gB_TiTi.misorientation, twinning(1)) < toleranceMis;
  isTwinning2 = angle(gB_TiTi.misorientation, twinning(2)) < toleranceMis;
  isTwinning3 = angle(gB_TiTi.misorientation,twinning(3)) < toleranceMis;
  isTwinning4 = angle(gB_TiTi.misorientation,twinning(4)) < toleranceMis;

  % Identify low angle and high angle grain boundaries
  isLowAngleGB = angle(gB_TiTi.misorientation) < 15.0 * degree;
  isHighAngleGB = angle(gB_TiTi.misorientation) >= 15.0 * degree;
  
  % Assign identified boundaries to output variables
  twinBoundary1 = gB_TiTi(isTwinning1);
  twinBoundary2 = gB_TiTi(isTwinning2);
  twinBoundary3 = gB_TiTi(isTwinning3);
  twinBoundary4 = gB_TiTi(isTwinning4);
  LowAngleGB = gB_TiTi(isLowAngleGB);
  highAngleGB = gB_TiTi(isHighAngleGB);
end
