% % calculate the average grain size
% [xmin, xmax, ymin, ymax] = ebsdToRefine.extend();
% totalGrainArea = [xmax-xmin]*[ymax-ymin];
% totalPixelNum = sum(grainsToRefine.grainSize);
% grainAreas = grainsToRefine.grainSize .* totalGrainArea ./ totalPixelNum;
% GrainRadius = sqrt(grainAreas./pi);
% AveGrainRaidus = sum(GrainRadius .* grainAreas) / totalGrainArea;