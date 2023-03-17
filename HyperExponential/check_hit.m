function y = check_hit(last_hit,curr_time,p1,p2,lambda1,lambda2,index,c)
y = 0;
x = curr_time-last_hit;
pdf = p1*lambda1.*exp(-lambda1.*x)+ p2*lambda2.*exp(-lambda2.*x);
ccdf = p1*exp(-lambda1.*x)+ p2*exp(-lambda2.*x);
hr = pdf./ccdf;
[~,idx] = sort(hr,'descend');
if(find(idx==index)<=c)
    y=1;
end    
end
