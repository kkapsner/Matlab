classdef BackgroundCorrectedTiffStack < TiffStackDecorator
    %BackgroundCorrectedTiffStack
    %   
    
    properties(SetAccess=private)
        backgroundStack
    end
    
    methods
        function this = BackgroundCorrectedTiffStack(stack, backgroundStack)
            if (nargin == 0)
                stack = [];
            end
            
            this = this@TiffStackDecorator(stack);
            if (nargin > 0)
                for o = this
                    if (nargin < 3)
                        backgroundStack = CroppedTiffStack(o.stack);
                    end
                    o.backgroundStack = backgroundStack;
                    addlistener(backgroundStack, 'cacheCleared', @(~,~)o.clearCache());
                end
            end
        end
    end
    
    methods
        
        function image = getUncachedImage(this, index)
            image = this.stack.getImage(index);
            background = this.backgroundStack.getImage(index);
            background = mean(background(:));
            image = double(image) - background;
        end
    end
    
    methods (Static)
        [panel, getParameter] = getGUIParameterPanel(parent)
    end
end

