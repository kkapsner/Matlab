function y = feval(this, x)
    if (nargin < 2)
        x = linspace(this.startX, this.endX, 200);
    end
    param = cell(size(this.arguments));
    
    for i = 1:numel(this.arguments)
        if (this.isArgumentInList(i, 'independent'))
            param{i} = x;
        else
            param{i} = this.arguments(i).value;
        end
    end
    
    y = this.func(param{:});
    if (numel(y) ~= numel(x))
        y = nan(size(x));
    end
end