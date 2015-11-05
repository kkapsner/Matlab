classdef Position < handle & matlab.mixin.Copyable
    
    properties
        index
        stacks
    end
    
    methods
        function this = Position(index)
            this.index = index;
        end
    end
    
    methods (Access=protected)
        function cp = copyElement(this)
            cp = copyElement@matlab.mixin.Copyable(this);
            cp.stacks = AbstractTiffStack.copyStructure(this.stacks);
        end
    end
end

