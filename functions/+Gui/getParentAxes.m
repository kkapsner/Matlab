function f = getParentAxes(element)
% GETPARENTAXES retreives the parent axes of an element.
    f = element;
    while (~strcmpi(get(f, 'Type'), 'axes') && ~isempty(f))
        f = get(f, 'Parent');
    end
end