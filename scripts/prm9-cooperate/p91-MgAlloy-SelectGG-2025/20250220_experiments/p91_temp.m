mori = orientation.map(Miller(1,1,-2,0,CS_MgMg),Miller(2,-1,-1,0,CS_MgMg),...
  Miller(0,0,0,1,CS_MgMg,'uvw'),Miller(0,1,-1,0,CS_MgMg,'uvw'));

% the rotational axis
round(mori.axis)

% the rotational angle
mori.angle / degree

% H:\Github\MyRhinoLab\scripts\prm9-cooperate\p91-MgAlloy-SelectGG-2025\20250220_experiments\scripts\p91_temp.m