C = 100:100:1000;
N = 1000;
alpha = 0.8;
p = (1:N).^(-alpha);
p = p / sum(p);

num_requests = 5*10^5;

len = length(C);
hit_prob_bound = zeros(1, len);
all_arrivals = [];

l = 5.0;
h = 15.0;
a = 1.8;

size_arr = zeros(N,1);
for n=1:N
    us = rand;
    size_arr(n,1) = round(l/(1+us*(((l/h)^a)-1))^ (1.0/a));
end

a = zeros(1,N);
b = (2*ones(1,N)./p)-a;
[m,~] = unifstat(a,b);

for n=1:N
    nth_arrivals = unifrnd(a(1,n),b(1,n),100,1);

    while (sum(nth_arrivals) < num_requests)
        nth_arrivals = [nth_arrivals; unifrnd(a(1,n),b(1,n),100,1)];
    end
    
    all_arrivals = [all_arrivals; [cumsum(nth_arrivals), n*ones(length(nth_arrivals), 1)]];
end
[arriv_times, srt_ind] = sort(all_arrivals(:, 1));
arrivals = [arriv_times, all_arrivals(srt_ind, 2)];
clear all_arrivals arriv_times srt_ind;

check_error = 0;

file_name = ['Uniform_trace_N' num2str(N) '.txt'];
file_name2 = ['Uniform_HR_Result_N' num2str(N) '.txt'];
fid =fopen(file_name, 'w' );
fid2 =fopen(file_name2, 'w' );

for i=1:len
    total_hit_prob_bound = 0;

    last_hit = zeros(1,N);
    req_num = 1;
    sim_time = 0;
    disp(i);
    while (req_num < num_requests)
        if (mod(req_num, 10^5) == 0)
            fprintf('Request number: %d\n',req_num);
        end
        time = arrivals(req_num, 1);
        item = arrivals(req_num, 2);
        size = size_arr(item,1);
        
        if(i==1)
            fprintf(fid, '%d %d %d \n', round(time), item, size);
        end    
        
        if(check_hit(last_hit,time,a,b,item, C(i), size_arr))
            total_hit_prob_bound=total_hit_prob_bound+1; 
        end 
        req_num = req_num + 1;
        last_hit(1,item) = time;
    end
    hit_prob_bound(i) = total_hit_prob_bound/(req_num-1);
    fprintf(fid2, '%f \n', hit_prob_bound(i));
end    
fclose(fid);
fclose(fid2);