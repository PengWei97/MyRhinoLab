function create_ebsd_scripts()
    % 创建 EBSD 脚本的目录
    scriptDir = 'H:\Github\MyRhinoLab\scripts\prm9-cooperate\p91-MgAlloy-SelectGG-2025\20250220_experiments\';
    
    if ~exist(scriptDir, 'dir')
        mkdir(scriptDir);
        fprintf('已创建文件夹：%s\n', scriptDir);
    else
        fprintf('文件夹 %s 已存在。\n', scriptDir);
    end

    % 定义脚本名和描述信息
    scripts = {
        'p91_s1_crc2ctf_clean',      '输入 .crc 文件，降噪细化后输出 .ctf 文件';
        'p91_s2_plot_maps',          '绘制 IPF map、KAM map 和 GOS map';
        'p91_s3_analyze_gb',         '晶界分析，包括 GB 类型图 和 Misorientation Distribution';
        'p91_s4_analyze_texture',    '取向分析，包括极图、反极图 和 ODF';
        'p91_s5_identify_grains',    '识别三类晶粒，输出 csv、带 grain_type 的 ctf/ang 文件';
        'p91_s6_export_moose_inl',   '导出 MOOSE 可用的 INL 文件（输入 grain_type 的 ctf 和 INL 文件）';
    };

    % 获取当前时间
    timeStr = datestr(now, 'yyyy-mm-dd HH:MM:SS');

    % 循环生成每个脚本文件
    for i = 1:size(scripts, 1)
        fileName = fullfile(scriptDir, [scripts{i,1}, '.m']);
        fid = fopen(fileName, 'w');
        if fid == -1
            warning('无法创建文件：%s', fileName);
            continue;
        end

        % 写入模板内容
        fprintf(fid, '%% %s.m\n', scripts{i,1});
        fprintf(fid, '%% 功能：%s\n', scripts{i,2});
        fprintf(fid, '%% 作者：Wei\n');
        fprintf(fid, '%% 创建时间：%s\n', timeStr);
        fprintf(fid, '%% -------------------------------------------\n\n');
        fprintf(fid, 'function %s()\n', scripts{i,1});
        fprintf(fid, '    %% TODO: 实现功能 - %s\n', scripts{i,2});
        fprintf(fid, '    disp("运行 %s 脚本...");\n', scripts{i,1});
        fprintf(fid, 'end\n');

        fclose(fid);
        fprintf('✅ 已创建：%s\n', fileName);
    end

    fprintf('\n🎉 所有 EBSD 脚本已创建成功，请在 %s 文件夹中查看。\n', scriptDir);
end
% H:\Github\MyRhinoLab\scripts\prm9-cooperate\p91-MgAlloy-SelectGG-2025\20250220_experiments\mkfiles.m
