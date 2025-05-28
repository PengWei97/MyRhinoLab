%% 清理环境
clc; clear; close all;

inputDataDir0 = 'H:\Github\MyRhinoLabData\p91_MgAlloy_SelectGG_2025\simulation\benchmark2_local2_100a100\GBMAniso\';
%% 设置数据路径和相关参数
simu_case = {'bk2_c1_GBIsotropy','bk2_c2_GBEAniso','bk2_c3_GBEAniso','bk3_c3_GBEAniso', 'bk2_c2_GBMAniso', 'bk2_c3_GBMAniso'}; 

% 确保输出目录存在
outputDataDir = 'H:\Github\MyRhinoLabData\p91_MgAlloy_SelectGG_2025\csv_kinetic\';
baseName = 'Mg_Gd_alloy';

if ~exist(outputDataDir, 'dir'), mkdir(outputDataDir); end

%% 遍历所有数据集
for i = length(simu_case):length(simu_case) 
    % 读取时间数据
    inputDataDir = fullfile(inputDataDir0, sprintf('csv_%s', simu_case{i}));
    timeDataTable = readtable(fullfile(inputDataDir, sprintf('out_%s.csv', simu_case{i})));
    numSteps = length(timeDataTable.time);

    % 初始化
    weightedRadiusList = zeros(numSteps, 3); % 三类晶粒
    grainNumList = zeros(numSteps, 3);
    grainAreaList = zeros(numSteps, 3);

    % 进度条
    hWaitbar = waitbar(0, sprintf('计算数据集 %d...', i));

    for stepIdx = 1:numSteps
        waitbar(stepIdx / numSteps, hWaitbar);
        grainVolFile = fullfile(inputDataDir, sprintf('out_%s_grain_volumes_%04d.csv', simu_case{i}, stepIdx));
        if ~isfile(grainVolFile), continue; end

        % 读取数据
        data = readtable(grainVolFile);
        grainType = round(data.grain_type);
        grainAreas = data.feature_volumes;

        % 初始化存储结构
        grainAreas_Group = cell(3, 1);

        % 循环筛选不同类型的区域并去除非正值
        for iGrainGroup = 1:3
            grainAreas_Group{iGrainGroup} = grainAreas(grainType == iGrainGroup & grainAreas > 0);
            grainNumList(stepIdx, iGrainGroup) = length(grainAreas_Group{iGrainGroup});
            grainAreaList(stepIdx, iGrainGroup) = sum(grainAreas_Group{iGrainGroup});

            if sum(grainAreas_Group{iGrainGroup}) > 0
                grainRadii = sqrt(grainAreas_Group{iGrainGroup} ./ pi);
                weightedRadiusList(stepIdx, iGrainGroup) = sum(grainAreas_Group{iGrainGroup} .* grainRadii) / sum(grainAreas_Group{iGrainGroup});
            else
                weightedRadiusList(stepIdx, iGrainGroup) = NaN;
            end
        end
    end

    close(hWaitbar);

    % 输出数据到CSV
    for j = 1:3
        outputFiles = sprintf('%s_%s_type%d_kinetic.csv', baseName, simu_case{i}, j);
        writetable(table(timeDataTable.time, weightedRadiusList(:,j), grainNumList(:,j), grainAreaList(:,j), 'VariableNames', {'Time', 'WeightedMeanRadius', 'grainNums', 'grainArea'}), ...
                   fullfile(outputDataDir, outputFiles));
    end
    fprintf('数据集 %d 计算完成\n', i);
end

% H:\Github\MyRhinoLab\scripts\prm9-cooperate\p91-MgAlloy-SelectGG-2025\20250509_simulations\p91_s2_get_kinetics_grain_type.m
