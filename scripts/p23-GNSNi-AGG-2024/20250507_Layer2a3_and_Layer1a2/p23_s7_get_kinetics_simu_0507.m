%% 清理环境
clc; clear; close all;

%% 设置数据路径和相关参数
simu_case = {'bk2_c7_t4','bk2_c7_t2','bk2_c7_t3','bk2_c8_t1'};

inputDataDir0 = 'H:\Github\MyRhinoLabData\p23_GNSNi_AGG_2024\simulation2\benchmark2_35p_layer2a3\';

% 确保输出目录存在
outputDataDir = 'H:\Github\MyRhinoLabData\p23_GNSNi_AGG_2024\simulation2\csv_kinetic\';

if ~exist(outputDataDir, 'dir'), mkdir(outputDataDir); end

%% 遍历所有数据集
for i = length(simu_case):length(simu_case) % length(simu_case)
    % 读取时间数据
    inputDataDir = fullfile(inputDataDir0, sprintf('csv_%s', simu_case{i}));
    timeDataTable = readtable(fullfile(inputDataDir, sprintf('out_%s.csv', simu_case{i})));
    numSteps = length(timeDataTable.time);
    weightedRadiusList = zeros(numSteps, 1);
    
    % 进度条
    hWaitbar = waitbar(0, sprintf('计算数据集 %d...', i));
    
    for stepIdx = 1:numSteps
        waitbar(stepIdx / numSteps, hWaitbar);
        grainVolFile = fullfile(inputDataDir, sprintf('out_%s_grain_volumes_%04d.csv', simu_case{i}, stepIdx));
        % grainVolFile = fullfile(inputDataDir, sprintf(grainVolPatterns{i}, stepIdx));
        if ~isfile(grainVolFile), continue; end
        
        grainAreas = readtable(grainVolFile).feature_volumes;
        grainAreas = grainAreas(grainAreas > 0);
        
        if sum(grainAreas) > 0
            grainRadii = sqrt(grainAreas ./ pi);
            weightedRadiusList(stepIdx) = sum(grainAreas .* grainRadii) / sum(grainAreas);
        else
            weightedRadiusList(stepIdx) = NaN;
        end
    end
    
    close(hWaitbar);
    outputFiles = sprintf('GNSNi_kinetic_%s.csv', simu_case{i});
    writetable(table(timeDataTable.time, weightedRadiusList, 'VariableNames', {'Time', 'WeightedMeanRadius'}), ...
               fullfile(outputDataDir, outputFiles));
    fprintf('数据集 %d 计算完成\n', i);
end

% H:\Github\MyRhinoLab\scripts\p23-GNSNi-AGG-2024\20250507_Layer2a3_and_Layer1a2\p23_s7_get_kinetics_simu_0507.m