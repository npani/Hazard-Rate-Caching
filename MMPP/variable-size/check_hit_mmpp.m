function y = check_hit_mmpp(index, state, C, p_desc,p_asc, size_arr)
len = size(C,2); 
if(state == 1)
    hr = p_desc;
else
    hr = p_asc;
end
[~,idx] = sort(hr./size_arr,'descend');

y = zeros(1, len);

size_hr_dec = size_arr(idx,1);
size_hr_dec = cumsum(size_hr_dec);
curr = find(idx==index);
curr_1 = curr(1);
    
for i=1:len
    y(i) = hit_or_not(size_hr_dec, C(i), curr_1, idx);
end    

function y = hit_or_not(size_hr_dec, c, curr_1, idx)
i_0 = find(size_hr_dec>c);
i_01 = i_0(1);
if(i_01==1)
    y = 0;
else
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
end


