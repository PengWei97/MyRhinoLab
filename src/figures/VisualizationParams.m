classdef VisualizationParams
  properties
      fontSizeXY = 16;
      fontSizeLegend = 18;
      fontSizeLabelTitle = 18;
      lineWidth = 2.0;
      colors;
      lineStyles;
      markers;
      markerSize = 8;
      width = 15;
      height = 12;
  end
  
  methods
      function obj = VisualizationParams()
          obj.colors = {'#0085c3','#14d4f4','#f2af00','#b7295a','#00205b','#009f4d','#84bd00','#efdf00','#e4002b','#a51890',...
                        '#0085c3','#14d4f4','#f2af00','#b7295a','#00205b','#009f4d','#84bd00','#efdf00','#e4002b','#a51890'};
          obj.lineStyles = {'-', '--', ':', '-.','-', '--', ':', '-.','-', '--', ':', '-.'}; % '-' (默认值) | '--' | ':' | '-.' | 'none'
          obj.markers = {'o','>','s','h','p','*','^','v','d','<'};
      end
  end
end