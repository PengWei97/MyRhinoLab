close all
clear
clc

cs = crystalSymmetry('m-3m');
ss = specimenSymmetry('orthorhombic');

components = [...
  orientation.goss(cs,ss),...
  orientation.brass(cs,ss),...
  orientation.cube(cs,ss),...
  orientation.cubeND22(cs,ss),...
  orientation.cubeND45(cs,ss),...
  orientation.cubeRD(cs,ss),...
  orientation.copper(cs,ss),...
  orientation.PLage(cs,ss),...
  orientation.QLage(cs,ss),...
  ];

close all
for i = 1:length(components)
  plotSection(components(i), 'add2all', 'MarkerColor', ind2color(i),...
    'DisplayName', round2Miller(components(i),'LaTex'))
end
  
legend('show','interpreter','LaTeX','location','southeast','FontSize',1.2*getMTEXpref('FontSize'));

% plotx2north
% h = Miller({1,0,0},{1,1,0},{1,1,1},{3,1,1},cs);

% close all
% for i = 1:length(components)
%   plotPDF(components(i),h,'MarkerSize',10,'MarkerColor', ind2color(i),...
%     'DisplayName',round2Miller(components(i),'LaTex'))
%   hold on
% end
% hold off

% legend('show','interpreter','LaTeX','location','northeast','numColumns',2,'FontSize',1.2*getMTEXpref('FontSize'));

% r = [vector3d.X,vector3d.Y,vector3d.Z];

% close all
% for i = 1:length(components)
%   plotIPDF(components(i),r,'MarkerSize',(12-i)^1.5,'MarkerColor', ind2color(i),...
%     'DisplayName',round2Miller(components(i),'LaTex'))
%   hold on
% end
% hold off

% legend('show','interpreter','LaTeX','location','northeast','numColumns',2,'FontSize',1.2*getMTEXpref('FontSize'));

% H:\Github\MyRhinoLab\scripts\p23-GNSNi-AGG-2024\0b-experiments-17min-USRP5\p23_0b_exp2_z_orientation_standard.m