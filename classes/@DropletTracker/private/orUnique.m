%ORUNIQUE searches for double entries in a matrix
%   ASSIGNMENT = orUnique(A) searches along the first dimension of A for
%   double entires in the remaining dimensions.
%   ASSIGNMENT is a vector with length size(A, 1). It is zero for a "row"
%   that is unique in A or is the first entry of a double entry. Otherwise
%   it contains the index of the first entry of the doubles.
%
%   Example:
%       >> A = [1 2; 1 1; 2 2; 3 3]
%
%       A =
% 
%             1     2
%             1     1
%             2     2
%             3     3
%
%       >> Ass = orUnique(A)
%       
%       Ass =
%
%            0
%            1
%            1
%            0