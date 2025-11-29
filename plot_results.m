function plot_results(mpc_data, idx_kpm, idx_kpd, c_kpm, s_kpm, s_kpd)
    figure('Position', [100, 100, 1200, 500]);
    
    % KPowerMeans Plot
    subplot(1, 2, 1);
    gscatter(mpc_data(:,2), mpc_data(:,1), idx_kpm);
    hold on;
    % 还原质心到原始坐标系 (简单的逆归一化用于显示)
    delay_range = max(mpc_data(:,1)) - min(mpc_data(:,1));
    angle_range = max(mpc_data(:,2)) - min(mpc_data(:,2));
    c_real_ang = c_kpm(:,2) * angle_range + min(mpc_data(:,2));
    c_real_del = c_kpm(:,1) * delay_range + min(mpc_data(:,1));
    plot(c_real_ang, c_real_del, 'kx', 'MarkerSize', 12, 'LineWidth', 2);
    
    set(gca, 'YDir', 'reverse');
    title({'\bf Algorithm 1: KPowerMeans', ['DB Index: ', num2str(s_kpm, '%.2f'), ' (Lower is better)']});
    xlabel('Angle (deg)'); ylabel('Delay (ns)'); grid on;
    
    % KPD Plot
    subplot(1, 2, 2);
    % 单独绘制噪声点
    noise_mask = idx_kpd == 0;
    if sum(noise_mask) > 0
        plot(mpc_data(noise_mask, 2), mpc_data(noise_mask, 1), 'k.', 'MarkerSize', 5); hold on;
    end
    % 绘制簇
    gscatter(mpc_data(~noise_mask, 2), mpc_data(~noise_mask, 1), idx_kpd(~noise_mask));
    
    set(gca, 'YDir', 'reverse');
    title({'\bf Algorithm 2: KPD-based', ['DB Index: ', num2str(s_kpd, '%.2f'), ' (Auto-detected K)']});
    xlabel('Angle (deg)'); ylabel('Delay (ns)'); grid on;
end