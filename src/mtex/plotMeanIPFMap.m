function plotMeanIPFMap(index, grains)
  % plotMeanIPFMap Display an Inverse Pole Figure (IPF) map with grain boundaries.
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
  %   plotMeanIPFMap(1, ebsdData, grainsData);

  % Create a new figure or activate the existing figure with the given index
  figure(index);
  
  % Plot the EBSD data showing crystallographic orientations
  plot(grains, grains.meanOrientation, 'coordinates', 'off', 'micronbar', 'off');
  hold on;
  
  % Plot the grain boundaries with specified line width
  plot(grains.boundary, 'linewidth', 0.8);
  hold on
  
  % gB = grains.boundary('Ni-superalloy', 'Ni-superalloy');
  % hold on

  % plot(gB, gB.misorientation.angle./degree, 'linewidth', 6);
  % mtexColorMap jet
  % mtexColorbar('title','misorientation angle in degrees')
end
