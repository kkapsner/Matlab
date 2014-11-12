function z = feval2D(this, x, y)
    if (nargin < 2)
        x = linspace(this.startX, this.endX, 200);
    end
    if (nargin < 3)
        y = linspace(this.startY, this.endY, 200);
    end
    param = cell(size(this.arguments));
    
    dims = [numel(y), numel(x)];
    
    x = ones(dims(1), 1) * reshape(x, 1, []);
    y = reshape(y, [], 1) * ones(1, dims(2), 1);
    
    assignY = false;
    for i = 1:numel(this.arguments)
        if (this.isArgumentInList(i, 'independent'))
            if (assignY)
                param{i} = y;
            else
                assignY = true;
                param{i} = x;
            end
        else
            param{i} = this.arguments(i).value;
        end
    end
    
    z = this.func(param{:});
end