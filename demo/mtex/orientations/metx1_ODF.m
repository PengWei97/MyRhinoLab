% cs = crystalSymmetry('432')
% ss = specimenSymmetry('222')


% ori = orientation.rand(100,cs,ss)

% % as phi2 sections
% plotSection(ori,'phi2')

cs = crystalSymmetry.load('Al-Aluminum.cif')

ori1 = orientation.brass(cs);
ori2 = orientation.copper(cs);
f = fibre.beta(cs);

odf = 0.2*unimodalODF(ori1) + ...
      0.3*unimodalODF(ori2) + ...
      0.5*fibreODF(f)

plot(odf,'sections',9,'layout',[4 3]) % 'silent',

% H:\Github\MyRhinoLab\demo\mtex\orientations\metx1_ODF.m