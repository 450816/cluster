function labels = algo_dbscan_wrapper(X, eps, minpts)
    % Ref: [9] Table 1 DBSCAN
    % 封装 MATLAB 内置函数
    
    % 检查是否有工具箱，如果没有则报错提示
    if exist('dbscan', 'file')
        % dbscan 输出 -1 为噪声，我们需要改为 0 以保持统一
        labels = dbscan(X, eps, minpts);
        labels(labels == -1) = 0; 
    else
        error('需要 Statistics and Machine Learning Toolbox 才能运行 dbscan');
    end
end