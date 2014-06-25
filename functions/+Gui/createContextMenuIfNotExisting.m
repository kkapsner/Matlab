function contextmenu = createContextMenuIfNotExisting(element)
%CREATECONTEXTMENUIFNOTEXISTING creates a context menu for the element
%   CONTEXTMENU = CREATECONTEXTMENUIFNOTEXISTING(ELEMENT) creates a context
%       menu for the elemente if it does not have one already
    
    contextmenu = get(element, 'uicontextmenu');
    if (isempty(contextmenu))
        contextmenu = uicontextmenu( ...
            'Parent', Gui.getParentFigure(element) ...
        );
        set(element, 'uicontextmenu', contextmenu);
    end
end

