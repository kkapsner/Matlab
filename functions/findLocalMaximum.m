function [m, p] = findLocalMaximum(A, p)
%FINDLOCALMAXIMUM finds a maximum in the vicinity
%   [m, p] = findLocalMaximum(A, p) finds the next maximum in A starting at
%   p. Returning m is the value and p is the position of the maximum.
    while p > 2 && A(p-1) >= A(p)
        p = p - 1;
    end
    
    while p < numel(A) - 1 && A(p+1) >= A(p)
        p = p + 1;
    end
    m = A(p);
end