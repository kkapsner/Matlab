function json = objectStringify(obj, param, varargin)
    map = JSON.objectToMap(obj, param, varargin{:});
    json = JSON.stringify(map);
end