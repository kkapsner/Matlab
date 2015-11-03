classdef PositionManager < Abstract.CellManager
    properties
        preselect
    end
    methods
        function this = PositionManager(title, content, preselect)
            if (nargin < 1)
                title = '';
            end
            if (nargin < 2)
                content = {};
            end
            if (nargin < 3)
                preselect = [];
            end
            this@Abstract.CellManager(title, content);
            this.contentName = 'Positions';
            this.preselect = preselect;
        end
    end
    
    methods (Access=protected)
        entry = createEntry(this)
        cp = copyEntry(this, original)
        fillEntryPanel(this, entry, panel)
    end
    
end

