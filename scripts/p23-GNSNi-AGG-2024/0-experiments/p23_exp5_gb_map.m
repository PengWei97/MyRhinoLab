%% 脚本说明
% 创建时间：2025年02月18日
% 创建人：Pengwei
% 创建目的：分析和可视化不同时间点的晶界类型
% 输入数据为EBSD数据，处理后按不同时间点绘制晶界图。

close all; % 关闭所有图形窗口
clear;     % 清除工作空间
clc;       % 清空命令行窗口

% 定义晶体对称性及其相关参数
crystalSymmetry = {... 
    'notIndexed', ...  % 没有索引的晶体
    crystalSymmetry('m-3m', [3.6 3.6 3.6], 'mineral', 'Ni-superalloy', 'color', [0.53 0.81 0.98])};  % Ni超级合金的晶体对称性

% 设置绘图的坐标轴方向
setMTEXpref('xAxisDirection', 'west');     % 设置x轴方向为西向
setMTEXpref('zAxisDirection', 'outOfPlane'); % 设置z轴方向为指向外平面

%% 指定数据文件路径和时间点
dataPath = 'H:\Github\MyRhinoLabData\p23_GNSNi_AGG_2024\ebsd\a0_GNSNi_QIS_EBSD_guangzhou\ctf_excerpt\';  % EBSD数据文件路径
timePoints = [5.0, 10.0, 20.0, 30.0];  % 研究的时间点（单位：分钟）

% 配置颜色，用于区分不同的晶界类型
colors = {'gold', 'blue', 'green', 'magenta', 'cyan', 'orange'};

%% 循环处理每个时间点的数据
for iTime = 2:2 % 1:length(timePoints)  % 循环遍历每个时间点
    % 构造输入文件路径
    inputFile = fullfile(dataPath, sprintf('GNSNi_%dmin_Layer1_denoising.ctf', timePoints(iTime)));

    %% 导入EBSD数据
    ebsdData = EBSD.load(inputFile, crystalSymmetry, 'interface', 'ctf', ...
                         'convertEuler2SpatialReferenceFrame');  % 加载CTF文件并转换欧拉角

    % 标识和平滑晶粒边界
    [grains, ebsdData] = identifyAndSmoothGrains(ebsdData, 2.0 * degree, 10, 3.0);  % 平滑晶粒并标识晶界

    % 定义用于晶粒边界的错配角度阈值
    % sigmaNum = [3, 5, 7, 9, 11, 13, 15];  % CSL边界的Sigma值

    sigmaNum = [3, 5, 7, 9, 11, 13, 17, 19];

    % 获取所有晶粒边界（Ni-superalloy材料）
    gB = grains.boundary('Ni-superalloy', 'Ni-superalloy');  % 获取所有晶粒边界
    lAGB = gB(angle(gB.misorientation) < 15.0 * degree);     % 低角度边界（< 15°）
    hAGB = gB(angle(gB.misorientation) >= 15.0 * degree);    % 高角度边界（≥ 15°）

    %% 循环计算每种Sigma值的晶界
    for iSigma = 1:length(sigmaNum)
        varName = sprintf('gB%d', sigmaNum(iSigma));  % 动态创建变量名，例如gB3, gB5等

        % 计算错配角度阈值（通过Sigma值计算）
        % deltaMisor = 15 * power(sigmaNum(iSigma), -1/2) * degree;  % 基于Sigma值计算错配角度 公式1 p133
        deltaMisor = 15 * power(sigmaNum(iSigma), -5/6) * degree;  % 基于Sigma值计算错配角度 公式2 p134

        % 提取对应Sigma值的晶界
        dataGBs.(varName) = gB(gB.isTwinning(CSL(sigmaNum(iSigma), ebsdData.CS), deltaMisor)); 
    end
    
    %% 绘制当前时间点的晶界图
    figure(iTime)  % 创建一个新图形窗口
    % % 绘制高角度边界（黑色）
    % plot(hAGB, 'lineColor', 'black', 'linewidth', 1.5, 'micronbar', 'off'); 
    % hold on  % 保持当前图像，使后续图形添加到同一个窗口
    % % 绘制低角度边界（靛蓝色）
    % plot(lAGB, 'lineColor', 'Indigo', 'linewidth', 2, 'micronbar', 'off'); 
    
    % 绘制每个Sigma值对应的晶界类型
    for iSigma = 1:length(sigmaNum)
        varName = sprintf('gB%d', sigmaNum(iSigma));  % 获取Sigma值对应的变量名
        legendName = sprintf('CSL %d', sigmaNum(iSigma));  % 设置图例名称

        % 绘制Sigma值对应的晶界，使用不同的颜色
        figure(iSigma)
        % plot(dataGBs.(varName), 'lineColor', colors{iSigma}, 'linewidth', 2, 'DisplayName', legendName); 
        plot(dataGBs.(varName), 'lineColor', 'black', 'linewidth', 2, 'DisplayName', legendName); 
    end
    
    % 绘制图例（如果需要显示）
    % legend on
end

%% 脚本路径说明
% 脚本路径: H:\Github\MyRhinoLab\scripts\p23-GNSNi-AGG-2024\0-experiments\p23_exp5_gb_map.m
