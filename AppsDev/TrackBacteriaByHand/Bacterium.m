classdef (Abstract) Bacterium < handle
    
    properties (SetAccess=private)
        parent = [];
        children = [];
    end
    properties (Dependent)
        dataSize
    end
    
    methods
        function this = Bacterium(parent)
            this.parent = parent;
            if (~isempty(parent))
                if (isempty(parent.children))
                    parent.children = this;
                else
                    parent.children(end + 1) = this;
                end
            end
        end
        
        function dataSize = get.dataSize(this)
            dataSize = this.getDataSize();
        end
        
        
        function bac = getEndBacteria(this)
            if (numel(this) > 1)
                bac = this(1).getEndBacteria();
                for b = this
                    bac = [bac, b.getEndBacteria()];
                end
            else
                if (isempty(this.children))
                    bac = this;
                else
                    bac = [ ...
                        this.children(1).getEndBacteria(), ...
                        this.children(2).getEndBacteria() ...
                    ];
                end
            end
        end
    end
    
    methods (Abstract)
        dataSize = getDataSize(this);
    end
end