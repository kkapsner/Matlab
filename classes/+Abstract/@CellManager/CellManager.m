classdef (Abstract) CellManager < handle
    %CELLMANAGER a GUI for managing cells containing one type of class
    
    properties(SetObservable)
        title
        content
        expandToFit = false
    end
    properties(Access=protected)
        handles
    end
    properties(Dependent)
        isOpen
    end
    
    events
        entryAdded
        entryRemoved
        winClose
        winOpen
        reset
    end
    
    methods
        function this = CellManager(title, content)
            if (nargin < 1)
                title = '';
            end
            if (nargin < 2)
                content = {};
            end
            this.title = title;
            this.content = {};
            this.addEntry(content);
        end
        
        function wait(this)
            uiwait(this.handles.figure);
        end
        
        function resetHandles(this)
            notify(this, 'reset');
            this.handles = struct();
        end
        
        function delete(this)
            this.close();
        end
        
        function isOpen = get.isOpen(this)
            isOpen = isfield(this.handles, 'figure') && ishandle(this.handles.figure);
        end
        
        close(this, ~,~)
        open(this, parent)
        addEntry(this, entry)
        removeEntry(this, entry)
        
        colorizePanels(this, startIndex)
    end
    
    methods (Abstract, Access=protected)
        entry = createEntry(this)
        fillEntryPanel(this, entry, panel)
    end
    
    methods (Access=protected)
        panel = addEntryPanel(this, entry)
        arrangeContainer(this)
        adjustInnerContainerHeight(this)
        header = createHeader(this)
    end
    
end

