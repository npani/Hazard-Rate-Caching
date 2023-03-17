function y = check_hit(last_hit,curr_time,a,b,index,c)
y = 0;
x = curr_time-last_hit;
hr = ones(1,size(a,2))./(b-x);
[~,idx] = sort(hr,'descend');
if(find(idx==index)<=c)
    y=1;
end    
end
