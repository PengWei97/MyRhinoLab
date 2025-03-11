%% 脚本说明
% 创建时间：2024年4月20日
% 创建人：Pengwei
% 创建目的：该脚本用于处理降噪后的GNSNi数据，调整基于INL（内部局部误差）和CTF（晶体方位分布）数据的rho值，并将处理后的数据输出为CSV文件。
% 该脚本适用于GNS-Ni合金的实验数据分析，时间点包括5min、10min、20min和30min。

%% 代码开始
close all;
clear;
clc;

%% 设置文件路径和参数
dataPath = 'H:\Github\MyRhinoLabData\p23_GNSNi_AGG_2024\ebsd\USRP5_17min_20250302\temp\';  % 输入数据路径

% 处理每个指定的时间点
for iRegion = 3:3
    % 读取INL和CTF数据
    dataINL = readtable(fullfile(dataPath, sprintf('S1_20250302_USPR5_17min_R%d_excerpt_bm2_inl.csv', iRegion)));
    dataCTF = readtable(fullfile(dataPath, sprintf('S1_20250302_USPR5_17min_R%d_excerpt_with_rho_bm2_ctf.csv', iRegion)));
 
    % 确定rho值的临界范围，用于过滤
    minCriticalRho = min(dataCTF.Rho(dataCTF.Rho > 100)) - 10;
    maxCriticalRho = max(dataCTF.Rho);

    % 可视化Rho分布
    plotRhoDistributions(dataINL, dataCTF);    

    % 基于特征调整rho值
    dataCTF = adjustRhoValues(dataINL, dataCTF, minCriticalRho, maxCriticalRho);

    % 可视化调整后的Rho分布
    plotRhoDistributions(dataINL, dataCTF);
    
    % 输出调整后的数据
    outputAdjustedData(dataINL, dataCTF, dataPath, iRegion);
end

%% 函数：可视化Rho分布
function plotRhoDistributions(dataInl, dataCtf)
    % 绘制INL数据和CTF数据中的log-scaled Rho值分布图

    % 绘制INL数据的Rho分布
    figure;
    scatter(dataInl.x, dataInl.y, 20, log(dataCtf.Rho), 'filled');
    title('Log-scaled Rho values from INL data');
    colorbar;

    % 绘制CTF数据的Rho分布
    figure;
    scatter(dataCtf.X, dataCtf.Y, 20, log(dataCtf.Rho), 'filled');
    title('Log-scaled Rho values from CTF data');
    colorbar;
end

%% 函数：根据特征调整Rho值
function dataCtf = adjustRhoValues(dataInl, dataCtf, minCriticalRho, maxCriticalRho)
    % 根据晶粒特征调整CTF数据中的Rho值

    for iFeature = 1:max(dataInl.FeatureId)
        % 获取指定特征的Rho值
        rhoGrain = dataCtf.Rho(dataInl.FeatureId == iFeature);
        rhoFiltered = rhoGrain(rhoGrain > minCriticalRho);

        % 如果没有有效的Rho值，则设置为最大Rho值
        if isempty(rhoFiltered)
            dataCtf.Rho(dataInl.FeatureId == iFeature) = maxCriticalRho;
            continue;
        end

        % 计算特征区域的平均Rho，并调整低于临界值的Rho
        rhoAverage = max(mean(rhoFiltered), minCriticalRho);
        indices = find(dataInl.FeatureId == iFeature);
        dataCtf.Rho(indices(dataCtf.Rho(indices) < minCriticalRho)) = rhoAverage;
        dataCtf.Rho(isnan(dataCtf.Rho(indices))) = maxCriticalRho;
    end

    % 对于所有Rho小于临界值的区域，设置为最大Rho值
    dataCtf.Rho(dataCtf.Rho < minCriticalRho) = maxCriticalRho;
    return
end

%% 函数：输出调整后的数据
function outputAdjustedData(dataInl, dataCtf, outputPath, timePoint)
    % 输出调整后的数据为CSV文件

    dataOutput = dataInl;
    fieldsToConvert = {'phi1', 'PHI', 'phi2', 'x', 'y', 'z'};  % 需要转换的字段
    precisions = {'%.6f', '%.6f', '%.6f', '%.6f', '%.6f', '%.2f'};  % 输出精度

    % 将指定字段转换为字符串格式
    for iVariable = 1:length(fieldsToConvert)
        dataOutput.(fieldsToConvert{iVariable}) = strtrim(cellstr(num2str(dataInl.(fieldsToConvert{iVariable}), precisions{iVariable})));
    end

    % 将Rho列转换为科学计数法格式
    dataOutput.Rho = strtrim(cellstr(num2str(dataCtf.Rho,'%.6e')));

    % 设置输出文件名，并将数据写入CSV文件
    outputFilename = sprintf('S1_20250302_USPR5_17min_R%d_excerpt_bm2_rho_inl.csv', timePoint); % GNSNi_10
    writetable(dataOutput, fullfile(outputPath, outputFilename), 'Delimiter', ' ');
end

% H:\Github\MyRhinoLab\scripts\p23-GNSNi-AGG-2024\0b-experiments-17min-USRP5\p23_0b_exp4_combine_inl_and_rho_step2.m