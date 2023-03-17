N = 1000;

num_requests = 5*10^5;
mu12 = 2*10^(-3);
mu21 = 1.6*10^(-3);
pi1 = (mu21/(mu21+mu12));
pi2 = (mu12/(mu21+mu12)); 


alpha = 0.8;
p = (1:N).^(-alpha);
p = p / sum(p);

p_desc = sort(p,'descend');
p_asc = sort(p,'ascend');

file_name_with_size = ['mmpp_trace_N' num2str(N) '_with_size.txt'];
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
    fprintf(fid2, '%d %d %d \n', round(arrivals(k,1)), arrivals(k,2), size_arr(arrivals(k,2),1));   
end

fclose(fid2);

file_name = ['mmpp_trace_N' num2str(N) '.mat'];
save(file_name,'N','p_asc','p_desc','arrivals','num_requests','size_arr');

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