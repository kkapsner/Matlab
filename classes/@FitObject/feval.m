function y = feval(this, x)
    param = cell(size(this.arguments));
    
    for i = 1:numel(this.arguments)
        if (this.isArgumentInList(i, 'independent'))
            param{i} = x;
        else
            param{i} = this.arguments(i).value;
        end
    end
    
    y = this.func(param{:});
end