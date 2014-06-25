classdef ConvolutedTiffStack < TiffStackDecorator
    %ConvolutedTiffStack
    
    properties(SetAccess=private, SetObservable)
        convolutionMatrix
    end
    properties(SetObservable)
        filterOn = true
    end
    
    methods
        function obj = ConvolutedTiffStack(stack, convolutionMatrix)
            if (nargin == 0)
                stack = [];
            end
            obj = obj@TiffStackDecorator(stack);
            
            if (nargin > 0)
                if (nargin < 2)
                    convolutionMatrix = 1;
                end
                obj.setConvolutionMatrix(convolutionMatrix);
            end
        end
    end
    
    methods
        function setConvolutionMatrix(this, convolutionMatrix)
            for o = this
                o.convolutionMatrix = convolutionMatrix;
                o.clearCache();
            end
        end
        
        function set.filterOn(this, value)
            this.filterOn = value;
            this.clearCache();
        end
        
        function image = getUncachedImage(obj, index)
            image = obj.stack.getImage(index);
            if (obj.filterOn)
                image = conv2(image, obj.convolutionMatrix, 'same') ./ conv2(ones(size(image)), obj.convolutionMatrix, 'same');
            end
        end
    end
    
    methods (Static)
        [panel, getParameter] = getGUIParameterPanel(parent)
    end
end

