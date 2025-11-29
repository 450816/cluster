function [mpc_data, true_labels] = generate_sv_data(cfg)
    num_clusters = cfg.num_clusters;
    mpcs_per = cfg.mpcs_per;
    
    % S-V 模型物理参数
    c_delay = [50, 150, 300]; 
    c_angle = [30, -45, 10];
    c_AS    = [5, 20, 10];    
    c_DS    = [20, 30, 25];   
    
    mpc_data = []; true_labels = [];
    rng(42); 
    %rng(2025);
    
    for i = 1:num_clusters
        d = exprnd(c_DS(i), mpcs_per, 1) + c_delay(i);
        b = c_AS(i) / sqrt(2);
        u = rand(mpcs_per, 1) - 0.5;
        ang = c_angle(i) - b .* sign(u) .* log(1 - 2*abs(u));
        p_db = -0.15 * (d - c_delay(i)) + randn(mpcs_per, 1) * 3;
        valid = p_db > -60;
        
        mpc_data = [mpc_data; d(valid), ang(valid), 10.^(p_db(valid)/10)];
        true_labels = [true_labels; ones(sum(valid), 1)*i];
    end
end