function [y, x] = fast_ind2sub(s, idx)
%FAST_IND2SUB provides a faster ind2sub for two dimensional matrices

    y_ = (1:s(1))' * ones(1, s(2));
    y = y_(idx);
    
    x_ = ones(s(1), 1) * (1:s(2));
    x = x_(idx);
end

