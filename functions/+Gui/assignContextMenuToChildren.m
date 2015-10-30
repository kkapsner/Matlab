function assignContextMenuToChildren(parent, recursive)
    %ASSIGNCONTEXTMENUTOCHILDREN propagates the context menu of the parent
    %
    %   Gui.assignContextMenuToChildren(PARENT) Assigns the context menu of
    %       PARENT to all the children of PARENT if they do not have their
    %       own.
    %   Gui.assignContextMenuToChildren(PARENT, RECURSIVE) let you specifiy
    %       if the assignment should be done recursively or not. The
    %       default is to do it recursively.
    % SEE ALSO: uicontextmenu, Gui.createContextMenuIfNotExisting
    if (nargin < 2)
        recursive = true;
    end
    contextMenu = get(parent, 'uicontextmenu');
    if (~isempty(contextMenu))
        for c = Gui.getAllChildren(parent);
            if (isempty(get(c, 'uicontextmenu')))
                set(c, 'uicontextmenu', contextMenu);
                if (recursive)
                    Gui.assignContextMenuToChildren(c, recursive);
                end
            end
        end
    end
end