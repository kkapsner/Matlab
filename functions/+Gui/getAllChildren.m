function children = getAllChildren(parent)
    %GETALLCHILDREN returns all children of an element
    %
    %   This function does ignore the handleVisibility property of any
    %   element and will return a row vector of really all children.
    oldShowHiddenHandles = get(0, 'ShowHiddenHandles');
    set(0, 'ShowHiddenHandles', 'on');
    children = reshape(get(parent, 'Children'), 1, []);
    set(0, 'ShowHiddenHandles', oldShowHiddenHandles);
end