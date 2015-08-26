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
    
    methods(Static)
        [panel, getParameter] = getGUIParameterPanel(parent)
        
        function img = medianBased(img, ~)
            %FUNCTIONTIFFSTACK.MEDIANBASED
            %
            % Function to be used to set the median of the image to one
            % and mirror the pixels above one down.
            img = double(img);
            med =  abs(img - median(img(:)));
            [min, max] = minmax(med);
            img = (max - med) ./ (max - min);
        end
        function img = inverted(img, ~)
            %FUNCITONTIFFSTACK.INVERTED
            %
            % Function to be used to invert the image.
            img = double(img);
            [min, max] = minmax(img(:));
            img = (max - img)./(max - min);
        end
        function img = normalised(img, ~)
            %FUNCITONTIFFSTACK.NORMALISED
            %
            % Function to be used to normalise the image between 0 and 1.
            img = double(img);
            [min, max] = minmax(img(:));
            img = (img - min)./(max - min);
        end
    end
end

