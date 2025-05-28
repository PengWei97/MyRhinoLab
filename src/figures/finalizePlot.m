function finalizePlot(params, titles)
  % finalizePlot Apply final customizations to the plot.
  % This function sets titles, labels, and legend properties, and
  % adjusts the overall plot dimensions and background color.
  %
  % Inputs:
  %   params - Struct containing final plot customization parameters
  %            such as font size, labels, and plot dimension.
  %   titles{1} - String, label for the x-axis.
  %   titles{2} - String, label for the y-axis.

  xlabel(titles{1}, 'FontSize', params.fontSizeLabelTitle, ...
      'FontWeight', 'bold', 'Color', 'k', 'FontName', 'Times New Roman');
  ylabel(titles{2}, 'FontSize', params.fontSizeLabelTitle, ...
      'FontWeight', 'bold', 'Color', 'k', 'FontName', 'Times New Roman');
  legend('FontSize', params.fontSizeLegend, 'TextColor', 'black' ,'FontName', 'Times New Roman',...
      'Location', 'northeast', 'NumColumns', 1, 'LineWidth', 1.0);
  set(gcf, 'Unit', 'centimeters', 'Position', [10, 10, params.width, params.height], 'Color', 'None');
  set(gca, 'Color', 'None'); % Set axes background color to transparent
end