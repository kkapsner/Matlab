classdef EmptyTiffStack < AbstractTiffStack & handle
    methods
        function size = getSize(this)
            size = [0, 0];
        end
        
        function height = getHeight(this)
            height = 0;
        end
        
        function width = getWidth(this)
            width = 0;
        end
        
        function image = getUncachedImage(this, idx)
            image = zeros(0, 0);
        end
        
        function str = char(this)
            str = 'Empty stack.';
        end
        
        function panel = getNamePanel(this)
            panel = [];
        end
    end
end