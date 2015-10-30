classdef ConstantBackgroundTiffStack < TiffStackDecorator
    %ConstantBackgroundTiffStack
    
    properties(SetObservable)
        method = 'median'
        backgroundValue = 0
    end
    
    properties(Constant)
        knownMethods = {'mean', 'median', 'mode', 'fixed'}
    end
    
    methods
        function this = ConstantBackgroundTiffStack(stack, method, backgroundValue)
            if (nargin == 0)
                stack = [];
            end
            
            this = this@TiffStackDecorator(stack);
            if (nargin > 0)
                if (nargin < 2)
                    method = 'median';
                end
                if (nargin < 3)
                    backgroundValue = 0;
                end
                for o = this
                    o.method = method;
                    o.backgroundValue = backgroundValue;
                end
            end
        end
        
        function set.method(this, method)
            assert(any(strcmp(method, this.knownMethods)), 'Unknown background method.');
            this.method = method;
            this.clearCache();
        end
        function set.backgroundValue(this, value)
            assert(isnumeric(value) && isscalar(value), 'Value has to be numeric scalar.');
            this.backgroundValue = value;
            if (strcmp(this.method, 'fixed'))
                this.clearCache();
            end
        end
    end
    
    methods
        
        function image = getUncachedImage(this, index)
            image = double(this.stack.getImage(index));
            switch (this.method)
                case 'fixed'
                    image = image - this.backgroundValue;
                case 'mean'
                    image = image - mean(image(:));
                case 'median'
                    image = image - median(image(:));
                case 'mode'
                    error('Not yet implemented.');
            end
        end
    end
    
    methods (Static)
        [panel, getParameter] = getGUIParameterPanel(parent)
    end
end

