function [labels, centers] = algo_kpowermeans(X, P, K)
    % Ref: [4] Czink et al. 
    % 逻辑复查：确保空簇处理和功率加权正确
    [N, dim] = size(X);
    centers = X(randperm(N, K), :);
    labels = zeros(N, 1);
    
    for iter = 1:100
        last_centers = centers;
        % 1. Assignment (Euclidean)
        dists = pdist2(X, centers); % 使用内置函数加速
        [~, labels] = min(dists, [], 2);
        
        % 2. Update (Power Weighted)
        for k = 1:K
            idx = (labels == k);
            if sum(idx) == 0
                centers(k,:) = X(randi(N), :); % 随机重置空簇
            else
                total_p = sum(P(idx));
                if total_p > 0
                    centers(k,:) = sum(X(idx,:) .* P(idx), 1) / total_p;
                else
                    centers(k,:) = mean(X(idx,:), 1);
                end
            end
        end
        if norm(centers - last_centers) < 1e-6, break; end
    end
end