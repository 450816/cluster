function plot_paper_style(mpc_data, labels, algo_name)
    % 专门用于复现论文风格的绘图函数
    % 输入: mpc_data [Delay, Angle, Power], labels, algo_name
    
    % 提取数据
    delay = mpc_data(:,1);
    power_db = 10*log10(mpc_data(:,3));
    
    % 创建画布
    figure('Name', ['Paper Replication: ' algo_name], 'Color', 'w', 'Position', [200, 200, 700, 500]);
    
    % --- 1. 绘制背景噪声/原始数据 ---
    % 论文风格：未聚类的点通常显示为黑色连线或灰点
    mask_noise = (labels == 0);
    
    % 为了画出论文那种“波形”感，我们需要按时延排序
    [d_sort, idx_sort] = sort(delay);
    p_sort = power_db(idx_sort);
    l_sort = labels(idx_sort);
    
    % 绘制底图 (模拟连续波形，用浅灰色)
    plot(d_sort, p_sort, '-', 'Color', [0.8 0.8 0.8], 'LineWidth', 1); hold on;
    
    % 绘制噪声点 (黑色)
    if sum(mask_noise) > 0
        plot(delay(mask_noise), power_db(mask_noise), 'k.', 'MarkerSize', 5, 'DisplayName', 'Noise');
    end
    
    % --- 2. 绘制簇及拟合线 (核心特征) ---
    u_labels = unique(labels(labels > 0));
    colors = lines(length(u_labels)); % 获取不同颜色
    
    for k = 1:length(u_labels)
        cid = u_labels(k);
        mask = (labels == cid);
        
        % 提取当前簇数据
        t_c = delay(mask);
        p_c = power_db(mask);
        col = colors(k, :);
        
        % A. 绘制簇内的点 (彩色)
        plot(t_c, p_c, '.', 'Color', col, 'MarkerSize', 12, 'DisplayName', ['Cluster ' num2str(cid)]);
        
        % B. 计算并绘制拟合直线 (Regression Line)
        % 这一步是两篇论文视觉效果的灵魂
        if length(t_c) > 1
            % 线性回归: P(dB) = a * Delay + b
            poly = polyfit(t_c, p_c, 1);
            
            % 生成拟合线的坐标 (从该簇最早到最晚)
            t_fit = linspace(min(t_c), max(t_c), 10);
            p_fit = polyval(poly, t_fit);
            
            % 绘制拟合线
            % Gentile论文用红色/紫色线，He论文用Magenta线
            if contains(algo_name, 'Sparsity')
                % He et al. 风格: Magenta Line
                plot(t_fit, p_fit, 'm-', 'LineWidth', 2.5, 'HandleVisibility', 'off');
                
                % 绘制簇头 (Onset Peak) - 黑圈
                [~, idx_head] = min(t_c); % 最早的时刻作为头
                plot(t_c(idx_head), p_c(idx_head), 'ko', 'LineWidth', 1.5, 'MarkerSize', 8, 'HandleVisibility', 'off');
                
            else
                % Kurtosis 风格: 拟合线颜色与簇一致或深色
                plot(t_fit, p_fit, '-', 'Color', col*0.8, 'LineWidth', 2.5, 'HandleVisibility', 'off');
            end
        end
    end
    
    % --- 3. 装饰 ---
    grid on; box on;
    xlabel('Delay (ns)', 'FontSize', 12);
    ylabel('Power (dB)', 'FontSize', 12);
    
    % 动态标题
    if contains(algo_name, 'Kurtosis')
        title_str = 'Kurtosis-based: Segmentation in Delay Domain';
        sub_str = '(Replicating Gentile [6], Fig. 3)';
    else
        title_str = 'Sparsity-based: S-V Model Fitting';
        sub_str = '(Replicating He et al. [7], Fig. 5/6)';
    end
    title({['\bf ' title_str], ['\rm ' sub_str]}, 'FontSize', 14);
    
    % 限制 Y 轴范围美观
    ylim([min(power_db)-5, max(power_db)+5]);
end