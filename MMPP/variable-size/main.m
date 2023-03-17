load('mmpp_trace_N1000.mat');
%C = 100:100:1000;
C = 50:50:500;


len = size(C,2); 
req_num = 1;
total_hit_prob_bound = zeros(1, len);
while (req_num < num_requests)
    if (mod(req_num, 10^5) == 0)
        fprintf('Request number: %d\n',req_num);
    end 
    
    time = arrivals(req_num, 1);
    item = arrivals(req_num, 2);
    state = arrivals(req_num, 3);
    
    total_hit_prob_bound = total_hit_prob_bound + check_hit_mmpp(item, state, C, p_desc.',p_asc.', size_arr);
    req_num = req_num + 1;    
end    
hit_prob_bound = total_hit_prob_bound/(req_num-1);
        
file_name = ['HR_results_mmpp_N' num2str(N) '.mat'];
save(file_name,'hit_prob_bound');