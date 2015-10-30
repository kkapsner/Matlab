classdef PositionManager < Abstract.CellManager
    
    methods
        function this = PositionManager(title, content)
            if (nargin < 1)
                title = '';
            end
            if (nargin < 2)
                content = {};
            end
            this@Abstract.CellManager(title, content);
            this.contentName = 'Positions';
        end
    end
    
    methods (Access=protected)
        entry = createEntry(this)
        fillEntryPanel(this, entry, panel)
    end
    
end

