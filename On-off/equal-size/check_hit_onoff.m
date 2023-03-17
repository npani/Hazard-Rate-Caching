function y = check_hit_onoff(time,index,C, p, N, boundary_times, states)
isActive = zeros(N,1);
for n=1:N
    boundary_times_for_n = boundary_times{n};
    states_for_n = states{n};
    [~, index_state] = histc(time, boundary_times_for_n);
    if(index_state==0)
        isActive(n,1) = states_for_n(1,end);
    else
        isActive(n,1) = states_for_n(1, index_state);
    end
end
hr = p.*isActive;
[~,idx] = sort(hr,'descend');
pos = find(idx==index);
y = (pos<= C);   
end

%     ind = boundary_times(:,2) == n;
%     ind2 = states(:,2) == n;
%     boundary_times_for_n = boundary_times(ind,1);
%     states_for_n = states(ind,1);
%     diffValues = boundary_times_for_n - time;
%     diffValues(diffValues > 0) = -inf;
%     [~, indexOfMax] = max(diffValues);
