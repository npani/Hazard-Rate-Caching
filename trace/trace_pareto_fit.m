format long g

load('data_trace1_popular.mat');
data = data_trace1;

N = max(data(:,3));
disp('Trace files read...');

k_shape = zeros(1,N);
sigma_scale = zeros(1,N);


for i = 1:N
    disp(i)
    ind = data(:,3) == i;% arrival times for ith content
    x = diff(data(ind,1));  % inter-request times for ith content
    parmhat = gpfit(x);
    k_shape(i) = parmhat(1);
    sigma_scale(i) = parmhat(2);
end
save('fitted_model_pareto_trace1.mat','k_shape','sigma_scale');