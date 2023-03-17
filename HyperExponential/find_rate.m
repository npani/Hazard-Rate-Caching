function [r] = find_rate(p1,l1,l2)
a = rand;
if(a<p1)
    r=l1;
else
    r=l2;
end