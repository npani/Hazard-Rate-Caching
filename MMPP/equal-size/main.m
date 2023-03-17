C = 10:10:100;
% C = 1:1:10;
N = 1000;

num_requests = 5*10^5;
len = size(C,2);

hit_prob_lfu = zeros(1, len);
hit_prob_lru = zeros(1, len);
hit_prob_fifo = zeros(1, len);
hit_prob_random = zeros(1, len);
hit_prob_static = zeros(1, len);
hit_prob_bound = zeros(1, len);
hit_prob_belady = zeros(1, len);

mu12 = 2*10^(-3);
mu21 = 1.6*10^(-3);


pi1 = (mu21/(mu21+mu12));
pi2 = (mu12/(mu21+mu12)); 

% E_V = 10;
% beta = 2.0;
% V_min = ((beta-1)/beta)*E_V;
% 
% % Parameter for Pareto distribution
% k = 1/beta;
% sigma = V_min*k;
% theta = sigma/k;

alpha = 0.8;
p = (1:N).^(-alpha);
p = p / sum(p);

p_desc = sort(p,'descend');
p_asc = sort(p,'ascend');
p_avg = (pi1*p_desc) + (pi2*p_asc);

[~,static_ids] = sort(p_avg,'descend');  

file_name = ['mmpp_trace_N' num2str(N) '.txt'];
file_name_with_size = ['mmpp_trace_N' num2str(N) '_with_size.txt'];
fid =fopen(file_name, 'w' );
fid2 = fopen(file_name_with_size,'w');


all_arrivals = generate_mmpp(mu12, mu21, num_requests, p_asc, p_desc, N);
[arriv_times, srt_ind] = sort(all_arrivals(:, 1));
arrivals = [arriv_times, all_arrivals(srt_ind, 2), all_arrivals(srt_ind, 3)];
clear all_arrivals arriv_times srt_ind;

%Parameters to determine size of the content if variable size
l = 5.0;
h = 15.0;
a = 1.8;
size_arr = zeros(N,1);

for n=1:N
    us = rand;
    size_arr(n,1) = round(l/(1+us*(((l/h)^a)-1))^ (1.0/a));
end    

for k = 1:num_requests
    fprintf(fid, '%d %d %d \n', round(arrivals(k,1)), arrivals(k,2), 1.0);   
    fprintf(fid2, '%d %d %d \n', round(arrivals(k,1)), arrivals(k,2), size_arr(arrivals(k,2),1));   
end    

fclose(fid);
fclose(fid2);

file_name = ['mmpp_trace_N' num2str(N) '.mat'];
save(file_name,'N','p_asc','p_desc','arrivals','num_requests','size_arr');


for i=1:len
    total_hit_prob_bound = 0;
    total_hit_prob_lru = 0;
    total_hit_prob_lfu = 0;
    total_hit_prob_fifo = 0;
    total_hit_prob_random = 0;
    total_hit_prob_static = 0;
    total_hit_prob_belady = 0;

    last_hit = zeros(1,N);
    next_hit = zeros(1,N);
    req_num = 1;
    sim_time = 0;
    
    lru_cache = -1 * ones(1, C(i));
    fifo_cache = -1 * ones(1, C(i));
    lfu_cache = -1 * ones(1, C(i));
    random_cache = [];
    opt_cache = [];
    disp(i)
    while (req_num < num_requests)
        if (mod(req_num, 10^5) == 0)
            fprintf('Request number: %d\n',req_num);
        end
        time = arrivals(req_num, 1);
        item = arrivals(req_num, 2);
        state = arrivals(req_num, 3);

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
        if(find(static_ids==item)<=C(i))
            total_hit_prob_static=total_hit_prob_static+1; 
        end
       
        if(state == 1)
            if(item <= C(i))
                total_hit_prob_bound=total_hit_prob_bound+1; 
            end
        else
            if(item >= N-C(i)+1)
                total_hit_prob_bound=total_hit_prob_bound+1; 
            end
        end    
        
