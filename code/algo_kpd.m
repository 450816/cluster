function [labels] = algo_kpd(X, P, eps, th)
    % Ref: [5] He et al.
    % 逻辑复查：确保核密度计算正确
    N = size(X, 1);
    % 1. Kernel Power Density Estimation
    % 向量化加速距离计算
    D = pdist2(X, X); 
    % Gaussian Kernel: K(d) = exp(-d^2 / 2sigma^2), sigma = eps/2
    sigma = eps / 2;
    K_val = exp(-(D.^2) ./ (2 * sigma^2));
    densities = (K_val * P); % 矩阵乘法直接完成加权求和
    densities = densities / max(densities); % 归一化
    
    % 2. Peak Finding & Clustering
    labels = zeros(N, 1);
    visited = false(N, 1);
    C = 0;
    
    [~, sorted_idx] = sort(densities, 'descend'); % 从高密度点开始
    
    for i = 1:N
        idx = sorted_idx(i);
        if visited(idx) || densities(idx) < th, continue; end
        
        C = C + 1;
        % 简单的区域生长 (Flood Fill)
        q = idx;
        visited(idx) = true;
        labels(idx) = C;
        
        head = 1;
        while head <= length(q)
            curr = q(head); head = head + 1;
            % 找邻居
            nbs = find(D(curr, :) <= eps);
            for k = nbs
                if ~visited(k)
                    visited(k) = true;
                    labels(k) = C;
                    % 只有密度够高的点才有资格扩展
                    if densities(k) >= th
                        q(end+1) = k; %#ok<AGROW>
                    end
                elseif labels(k) == 0 
                    labels(k) = C; % 吸收之前的噪声点
                end
            end
        end
    end
end