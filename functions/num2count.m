function str = num2count(num)
%NUM2COUNT 
%   
    if num == 1
        str = '1st';
    elseif num == 2
        str = '2nd';
    else
        str = sprintf('%uth', num);
    end
end

