% % 定义晶体对称性（以HCP结构为例，Mg）
% CS = crystalSymmetry('6/mmm', [3.21, 3.21, 5.21], 'mineral', 'Mg', 'color', 'light blue');

% 定义欧拉角（Bunge 角度，单位为度）
eulerAngles = [55.8, 136.4, 43.8]; % [phi1, Phi, phi2]

% 创建取向对象（晶体坐标系到样品坐标系）
o = orientation('Euler', eulerAngles(1)*degree, eulerAngles(2)*degree, eulerAngles(3)*degree, CS{2});
zDir = vector3d.Z;

% 定义晶面法向向量（在晶体坐标系中）
h = Miller(1, 0, -1, 2, CS{2}); % {1 0 -1 2}
symH = o * symmetrise(h);  % 输出是vector3d数组
angles = angle(symH, zDir)./degree;

min(angles)

% % 将晶面法向量转换为样品坐标系下的方向
% n_sample = o * h;

% % z轴方向（样品坐标系）
% z_axis = vector3d.Z;

% % 计算夹角（单位为度）
% angleToZ = angle(n_sample, z_axis) / degree;

% % 显示结果
% disp(['Angle between {10-12} plane normal and Z-axis: ', num2str(angleToZ), ' degrees']);

% H:\Github\MyRhinoLab\scripts\prm9-cooperate\p91-MgAlloy-SelectGG-2025\p91_temp.m

% planeNormal = Miller({1,0,-1,2},CS{2});
% zDir = vector3d.Z; % ND方向，也可以用 vector3d(0,1,0) 表示 TD，vector3d.X 表示 RD
% angles = zeros(length(grains),1);
% for iGrain = 1:length(grains)
%   crystalDirections = grains(iGrain).meanOrientation * symmetrise(planeNormal);
%   angles(iGrain) = min(angle(crystalDirections, zDir)./degree);
% end

% redGrain = grains(angles < 10.0);