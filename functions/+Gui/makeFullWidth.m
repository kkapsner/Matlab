function makeFullWidth(element, dynX, dynWidth)
%GUI.MAKEFULLWIDTH makes an element always the same width than the parent
%
%   Gui.makeFullWidth(element) sets the neccessary event listeners to bind
%       the width of the element to the width of the parent element
%   Gui.makeFullWidth(..., dynX) sets the x-position according to the
%       return value of the dynX-function that is called with the width of
%       the parent element
%   Gui.makeFullWidth(..., dynWidth) if the dynWidth-parameter is set the
%       return value of this function (called with the width of the parent
%       element) is used to set the width.
    if (nargin < 3)
        dynX = [];
    end
    if (nargin < 4 || isempty(dynWidth))
        dynWidth = @(a)a;
    end
    try
        addlistener(element.Parent, 'SizeChanged', @callback);
    catch
        addlistener(element.Parent, 'SizeChange', @callback);
    end
    callback();
    
    function callback(~,~)
        parentWidth = handle(element.Parent).Position(3);
        if (~isempty(dynX))
            element.Position(1) = dynX(parentWidth);
        end
        element.Position(3) = max(1, dynWidth(parentWidth));
    end
end