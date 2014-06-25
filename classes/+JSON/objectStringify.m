function json = objectStringify(obj, param, varargin)

    map = containers.Map({'MATLAB::constructor'}, {class(obj)}, 'UniformValues', false);
    
    if (~isempty(param))
        map('MATLAB::constructor::parameter') = param;
    end
    for i = 1:numel(varargin)
        map(varargin{i}) = obj.(varargin{i});
    end
    json = JSON.stringify(map);
end