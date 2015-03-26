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
                if (nargin < 3)
                    backgroundStack = CroppedTiffStack(stack);
                end
                this.backgroundStack = backgroundStack;
                addlistener(backgroundStack, 'cacheCleared', @(~,~)this.clearCache());
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

