%% 清理环境
clc; clear; close all;

inputDataDir0 = 'H:\Github\MyRhinoLabData\p91_MgAlloy_SelectGG_2025\simulation\';
%% 设置数据路径和相关参数
simu_case = {'bk1_c1_isotropy'};

% 确保输出目录存在
outputDataDir = 'H:\Github\MyRhinoLabData\p91_MgAlloy_SelectGG_2025\csv_kinetic\';
baseName = 'Mg_Gd_alloy';

if ~exist(outputDataDir, 'dir'), mkdir(outputDataDir); end

%% 遍历所有数据集
for i = 1:1 % length(simu_case) % length(simu_case)
    % 读取时间数据
    inputDataDir = fullfile(inputDataDir0, sprintf('csv_%s', simu_case{i}));
    timeDataTable = readtable(fullfile(inputDataDir, sprintf('out_%s.csv', simu_case{i})));
    numSteps = length(timeDataTable.time);
    weightedRadiusList = zeros(numSteps, 1);
    grainNumList = zeros(numSteps, 1);
    
    % 进度条
    hWaitbar = waitbar(0, sprintf('计算数据集 %d...', i));
    
    for stepIdx = 1:20 % numSteps
        waitbar(stepIdx / numSteps, hWaitbar);
        grainVolFile = fullfile(inputDataDir, sprintf('out_%s_grain_volumes_%04d.csv', simu_case{i}, stepIdx));
        % grainVolFile = fullfile(inputDataDir, sprintf(grainVolPatterns{i}, stepIdx));
        if ~isfile(grainVolFile), continue; end
        
        grainAreas = readtable(grainVolFile).feature_volumes;
        grainAreas = grainAreas(grainAreas > 0);
        grainNumList(stepIdx) = length(grainAreas(grainAreas>0));

        if sum(grainAreas) > 0
            grainRadii = sqrt(grainAreas ./ pi);
            weightedRadiusList(stepIdx) = sum(grainAreas .* grainRadii) / sum(grainAreas);
        else
            weightedRadiusList(stepIdx) = NaN;
        end
    end
    
    close(hWaitbar);
    outputFiles = sprintf('%s_%s_kinetic.csv', baseName, simu_case{i});
    writetable(table(timeDataTable.time, weightedRadiusList, grainNumList, 'VariableNames', {'Time', 'WeightedMeanRadius', 'grainNums'}), ...
               fullfile(outputDataDir, outputFiles));
    fprintf('数据集 %d 计算完成\n', i);
end

% H:\Github\MyRhinoLab\scripts\prm9-cooperate\p91-MgAlloy-SelectGG-2025\20250509_simulations\p91_s1_get_kinetics.m