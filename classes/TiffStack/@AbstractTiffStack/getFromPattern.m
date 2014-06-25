function stack = getFromPattern(dir, pattern, varargin)
%GETFROMPATTERN creates a stack from a string pattern
    pattern = sprintf(pattern, varargin);
    stacks = TiffStack.empty(0, 1);
    regexp(pattern, '{[^}]+}');
end

