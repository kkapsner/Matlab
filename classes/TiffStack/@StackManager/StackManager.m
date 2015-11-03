classdef StackManager < Abstract.CellManager
    %STACKMANAGER a GUI for managing stacks
    
    properties(SetObservable)
        preselect
    end
    
    events
        stackAdded
        stackRemoved
    end
    
    properties(Dependent, SetObservable)
        stacks
    end
    
    methods
        function this = StackManager(title, stacks, preselect)
            if (nargin < 1)
                title = '';
            end
            if (nargin < 2)
                stacks = {};
            end
            if (nargin < 3)
                preselect = [];
            end
            this@Abstract.CellManager(title, stacks);
            this.preselect = preselect;
            addlistener(this, 'entryAdded', @(~, evt)notify(this, 'stackAdded', evt));
            addlistener(this, 'entryRemoved', @(~, evt)notify(this, 'stackRemoved', evt));
        end
        
        function stacks = get.stacks(this)
            stacks = this.content;
        end
        function set.stacks(this, stacks)
            this.content = stacks;
        end
    end
    
    methods (Access=protected)
        entry = createEntry(this)
        cp = copyEntry(this, original)
        fillEntryPanel(this, entry, panel)
        header = createHeader(this)
    end
end

