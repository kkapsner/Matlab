classdef (Abstract) CellManager < handle
    %CELLMANAGER a GUI for managing cells containing one type of class
    
    properties(SetObservable)
        title
        content
    end
    properties(Access=protected)
        handles
    end
    
    events
        entryAdded
        entryRemoved
        winClose
        winOpen
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
            this.open();
            this.addEntry(content);
        end
        
        function wait(this)
            uiwait(this.handles.figure);
        end
        
        function delete(this)
            this.close();
        end
        
        close(this, ~,~)
        addEntry(this, entry)
        removeEntry(this, entry)
    end
    
    methods (Abstract, Access=protected)
        entry = createEntry(this)
        fillEntryPanel(this, entry, panel)
    end
    
    methods (Access=protected)
        open(this)
        panel = addEntryPanel(this, entry)
        arrangeContainer(this)
        adjustInnerContainerHeight(this)
        header = createHeader(this)
    end
    
end

