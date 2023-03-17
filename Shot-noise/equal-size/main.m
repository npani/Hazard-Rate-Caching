load('shot_noise_trace_N143871_new_params.mat');
C = 1000:1000:10000;
len = size(C,2);
hit_prob_lru = zeros(1, len);
hit_prob_fifo = zeros(1, len);
hit_prob_random = zeros(1, len);
hit_prob_static = zeros(1, len);

for i=1:len
    total_hit_prob_lru = 0;
    total_hit_prob_fifo = 0;
    total_hit_prob_random = 0;
    total_hit_prob_static = 0;

    req_num = 1;
    sim_time = 0;
    
    lru_cache = -1 * ones(1, C(i));
    fifo_cache = -1 * ones(1, C(i));
    random_cache = [];
    disp(i)
    while (req_num < num_requests)
        if (mod(req_num, 10^5) == 0)
            fprintf('Request number: %d\n',req_num);
        end
        time = arrivals(req_num, 1);
        item = arrivals(req_num, 2);

        ind = find(lru_cache == item);

        if (isempty(ind)) % miss
            lru_cache = [item, lru_cache(1:C(i)-1)];
        else % hit
            total_hit_prob_lru=total_hit_prob_lru+1;
            tmp = lru_cache;
            tmp(ind) = [];
            lru_cache = [item, tmp];
        end

        ind = find(fifo_cache == item);

        if (isempty(ind)) % miss
            fifo_cache = [item fifo_cache(1:C(i)-1)];
        else % hit
            total_hit_prob_fifo=total_hit_prob_fifo+1;
        end

        ind = find(random_cache == item);

        if (isempty(ind)) % miss
            if(length(random_cache) == C(i))
                rand_ind = randi([1 C(i)]);
                random_cache(rand_ind) = item;
            else    
                random_cache= [random_cache,item];
            end
        else % hit
            total_hit_prob_random=total_hit_prob_random+1;
        end
        if(find(srt_ind_pop==item)<=C(i))
            total_hit_prob_static=total_hit_prob_static+1; 
        end    
        req_num = req_num + 1;
    end
    hit_prob_lru(i) = total_hit_prob_lru/(req_num-1);
    hit_prob_fifo(i) = total_hit_prob_fifo/(req_num-1);
    hit_prob_random(i) = total_hit_prob_random/(req_num-1);
    hit_prob_static(i) = total_hit_prob_static/(req_num-1);
end    
req_num = 1;
total_hit_prob_bound = zeros(1, len);
while (req_num < num_requests)
    if (mod(req_num, 10^5) == 0)
        fprintf('Request number: %d\n',req_num);
    end 
    
    time = arrivals(req_num, 1);
    item = arrivals(req_num, 2);
    
    total_hit_prob_bound = total_hit_prob_bound + check_hit_classes(time,item, C,meta_data_contents);
    req_num = req_num + 1;    
end    
hit_prob_bound = total_hit_prob_bound/(req_num-1);
        
file_name = ['Final_results_trace_N' num2str(N) '_new_params.mat'];
save(file_name);