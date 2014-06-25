function str = char(stack)
%CHAR cast function to char
    
    if (isnumeric(stack.stack2))
        str = sprintf('(%s %s %f)', stack.stack1.char(), stack.operation, stack.stack2);
    else
        str = sprintf('(%s %s %s)', stack.stack1.char(), stack.operation, stack.stack2.char());
    end
end

