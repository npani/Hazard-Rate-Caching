% Size of the content catalog
N = 1000;
% Maximum simulation time
Tmax = 5*10^3;

% N = 100;
% Tmax = 5*10^2;

% Parameters for independent on-off request process
Ton = 7;
Toff = 63;
mu01 = 1/Toff;
mu10 = 1/Ton;
pi0 = (mu10/(mu10+mu01));


%Popularity profile for contents in an on period
E_V = 10;
beta = 2.0;
V_min = ((beta-1)/beta)*E_V;

% Parameters for Pareto distribution
k = 1/beta;
sigma = V_min*k;
theta = sigma/k;

p = gprnd(k,sigma,theta,N,1)./(Ton*ones(N,1));
p = sort(p,'descend');

all_arrivals = [];

% Parameters to determine size of the content if variable size
l = 5.0;
h = 15.0;
a = 1.8;
size_arr = zeros(N,1);

boundary_times = {};
states = {};
is_first_req=[];

for n=1:N
    if (mod(n, 10^4) == 0)
        fprintf('Content id: %d\n',n);
    end
    
    % nth_arrivals: Arrival time instances of a content n
    % boundary_times_i: Time instances at which transition between states (0 to 1 and 1 to 0) occurs
    % states: states (0 or 1) at boundary times
    
    [nth_arrivals,boundary_times_i,states_i] = generate_on_off(mu01, mu10, Tmax, p(n));   
%     all_arrivals = [all_arrivals; [nth_arrivals, n*ones(length(nth_arrivals), 1)]];
    all_arrivals = [all_arrivals; [nth_arrivals, n*ones(length(nth_arrivals), 1)]];
    boundary_times{n} = boundary_times_i;
    states{n} = states_i;    
%     boundary_times = [boundary_times; [boundary_times_i, n*ones(length(boundary_times_i), 1)]];
%     states = [states; [states_i, n*ones(length(states_i), 1)]];
    us = rand;
    size_arr(n,1) = round(l/(1+us*(((l/h)^a)-1))^ (1.0/a));
end
[arriv_times, srt_ind] = sort(all_arrivals(:, 1));
arrivals = [arriv_times, all_arrivals(srt_ind, 2)];
% clear all_arrivals arriv_times srt_ind;
check_error = 0;

[num_requests, num_columns] = size(arrivals);

file_name = ['on_off_trace_N' num2str(N) '.txt'];
file_name_with_size = ['on_off_trace_N' num2str(N) '_with_size.txt'];

fid1 = fopen(file_name,'w');
fid2 = fopen(file_name_with_size,'w');
for k = 1:num_requests
    fprintf(fid1, '%d %d %d \n', round(arrivals(k,1)), arrivals(k,2), 1.0);   
    fprintf(fid2, '%d %d %d \n', round(arrivals(k,1)), arrivals(k,2), size_arr(arrivals(k,2),1));   
end  

fclose(fid1);
fclose(fid2);

file_name = ['on_off_trace_N' num2str(N) '_new.mat'];
save(file_name,'N','p','states','boundary_times','arrivals','num_requests','all_arrivals','size_arr');


% Generates content requests according to independent on-off process for a single content 
function [arrival_times, boundary_times,states] = generate_on_off(mu01, mu10, Tmax, p_i)
r = 0;
pi0 = (mu10/(mu10+mu01));
arrival_times=[];
boundary_times=[];
boundary_times = [boundary_times,0];
states = [];
a = rand;
time = 0;

% Set the first period as on or off
if(a<pi0)
    idx = 0;
    states = [states,0];
else
    idx = 1;
    states = [states,1];
end

while 1
    if(r > Tmax)
        break;
    end    
    if(idx == 0)
        r = r + exprnd(1/mu01);  
        boundary_times = [boundary_times,r];
        time = r;
        idx = 1;
        states = [states,1];
    else
        r = r + exprnd(1/mu10);
        states = [states,0];
        boundary_times = [boundary_times,r];
        time = time + exprnd(1/p_i);
        while(time < r)
            arrival_times=[arrival_times,time];
            time = time + exprnd(1/p_i);
        end  
        idx = 0;
    end     
end
arrival_times = arrival_times.';
% boundary_times = boundary_times.';
% states = states.';
end

