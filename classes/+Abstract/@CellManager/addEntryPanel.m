function panel = addEntryPanel(this, entry)
%ADDENTRYPANEL adds a panel for the entry
    panel = this.handles.innerAPI.addPanel( ...
        'Units', 'Pixels', ...
        'BorderWidth', 0, ...
        'Position', [0, 0, 30, 30]...
    );
    contextMenu = Gui.createContextMenuIfNotExisting(panel);
    moveUpMenu = uimenu(contextMenu, 'Label', 'move up', 'Callback', @moveUp);
    moveDownMenu = uimenu(contextMenu, 'Label', 'move down', 'Callback', @moveDown);
    uimenu(contextMenu, 'Label', 'delete', 'Callback', @(~,~)this.removeEntry(entry));
    updateContextMenu();
    l = [
        addlistener(this, 'content', 'PostSet', @updateContextMenu);
        addlistener(panel, 'ObjectBeingDestroyed', @removeListener)
    ];
    
    this.fillEntryPanel(entry, panel);
    
    Gui.assignContextMenuToChildren(panel, true);
    
    function moveUp(~,~)
        moveEntry(-1);
    end
    function moveDown(~,~)
        moveEntry(1);
    end
    function moveEntry(dir)
        numContent = numel(this.content);
        oldIndex = getEntryIndex();
        newIndex = oldIndex + dir;
        if (newIndex > 0 && newIndex < numContent)
            arrangement = [1:(oldIndex-1),(oldIndex+1):numContent];
            arrangement = [
                arrangement(1:(newIndex-1)), ...
                oldIndex, ...
                arrangement(newIndex:end) ...
            ];
            this.content = this.content(arrangement);
            this.handles.entryPanels = this.handles.entryPanels(arrangement);
            this.handles.innerContainer.Children = [this.handles.entryPanels{end:-1:1}];
            this.handles.innerAPI.layout();
            this.colorizePanels();
        end
        
    end
    function index = getEntryIndex()
        filter = cellfun(@(s)entry == s, this.content);
        index = find(filter, 1, 'first');
    end
    
    function updateContextMenu(~,~)
        entryIndex = getEntryIndex();
        isFirst = entryIndex == 1;
        isLast = entryIndex == numel(this.content);
        moveUpMenu.Enable = Gui.booleanToStr(~isFirst);
        moveDownMenu.Enable = Gui.booleanToStr(~isLast);
    end
    function removeListener(~,~)
        delete(l);
    end
end