%         ind = find(opt_cache == item);
% 
%         if (isempty(ind)) % miss
%             if(length(opt_cache) == C(i))
%                 ind = get_index(arrivals(req_num+1:end,2).',[opt_cache item]);
%                 if(ind ~= C(i) + 1)
%                     opt_cache(ind) = item;
%                 end    
%             else    
%                 opt_cache= [opt_cache,item];
%             end
%         else % hit
%             total_hit_prob_belady=total_hit_prob_belady+1;
%         end

        req_num = req_num + 1;
        last_hit(1,item) = time;
    end
    hit_prob_bound(i) = total_hit_prob_bound/(req_num-1);
    hit_prob_belady(i) = total_hit_prob_belady/(req_num-1);
    hit_prob_lru(i) = total_hit_prob_lru/(req_num-1);
    hit_prob_fifo(i) = total_hit_prob_fifo/(req_num-1);
    hit_prob_random(i) = total_hit_prob_random/(req_num-1);
    hit_prob_static(i) = total_hit_prob_static/(req_num-1);
end    

file_name = ['results_N' num2str(N) '.mat'];
save(file_name,'C','hit_prob_belady','hit_prob_bound','hit_prob_lru','hit_prob_fifo','hit_prob_random','hit_prob_static');


% figure;
% grid on;
% % set(gca, 'FontSize', 18, 'Fontname', 'Times New Roman','XScale', 'log', 'YScale', 'log');
% set(gca, 'FontSize', 24, 'Fontname', 'Times New Roman');
% hold on;
% plot(C,hit_prob_belady,'m','LineWidth', 2, 'Marker', '+', 'MarkerSize',10);
% plot(C,hit_prob_bound,'r','LineWidth', 2, 'Marker', 'o', 'MarkerSize',10);
% plot(C,hit_prob_static,'b','LineWidth', 2, 'Marker', '*', 'MarkerSize',10);
% plot(C,hit_prob_lru,'color','g','LineWidth', 2, 'Marker', 'x', 'MarkerSize',10);
% plot(C,hit_prob_fifo,'color',[0.9290, 0.6940, 0.1250],'LineWidth', 2, 'Marker', 's', 'MarkerSize',10);
% plot(C,hit_prob_random,'k','LineWidth', 2, 'Marker', 'd', 'MarkerSize',10);
% xlim([0 11]);
% ylim([0 0.7]);
% xlabel('Cache Capacity');
% ylabel('Object Hit Probability');
% h_legend = legend('Belady-CA','HR Based','Static','LRU', 'FIFO','Random');
% % h_legend = legend('HR Based','Static','LRU', 'FIFO','Random');
% set(h_legend,'FontSize',20, 'NumColumns',2);
% print -dpdf hit_prob_bound_opt_n5105_mmpp.pdf;

function p = find_ele(arrivals_next, ele)
p = -1;
for i = 1:length(arrivals_next)
    if(arrivals_next(i) == ele)
        p = i;
        return;
    end    
end
end

function farthest_item = get_index(arrivals_next, opt_cache)
output = length(arrivals_next)*ones(1,length(opt_cache));
for k = 1 : length(opt_cache)
  p = find_ele(arrivals_next, opt_cache(k));
  if(p~=-1)
    output(1,k) = p;
  else
    farthest_item = k; 
    return;  
  end   
end
[val, farthest_item] = max(output);
end

function all_arrivals = generate_mmpp(mu12, mu21, num_requests, p_asc, p_desc, N)
r = 0;
all_arrivals = zeros(num_requests,3); 
count = 1;
pi1 = (mu21/(mu21+mu12));
% pi2 = (mu12/(mu21+mu12)); 

a = rand;
time = 0;
if(a<pi1)
    idx = 1;
else
    idx = 2;
end

while 1
    if(idx == 1)
        r_prev  = r;
        r = r + exprnd(1/mu12);   
        for item=1:N
            time = time + exprnd(1/p_desc(item));
            while(time < r)
                all_arrivals(count,1) = time;
                all_arrivals(count,2) = item;
                all_arrivals(count,3) = 1;
                time = time + exprnd(1/p_desc(item));
                count = count+1;
                if(count > num_requests)
                    return;
                end
            end 
            time = r_prev;
        end 
        
        time = r;
        idx = 2;
    else
        r_prev  = r;
        r = r + exprnd(1/mu21);
        for item=1:N
            time = time + exprnd(1/p_asc(item));
            while(time < r)
                all_arrivals(count,1) = time;
                all_arrivals(count,2) = item;
                all_arrivals(count,3) = 2;
                time = time + exprnd(1/p_asc(item));
                count = count+1;
                if(count > num_requests)
                    return;
                end
            end 
            time = r_prev;
        end   
        time = r;
        idx = 1;
    end     
end
end