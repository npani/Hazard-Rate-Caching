C = 10:10:100;
N = 1000;
alpha = 0.8;
p = (1:N).^(-alpha);
p = p / sum(p);

transient_num_reqs = 10^5;
num_requests = 5*10^5;
restart = 5*10^5;

a =0.5  * ones(1,N);
b = ones(1,N)./(a.*p);
[m,~] = gamstat(a,b);
len = size(C,2);

hit_prob_lfu = zeros(1, len);
hit_prob_lru = zeros(1, len);
hit_prob_fifo = zeros(1, len);
hit_prob_random = zeros(1, len);
hit_prob_static = zeros(1, len);
hit_prob_bound = zeros(1, len);
hit_prob_belady = zeros(1, len);

all_arrivals = [];
for n=1:N
    nth_arrivals = gamrnd(a(n),b(n),100,1);

    while (sum(nth_arrivals) < num_requests)
        nth_arrivals = [nth_arrivals; gamrnd(a(n),b(n),100,1)];
    end
    
    all_arrivals = [all_arrivals; [cumsum(nth_arrivals), n*ones(length(nth_arrivals), 1)]];
end
[arriv_times, srt_ind] = sort(all_arrivals(:, 1));
arrivals = [arriv_times, all_arrivals(srt_ind, 2)];
clear all_arrivals arriv_times srt_ind;

check_error = 0;

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
%     arrival_times = gprnd(k,sigma,theta);
    disp(i);
    while (req_num < num_requests)
        if (mod(req_num, 10^5) == 0)
            fprintf('Request number: %d\n',req_num);
        end
        time = arrivals(req_num, 1);
        item = arrivals(req_num, 2);
%         arrival_times(item) = time + gprnd(k(item),sigma(item),theta(item));

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
        
        if(item <= C(i))
            total_hit_prob_static=total_hit_prob_static+1; 
        end    
        
        if(check_hit(last_hit,time,a,b,item, C(i)))
            total_hit_prob_bound=total_hit_prob_bound+1; 
        end 
        
        ind = find(opt_cache == item);

        if (isempty(ind)) % miss
            if(length(opt_cache) == C(i))
                ind = get_index(arrivals(req_num+1:end,2).',[opt_cache item]);
                if(ind ~= C(i) + 1)
                    opt_cache(ind) = item;
                end    
            else    
                opt_cache= [opt_cache,item];
            end
        else % hit
            total_hit_prob_belady=total_hit_prob_belady+1;
        end
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
file_name = ['HR_results_Gamma_N' num2str(N) '.mat'];
save(file_name,'hit_prob_bound', 'hit_prob_belady', 'hit_prob_lru','hit_prob_fifo','hit_prob_random','hit_prob_static');


figure;
grid on;
% set(gca, 'FontSize', 18, 'Fontname', 'Times New Roman','XScale', 'log', 'YScale', 'log');
set(gca, 'FontSize', 24, 'Fontname', 'Times New Roman');
hold on;
plot(C,hit_prob_belady,'m','LineWidth', 2, 'Marker', '+', 'MarkerSize',10);
plot(C,hit_prob_bound,'r','LineWidth', 2, 'Marker', 'o', 'MarkerSize',10);
plot(C,hit_prob_static,'b','LineWidth', 2, 'Marker', '*', 'MarkerSize',10);
plot(C,hit_prob_lru,'color','g','LineWidth', 2, 'Marker', 'x', 'MarkerSize',10);
plot(C,hit_prob_fifo,'color',[0.9290, 0.6940, 0.1250],'LineWidth', 2, 'Marker', 's', 'MarkerSize',10);
plot(C,hit_prob_random,'k','LineWidth', 2, 'Marker', 'd', 'MarkerSize',10);
xlim([0 110]);
ylim([0 1.1]);
xlabel('Cache Capacity');
ylabel('Object Hit Probability');
h_legend = legend('Belady','HR Based','Static','LRU', 'FIFO','Random');
set(h_legend,'FontSize',20, 'NumColumns',2);
print -depsc hit_prob_bound_opt_n5105_Gamma_DHR_ca.eps;

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