function plotGNDsMap(ebsd, grains, rho, minRho, maxRho)
  % plotIPFMap Display an Inverse Pole Figure (IPF) map with grain boundaries.
  %
  % This function creates a figure to display the IPF color mapping of an EBSD dataset
  % and overlays the grain boundaries. This visualization is useful for analyzing the
  % crystallographic orientation and grain structure in materials science.
  %
  % Inputs:
  %   index - Integer, the figure index to ensure figures are not overwritten.
  %   ebsd - EBSD dataset, contains crystallographic orientation data.
  %   grains - Grains dataset, contains information about grain boundaries.
  %
  % The function creates a plot without coordinates and a micron bar, focusing
  % on the orientation data and grain boundaries for clarity.
  %
  % Example:
  %   plotIPFMap(1, ebsdData, grainsData);

  % Plot the EBSD data showing crystallographic orientations
  plot(ebsd, rho, 'coordinates', 'off', 'micronbar', 'off');
  mtexColorMap('jet');
  set(gca, 'ColorScale', 'log');
  set(gca, 'CLim', [minRho, maxRho]);
  
  hold on;
  
  % Plot the grain boundaries with specified line width
  plot(grains.boundary, 'linewidth', 0.8);
  hold off;
end
