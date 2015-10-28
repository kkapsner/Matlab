function str = char(this)
%CHAR cast function to char
    
    str = sprintf('Background corrected %s by', this.stack.char());
    if (strcmp(this.method, 'fixed'))
        str = [str, sprintf(' %d', this.backgroundValue)];
    else
        str = [str, sprintf(' <%s>', this.method)];
    end
end

