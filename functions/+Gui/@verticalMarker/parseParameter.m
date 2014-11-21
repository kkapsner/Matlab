function parseParameter(obj, varargin)
%PARSEPARAMETER parses the parameter of the constructor
%   
    isBooleanString = @(x) isa(x, 'logical') || any(validatestring(x, {'off', 'on'}));
    p = inputParser;
    p.addRequired('Axes', @ishandle);
    p.addOptional('Parent', -1, @ishandle);
    p.addOptional('Min', -Inf, @isnumeric);
    p.addOptional('MinInput', 'off', isBooleanString);
    p.addOptional('Max', Inf, @isnumeric);
    p.addOptional('MaxInput', 'off', isBooleanString);
    p.addOptional('Value', 0, @isnumeric);
    p.addOptional('ValueInput', 'off', isBooleanString);
    p.addOptional('SliderInput', 'on', isBooleanString);
    p.addOptional('Color', [0 0 0]);
    p.addOptional('Position', [1 1 300 40]);
    p.addOptional('Units', 'Pixel');
    p.addOptional('UserData', []);

    p.parse(varargin{:});
    
    names = fieldnames(p.Results);
    for i = 1:numel(names)
        name = names{i};
        objName = [lower(name(1)) name(2:end)];
        try
            obj.(objName) = p.Results.(names{i});
        end
    end
    
    if (~ishandle(obj.parent))
        obj.parent = ancestor(p.Results.Axes, 'figure');
    end
    
    dim = get(obj.axes, 'XLim');
    if (~isfinite(obj.min))
        obj.min = dim(1);
    end
    
    if (~isfinite(obj.max))
        obj.max = dim(2);
    end
    
    if (obj.max < obj.min)
        [obj.max, obj.min] = deal(obj.min, obj.max);
    end
    
    if (obj.value < obj.min)
        obj.value = obj.min;
    elseif (obj.value > obj.max)
        obj.value = obj.max;
    end
end

