function viz_tools(mode, mpc_data, labels, meta)
    % mode: 'plot_raw' 或 'plot_res'
    
    switch mode
        case 'plot_raw'
            plot_raw_data(mpc_data);
        case 'plot_res'
            plot_algorithm_result(mpc_data, labels, meta);
    end
end

function plot_raw_data(data)
    figure('Name', 'Raw Channel Data', 'Color', 'w', 'Position', [100, 300, 600, 400]);
    scatter(data(:,2), data(:,1), 30, 10*log10(data(:,3)), 'filled');
    colormap('jet'); colorbar;
    set(gca, 'YDir', 'reverse');
    title('\bf Initial MPC Data (Color = Power dB)');
    xlabel('Angle (deg)'); ylabel('Delay (ns)'); grid on;
end

function plot_algorithm_result(data, labels, meta)
    figure('Name', ['Result: ' meta.name], 'Color', 'w', 'Position', [100, 100, 600, 400]);
    
    X = data(:, 1:2); % Delay, Angle
    
    % --- 处理 1D 算法的特殊显示 ---
    is_1d = isfield(meta, 'domain') && strcmp(meta.domain, '1D');
    
    if is_1d
        % 如果是仅时延域算法，画图时为了美观，我们通常还是画在 2D 平面上，
        % 但你会看到结果呈现“横条状”（Angle 维度上没有切分）
        subtitle_str = '(1D Delay-Domain Clustering)';
    else
        subtitle_str = '(2D Delay-Angle Clustering)';
    end
    
    % 1. 画噪声
    noise = (labels == 0);
    if sum(noise) > 0
        scatter(X(noise, 2), X(noise, 1), 10, [0.8 0.8 0.8], '.'); hold on;
    end
    
    % 2. 画簇
    valid = ~noise;
    if sum(valid) > 0
        gscatter(X(valid, 2), X(valid, 1), labels(valid), [], 'o', 5);
    end
    hold on;
    
    % 3. 画质心 (如果有)
    if isfield(meta, 'centers') && ~isempty(meta.centers)
        % 还原坐标 (假设传入的是归一化的)
        C = meta.centers;
        range = max(X) - min(X);
        mn = min(X);
        C_real = C .* range + mn;
        plot(C_real(:,2), C_real(:,1), 'kx', 'MarkerSize', 12, 'LineWidth', 2);
    end
    
    set(gca, 'YDir', 'reverse'); grid on; box on;
    xlabel('Angle (deg)'); ylabel('Delay (ns)');
    title({['\bf ' meta.name], ['Time: ' num2str(meta.time, '%.3f') 's  |  ' subtitle_str]});
end