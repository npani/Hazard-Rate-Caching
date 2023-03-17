function y = check_hit_classes(curr_time,index,C, meta_data_contents)
V = meta_data_contents(:,4);
L = meta_data_contents(:,3);
tau = meta_data_contents(:,5);
hr = (V./L).*exp(-(curr_time-tau)./L);  
hr = hr.*(curr_time > tau);
[~,idx] = sort(hr,'descend');
pos = find(idx==index);
y = (pos<= C);   
end
