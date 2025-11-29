function [labels, centers] = algo_fcm_wrapper(X, K)
    % Ref: [8] Table 1 Fuzzy-c-means
    % 封装 MATLAB 内置函数
    
    if exist('fcm', 'file')
        options = [2.0, 100, 1e-5, 0]; % [exponent, max_iter, min_improv, verbose]
        [centers, U] = fcm(X, K, options);
        % FCM 输出的是隶属度矩阵 U (K x N)
        % 硬化 (Hardening)：取最大隶属度作为 Label
        [~, labels] = max(U, [], 1);
        labels = labels'; 
    else
        error('需要 Fuzzy Logic Toolbox 才能运行 fcm');
    end
end