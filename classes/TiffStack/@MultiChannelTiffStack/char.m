function str = char(stack)
%CHAR cast function to char
    
    str = sprintf('%s<%d/%d of %s>', class(stack), stack.channel, stack.numChannel, stack.stack.char());
end

