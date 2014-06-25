classdef FileInput < handle & hgsetget
    events
        resize
        valueChange
    end
    
    properties(Access=private)
        value
        handles
    end
    
    properties(Dependent)
        containerHandle
    end
    
    methods
        function input = FileInput(varargin)
            input.handles = input.createHandles(varargin{:});
        end
    end
    
    methods
        function h = get.containerHandle(input)
            h = input.handles.container;
        end
        
        function value = get.value(input)
            value = input.value;
        end
    end
end