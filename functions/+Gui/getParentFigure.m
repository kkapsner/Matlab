function f = getParentFigure(element)
% GETPARENTFIGURE retreives the parent figure of an element.
    f = element;
    while (~strcmpi(get(f, 'Type'), 'figure') && ~isempty(f))
        f = get(f, 'Parent');
    end
end