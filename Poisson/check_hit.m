function y = check_hit(p,index,c)
y = 0;
hr = p;
[~,idx] = sort(hr,'descend');
if(find(idx==index)<=c)
    y=1;
end    
end
