load('on_off_trace_N1000_new.mat');
% C = 10:10:100;

% load('on_off_trace_N100.mat');
C = 1:1:10;

len = size(C,2); 
req_num = 1;
total_hit_prob_bound = zeros(1, len);
while (req_num < num_requests)
    if (mod(req_num, 10^5) == 0)
        fprintf('Request number: %d\n',req_num);
    end 
    
    time = arrivals(req_num, 1);
    item = arrivals(req_num, 2);
    
    total_hit_prob_bound = total_hit_prob_bound + check_hit_onoff(time,item, C, p, N, boundary_times, states);
    req_num = req_num + 1;    
end    
hit_prob_bound = total_hit_prob_bound/(req_num-1);
        
file_name = ['HR_results_on_off_N' num2str(N) '_new_low_cs.mat'];
save(file_name,'hit_prob_bound');