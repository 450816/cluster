clc; clear; close all;
    addpath(genpath(pwd)); % 自动添加当前路径下的子文件夹
    
    %% --- Step 1: 仿真数据生成 (S-V Model) ---
    fprintf('Initializing Channel Data...\n');
    % 配置：3个簇，每簇100条路径
    cfg.num_clusters = 3; 
    cfg.mpcs_per = 100;
    [mpc_data, GT_labels] = generate_sv_data(cfg);
    
    % 归一化处理 (这对所有距离敏感型算法至关重要)
    X_raw = mpc_data(:, 1:2); % [Delay, Angle]
    P_raw = mpc_data(:, 3);   % Power (Linear)
    % Min-Max Normalize to [0, 1]
    X_norm = (X_raw - min(X_raw)) ./ (max(X_raw) - min(X_raw));
    
    % 可视化初始数据
    viz_tools('plot_raw', mpc_data, [], []);
    
    %% --- Step 2: 运行 2D 聚类算法 (Delay + Angle) ---
    % 这一组算法同时利用时空信息
    
    % 1. KPowerMeans (Table 1: [4])
    % 特点：需预设 K，功率加权
    fprintf('Running Algo 1: KPowerMeans...\n');
    t = tic;
    [L1, C1] = algo_kpowermeans(X_norm, P_raw, 3); 
    meta1 = struct('name', 'KPowerMeans [4]', 'time', toc(t), 'k_preset', 3, 'centers', C1);
    viz_tools('plot_res', mpc_data, L1, meta1);
    
    % 2. KPD-based (Table 1: [5])
    % 特点：自动 K，基于密度，抗噪
    fprintf('Running Algo 2: KPD-based...\n');
    t = tic;
    % epsilon 需根据归一化数据调整，通常在 0.05-0.2 之间
    [L2] = algo_kpd(X_norm, P_raw, 0.12, 0.15); 
    meta2 = struct('name', 'KPD-based [5]', 'time', toc(t));
    viz_tools('plot_res', mpc_data, L2, meta2);
    
    % 3. DBSCAN (Table 1: [9])
    % 特点：利用 MATLAB 内置函数，纯几何密度
    fprintf('Running Algo 3: DBSCAN...\n');
    t = tic;
    % minpts=5, epsilon=0.1
    L3 = algo_dbscan_wrapper(X_norm, 0.1, 5); 
    meta3 = struct('name', 'DBSCAN [9]', 'time', toc(t));
    viz_tools('plot_res', mpc_data, L3, meta3);
    
    % 4. Fuzzy C-Means (Table 1: [8])
    % 特点：利用 MATLAB 内置 fcm，软聚类
    fprintf('Running Algo 4: Fuzzy C-Means...\n');
    t = tic;
    [L4, C4] = algo_fcm_wrapper(X_norm, 3);
    meta4 = struct('name', 'Fuzzy C-Means [8]', 'time', toc(t), 'k_preset', 3, 'centers', C4);
    viz_tools('plot_res', mpc_data, L4, meta4);
    
    %% --- Step 3: 运行 1D 聚类算法 (Delay Only) ---
    % 这一组算法仅利用时延信息 
    
%% --- Phase 3: Delay-Domain 算法 (Paper Replication) ---
fprintf('\nRunning 1D Algorithms (Paper Style)...\n');

% 5. Kurtosis-based
L_kurt = algo_kurtosis(mpc_data(:,1), mpc_data(:,3));
% 调用新画图函数
plot_paper_style(mpc_data, L_kurt, 'Kurtosis-based');

% 6. Sparsity-based
L_spar = algo_sparsity(mpc_data(:,1), mpc_data(:,3));
% 调用新画图函数
plot_paper_style(mpc_data, L_spar, 'Sparsity-based');



    
    fprintf('\nRunning 1D Delay-Domain Algorithms...\n');




    % 5. Kurtosis-based (Table 1: [6])
    % 特点：基于统计峰度，寻找对数正态分布
    fprintf('Running Algo 5: Kurtosis-based...\n');
    t = tic;
    L5 = algo_kurtosis(X_norm(:,1), P_raw); % 仅输入 Delay 列
    meta5 = struct('name', 'Kurtosis-based [6]', 'time', toc(t), 'domain', '1D');
    viz_tools('plot_res', mpc_data, L5, meta5);

    % 6. Sparsity-based (Table 1: [7])
    % 特点：基于 S-V 模型拟合 (指数衰减)
    fprintf('Running Algo 6: Sparsity-based...\n');
    t = tic;
    L6 = algo_sparsity(mpc_data(:,1), P_raw); % 输入原始 Delay (ns) 以便拟合物理模型
    meta6 = struct('name', 'Sparsity-based [7]', 'time', toc(t), 'domain', '1D');
    viz_tools('plot_res', mpc_data, L6, meta6);



%     close all
%     % 6. Sparsity-based (Table 1: [7])
%     % 特点：基于 S-V 模型拟合 (指数衰减)
%     fprintf('Running Algo 6: Sparsity-based...\n');
%     t = tic;
%     L6 = algo_sparsity(mpc_data(:,1), P_raw); % 输入原始 Delay (ns) 以便拟合物理模型
%     meta6 = struct('name', 'Sparsity-based [7]', 'time', toc(t), 'domain', '1D');
%     viz_tools('plot_res', mpc_data, L6, meta6);
%     % 6. Sparsity-based
% L_spar = algo_sparsity(mpc_data(:,1), mpc_data(:,3));
% % 调用新画图函数
% plot_paper_style(mpc_data, L_spar, 'Sparsity-based');


