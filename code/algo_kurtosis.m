function labels = algo_kurtosis(delays, powers)
    % Ref: [6] C. Gentile, "Using the Kurtosis Measure..."
    % 原理对应: Paper Section "Kurtosis-based Algorithm" [cite: 182-184]
    
    %% --- Step 1: 预处理 ---
    % 论文假设: "amplitudes ... are lognormally distributed" 。
    % 这意味着 Power (dB) 或 Log-Amplitude 应该服从正态分布。
    [d_sorted, sort_idx] = sort(delays);
    p_lin = powers(sort_idx);
    A_log = 10*log10(p_lin); % 转换到 dB 域进行统计分析
    
    N = length(delays);
    labels_sorted = ones(N, 1);
    
    %% --- Step 2: 递归区域竞争 (Region Competition) ---
    % 原理: 论文提到的 "region competition technique" [cite: 183]。
    % 我们从整体开始，尝试寻找最佳分割点，将一个区域一分为二，
    % 看分割后的两个子区域是否比原区域更符合统计假设（峰度更低/更接近目标）。
    labels_sorted = recursive_split(d_sorted, A_log, labels_sorted, 1);
    
    %% --- Step 3: 结果输出 ---
    labels = zeros(N, 1);
    labels(sort_idx) = labels_sorted;
end

function L = recursive_split(time, amp, L, current_id)
    % 提取当前簇的数据
    idx_global = find(L == current_id);
    n = length(idx_global);
    
    % 物理约束: 簇不能无限小，必须包含一定数量的多径才能进行统计计算
    min_len = 15; 
    if n < 2 * min_len, return; end
    
    local_t = time(idx_global);
    local_a = amp(idx_global);
    
    % 计算当前区域的得分为基准
    parent_score = calc_laplacian_score(local_t, local_a);
    
    best_score = inf;
    best_k = -1;
    
    % --- 寻找最佳分割点 (Competition) ---
    % 遍历所有可能的时间切分点，计算切分后左右两部分的统计得分总和
    for k = min_len : 2 : (n - min_len)
        s1 = calc_laplacian_score(local_t(1:k), local_a(1:k));
        s2 = calc_laplacian_score(local_t(k+1:end), local_a(k+1:end));
        
        total_score = s1 + s2;
        if total_score < best_score
            best_score = total_score;
            best_k = k;
        end
    end
    
    % --- 判决 ---
    % 如果分割后的总得分显著优于未分割 (降低了统计偏差)，则执行分割。
    % 这对应了通过竞争优化模型拟合度的过程。
    if best_k > 0 && best_score < parent_score * 0.90
        split_idx_local = best_k;
        new_id = max(L) + 1;
        
        % 更新标签: 右半部分被标记为新簇
        global_indices_right = idx_global(split_idx_local+1 : end);
        L(global_indices_right) = new_id;
        
        % 递归继续尝试分割子区域
        L = recursive_split(time, amp, L, current_id); 
        L = recursive_split(time, amp, L, new_id);     
    end
end

function score = calc_laplacian_score(t, a)
    % 原理: 使用 Kurtosis measure 。
    % 理想的高斯分布/拉普拉斯分布残差具有特定的峰度值。
    
    if length(t) < 4, score = inf; return; end
    
    % 去除线性趋势 (Exponential Decay in Linear = Linear in dB)
    % 簇内功率随延迟衰减，剩下的残差才反映分布特性
    p = polyfit(t, a, 1);
    fit_curve = polyval(p, t);
    residuals = a - fit_curve;
    
    % 计算峰度
    k_val = kurtosis(residuals);
    if isnan(k_val), k_val = 0; end
    
    % 目标峰度: Laplacian 分布的 Kurtosis 为 6 (MATLAB 定义)。
    % 很多信道模型 (如 IEEE 802.11) 认为簇内角度/幅度偏差服从 Laplacian 分布 [cite: 32]。
    target_k = 6; 
    
    % 得分函数: 越接近目标峰度，得分越低 (越好)。
    % 加入长度加权是为了防止算法过度切碎成只有几个点的小片段（小样本峰度不可靠）。
    score = (length(t)^1.1) * abs(k_val - target_k); 
end