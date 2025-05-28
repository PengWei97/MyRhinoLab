function [grains, ebsd] = identifyAndSmoothGrains(ebsd, threshold, smoothFactor, minGrainSize)
  % identifyAndSmoothGrains Perform grain identification and processing on EBSD data.
  %
  % This function calculates grains based on EBSD mapping data, smooths the grain boundaries,
  % and removes grains smaller than a specified size. The grains are recalculated and smoothed
  % again after the small grains are removed.
  %
  % Inputs:
  %   ebsd - EBSD dataset from which grains are to be calculated.
  %   threshold - Angular threshold for grain boundary detection.
  %   smoothFactor - Smoothing factor used for grain boundary smoothing.
  %   minGrainSize - Minimum grain size threshold; grains smaller than this are removed.
  %
  % Outputs:
  %   grains - Processed grains with smoothed boundaries and without small grains.
  %   ebsd - Updated EBSD dataset with grainId and misorientation to mean orientation.
  %
  % Example usage:
  %   [grains, updatedEbsd] = identifyAndSmoothGrains(ebsdData, 5*degree, 10, 5);

  fprintf('Running identifyAndSmoothGrains\n');

  % Initial grain calculation
  [grains, ebsd.grainId, ebsd.mis2mean] = calcGrains(ebsd, 'threshold',threshold, 'alpha',0.0, 'minPixel',1);

  % Smooth the grains
  grains = smooth(grains, smoothFactor);

  % Remove grains smaller than the specified minimum size
  ebsd(grains(grains.grainSize < minGrainSize)) = [];

  % Recalculate grains after removal of small grains
  [grains, ebsd.grainId, ebsd.mis2mean] = calcGrains(ebsd, 'threshold', threshold);

  % Smooth the grains again after recalculation
  grains = smooth(grains, smoothFactor);
end
