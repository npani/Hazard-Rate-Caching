load('shot_noise_trace_N143871_new_params.mat');
C = 10000:10000:100000;
len = size(C,2); 
req_num = 1;
total_hit_prob_bound = zeros(1, len);
while (req_num < num_requests)
    if (mod(req_num, 10^5) == 0)
        fprintf('Request number: %d\n',req_num);
    end 
    
    time = arrivals(req_num, 1);
    item = arrivals(req_num, 2);
    
    total_hit_prob_bound = total_hit_prob_bound + check_hit_classes(time,item, C,meta_data_contents, size_arr);
    req_num = req_num + 1;    
end    
hit_prob_bound = total_hit_prob_bound/(req_num-1);
        
file_name = ['Final_results_trace_N' num2str(N) '_new_params.mat'];
save(file_name);