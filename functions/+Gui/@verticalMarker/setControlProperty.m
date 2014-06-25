function setControlProperty(obj, control, varargin)
    if isfield(obj.controls, control) && ishandle(obj.controls.(control))
        set(obj.controls.(control), varargin{:});
    end

end

