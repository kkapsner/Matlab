classdef FunctionTiffStack < TiffStackDecorator
    %FunctionTiffStack
    
    properties(SetObservable)
        func
    end
    
    methods
        function this = FunctionTiffStack(stack, func)
            if (nargin == 0)
                stack = [];
            end
            this = this@TiffStackDecorator(stack);
            
            if (nargin > 0)
                this.setFunc(func);
            end
        end
    end
    
    methods
        function setFunc(this, func)
            for o = this
                o.func = func;
            end
        end
        
        function image = getUncachedImage(this, index)
            image = this.func(this.stack.getImage(index), index);
        end
    end
    
    methods (Static)
        [panel, getParameter] = getGUIParameterPanel(parent)
    end
end

