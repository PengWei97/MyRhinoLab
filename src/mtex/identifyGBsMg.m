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

function [twinBoundary1, twinBoundary2, csl3, csl7, LowAngleGB, highAngleGB] = identifyGBsMg(grains, ebsd)
  % Extract grain boundaries
  gB = grains.boundary;
  
  % Filter grain boundaries for specific phase
  gb_MgMg = gB('Magnesium', 'Magnesium');
  
  % Define twinning orientations
  % twinning1 = orientation.byAxisAngle(Miller({1 -2 1 0}, ebsd.CS), 85 * degree); % tensile twin
  % twinning2 = orientation.byAxisAngle(Miller({1 -2 1 0}, ebsd.CS), 56 * degree); % compression twin
  twinning1 = orientation.byAxisAngle(Miller({1 -2 1 0}, ebsd.CS), 61.91 * degree); % tensile twin
  twinning2 = orientation.byAxisAngle(Miller({1 -2 1 0}, ebsd.CS), 75.06 * degree); % compression twin

  twinning = [twinning1, twinning2];
  
  % Define tolerance for misorientation
  toleranceMis = 3.90 * degree;
  
  % Identify twin boundaries
  isTwinning1 = angle(gb_MgMg.misorientation, twinning(1)) < toleranceMis;
  isTwinning2 = angle(gb_MgMg.misorientation, twinning(2)) < toleranceMis;

  % Identify low angle and high angle grain boundaries
  isLowAngleGB = angle(gb_MgMg.misorientation) < 15.0 * degree;
  isHighAngleGB = angle(gb_MgMg.misorientation) >= 15.0 * degree;
  
  % Assign identified boundaries to output variables
  twinBoundary1 = gb_MgMg(isTwinning1);
  twinBoundary2 = gb_MgMg(isTwinning2);
  csl3 = gb_MgMg(gb_MgMg.isTwinning(CSL(3, ebsd.CS), toleranceMis)); % CSL Σ3 (twin boundaries)
  csl7 = gb_MgMg(gb_MgMg.isTwinning(CSL(13, ebsd.CS), toleranceMis)); % CSL Σ3 (twin boundaries)
  LowAngleGB = gb_MgMg(isLowAngleGB);
  highAngleGB = gb_MgMg(isHighAngleGB);
end

