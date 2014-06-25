function str = char(stack)
%CHAR cast function to char
    
    str = sprintf('%s<%s>', class(stack), stack.stack.char());
end

