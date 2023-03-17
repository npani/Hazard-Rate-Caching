function y = check_hit(last_hit,curr_time,k,sigma,index,c, size_arr)
y = 0;
x = curr_time-last_hit;
hr = ones(1,size(k,2))./(sigma+(k.*x));
hr_over_c = (hr.')./size_arr;
[~,idx] = sort(hr_over_c,'descend');
size_hr_dec = size_arr(idx);
size_hr_dec = cumsum(size_hr_dec);
i_0 = find(size_hr_dec>c);
i_01 = i_0(1);
if(i_01==1)
    y = 0;
else
    curr = find(idx==index);
    curr_1 = curr(1);
    if(curr_1<=i_01-1)
        y=1;
    elseif(curr_1==i_01)
        z = rand;
        remaining_frac = (c - size_hr_dec(i_01-1))/size_arr(idx(i_01));
        if(z <= remaining_frac)
            y = 1;
        else
            y = 0;
        end
    else    
        y=0;
    end
end       
end
