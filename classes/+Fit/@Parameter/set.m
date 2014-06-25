function set(obj, varargin)
%SET multiple set functionality

    for i = 1:2:nargin-2
        obj.(varargin{i}) = varargin{i+1};
    end
end

