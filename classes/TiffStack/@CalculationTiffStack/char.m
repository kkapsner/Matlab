function str = char(this)
%CHAR cast function to char
    
    if (isnumeric(this.stack2))
        str = sprintf('(%s %s %f)', this.stack1.char(), this.operation, this.stack2);
    else
        str = sprintf('(%s %s %s)', this.stack1.char(), this.operation, this.stack2.char());
    end
end

