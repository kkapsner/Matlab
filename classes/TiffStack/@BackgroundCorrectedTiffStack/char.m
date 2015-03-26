function str = char(this)
%CHAR cast function to char
    
    str = sprintf('Background corrected %s', this.stack.char());
end

