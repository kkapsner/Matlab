classdef CachedTiffStack < TiffStackDecorator
    %CachedTiffStack
    
    properties(SetAccess=private, SetObservable)
        video
    end
    
    methods
        function obj = CachedTiffStack(stack)
            if (nargin == 0)
                stack = [];
            end
            obj = obj@TiffStackDecorator(stack);
            obj.reloadCache();
        end
    end
    
    methods
        function width = getWidth(this)
            width = size(this.video, 2);
        end
        
        function height = getHeight(this)
            height = size(this.video, 1);
        end
        
        function length = getSize(this)
            length = size(this.video, 3);
        end
        
        function reloadCache(this)
            for o = this
                firstImage = this.stack.getImage(1);
                this.video = zeros(size(firstImage, 1), size(firstImage, 2), this.size);
                for index = 1:this.size
                    this.video(:, :, index) = this.stack.getImage(index);
                end
            end
        end
        
        function image = getUncachedImage(this, index)
            image = this.video(:, :, index);
        end
    end
    
    methods (Static)
        [panel, getParameter] = getGUIParameterPanel(parent)
    end
end

