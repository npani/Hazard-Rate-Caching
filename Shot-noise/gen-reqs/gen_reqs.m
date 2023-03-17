% Earlier parameters
% toal_contents = 0.93 * 10^6;
% frac_contents_classwise = [0.0317 0.049 0.0295 0.0445];
% gamma_overall = 2.657 * (10^4);
% class_N = toal_contents * frac_contents_classwise;
% class_cumsum_N = cumsum(class_N);
% class_L = [1.14 3.36 6.40 10.53];
% class_L = class_L/0.8;
% class_alpha = class_L/2;
% class_gammas = class_N./class_L;
% class_E_Vm = [86.4 41.9 59.5 36.9];
% class_id = [1 2 3 4];
% N = sum(class_N);

toal_contents = 0.93 * 10^6;
frac_contents_classwise = [0.0317 0.049 0.0295 0.0445];
gamma_overall = 2.657 * (10^4);
class_N = toal_contents * frac_contents_classwise;
class_cumsum_N = cumsum(class_N);
class_L = [1.14 3.36 6.40 10.53];
class_alpha = class_L/log(9);
class_gammas = frac_contents_classwise*gamma_overall;
class_E_Vm = [86.4 41.9 59.5 36.9];
class_id = [1 2 3 4];
N = sum(class_N);


meta_data_contents = zeros(N, 5);
meta_data_contents(:,1) = repelem(class_id,class_N).';
meta_data_contents(:,2) = repelem(class_E_Vm,class_N).';
meta_data_contents(:,3) = repelem(class_alpha,class_N).';
meta_data_contents(:,4) = poissrnd(meta_data_contents(:,2)).';
total = 0;
meta_data_contents(1:class_cumsum_N(1),5) = cumsum(exprnd(1/class_gammas(1), class_N(1), 1));
for i=2:4
    meta_data_contents(class_cumsum_N(i-1)+1:class_cumsum_N(i),5) = cumsum(exprnd(1/class_gammas(i), class_N(i), 1));
end    

all_arrivals = [];
l = 5.0;
h = 15.0;
a = 1.8;
size_arr = zeros(N,1);
for n=1:N
    if (mod(n, 10^4) == 0)
        fprintf('Content id: %d\n',n);
    end
    V_n = meta_data_contents(n,4);
    L = meta_data_contents(n,3);
    tau = meta_data_contents(n,5);
    us = rand;
    size_arr(n,1) = round(l/(1+us*(((l/h)^a)-1))^ (1.0/a));
    nth_arrivals = nonhomopp(@(x)((V_n/L)*exp(-1*x/L)), V_n,V_n/L, tau);
    all_arrivals = [all_arrivals; [nth_arrivals, n*ones(length(nth_arrivals), 1)]];
end
[arriv_times, srt_ind] = sort(all_arrivals(:, 1));
arrivals = [arriv_times, all_arrivals(srt_ind, 2)];
clear all_arrivals arriv_times srt_ind;
check_error = 0;

[num_requests, columns] = size(arrivals);

disp(num_requests);


file_name = ['shot_noise_trace_N' num2str(N) '_new_params.txt'];
file_name_with_size = ['shot_noise_trace_N' num2str(N) '_with_size_new_params.txt'];

fid1 = fopen(file_name,'w');
fid2 = fopen(file_name_with_size,'w');
for k = 1:num_requests
    fprintf(fid1, '%d %d %d \n', round(arrivals(k,1)), arrivals(k,2), 1.0);   
    fprintf(fid2, '%d %d %d \n', round(arrivals(k,1)), arrivals(k,2), size_arr(arrivals(k,2),1));   
end  

% fileID = fopen(file_name,'r');
% formatSpec = '%d %d %d';
% sizeA = [3 Inf];
% 
% arrivals = fscanf(fileID,formatSpec,sizeA);
% arrivals = arrivals';
% [num_requests, columns] = size(arrivals);

% file_name_with_size = ['shot_noise_trace_N' num2str(N) '_with_size.txt'];
% fid =fopen(file_name_with_size, 'w' );
% 
% for k = 1:num_requests-1
%     fprintf(fid, '%d %d %d \n', round(arrivals(k,1)), arrivals(k,2), size_arr(arrivals(k,2),1));   
% end   

fclose(fid1);
fclose(fid2);

[~, srt_ind_pop] = sort(meta_data_contents(:,4)./meta_data_contents(n,3),'descend');
file_name = ['shot_noise_trace_N' num2str(N) '_new_params.mat'];
save(file_name);

function y = nonhomopp(intens,no_of_points,lambdad_max, tau)
y = zeros(no_of_points, 1);
time_init = tau+exprnd(1/lambdad_max);
y(1,1) = time_init;
for i=2:no_of_points
    rate_item = intens(time_init-tau);
    y(i,1) = y(i-1,1) + exprnd(1/rate_item);
    time_init = y(i,1);
    if(time_init > 10^6)
        break;
    end    
end   
y = y(1:i-1,1);
end

