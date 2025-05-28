function fig = initPlot(index, params)
  % initPlot Initialize and configure the plot environment.
  % This function creates a figure with specified index and sets up
  % basic plot properties based on provided parameters.
  %
  % Inputs:
  %   index - Integer specifying the figure index.
  %   params - Struct containing visualization parameters such as
  %            font size, line width, and font name for plot axes.

  fig = figure(index);
  box on;
  hold on;
  set(gca, 'FontSize', params.fontSizeXY, ...
      'LineWidth', params.lineWidth, ...
      'FontName', 'Times New Roman');
end