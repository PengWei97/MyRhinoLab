% % hist(log(dataCTF.Rho), 30);
% % [counts, centers] =  hist(log(dataCTF.Rho), 30);

% % grainID = [85406,230919,221726,164193,344494,150023]
% grainID = [303308,305354,288132]
% x = [1:1:length(grainID)]';
% rhos = rho(grainID)

% figure(10)
% scatter(x,log(rhos))

% % [3.090827350829369e+11, 6.440915258544196e+12]
% % [5198907413780.64, 45285361939521.8]
% % 

% 5.0e12,5.0e13
regionRho = [5.0e12,5.0e13];
aveRho = zeros(3,1);
std_value = zeros(3,1);
for iLevel = 1:3
  switch iLevel
    case 1
      selectRho = dataCTF.Rho(dataCTF.Rho<regionRho(1));
    case 2
      selectRho = dataCTF.Rho(dataCTF.Rho<regionRho(2) & dataCTF.Rho>regionRho(1));
    case 3
      selectRho = dataCTF.Rho(dataCTF.Rho>regionRho(2));
  end 
  
  aveRho(iLevel,1) = mean(selectRho);
  std_value(iLevel,1) = std(selectRho);
end