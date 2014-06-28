function str = char(this)
%CHAR cast function to char
    
    str = sprintf('%s<%d/%d of %s>', class(this), this.channel, this.numChannel, this.stack.char());
end

