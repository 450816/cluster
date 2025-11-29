function db_index = evaluate_clustering(X, labels)
    % 计算 Davies-Bouldin (DB) Index
    % DB = mean( max( (S_i + S_j) / M_ij ) )
    % S_i: 簇内散度, M_ij: 簇间距离
    
    u_labels = unique(labels);
    u_labels(u_labels == 0) = []; % 排除噪声
    K = length(u_labels);
    
    if K < 2
        db_index = NaN; return;
    end
    
    S = zeros(K, 1);
    Centroids = zeros(K, size(X, 2));
    
    % 计算簇内散度 S_i
    for k = 1:K
        idx = labels == u_labels(k);
        data_k = X(idx, :);
        Centroids(k, :) = mean(data_k, 1);
        S(k) = mean(sqrt(sum((data_k - Centroids(k,:)).^2, 2)));
    end
    
    % 计算 R_ij 并求最大值
    R = zeros(K, K);
    for i = 1:K
        for j = i+1:K
            M_ij = sqrt(sum((Centroids(i,:) - Centroids(j,:)).^2));
            val = (S(i) + S(j)) / M_ij;
            R(i,j) = val;
            R(j,i) = val;
        end
    end
    
    % 对每个簇找最大的相似度
    max_R = max(R, [], 2);
    db_index = mean(max_R);
end