classdef SegmentFilterManager < Abstract.CellManager
    methods
        function this = SegmentFilterManager(varargin)
            this@Abstract.CellManager(varargin{:});
        end
    end
    methods (Access=protected)
        entry = createEntry(this)
        cp = copyEntry(this, original)
        fillEntryPanel(this, entry, panel)
    end
end

