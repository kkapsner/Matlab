function [varargout] = getControlProperty(obj, control, varargin)
    if isfield(obj.controls, control) && ishandle(obj.controls.(control))
        [varargout{1:nargout}] = get(obj.controls.(control), varargin{:});
    else
        varargout = [];
    end
end