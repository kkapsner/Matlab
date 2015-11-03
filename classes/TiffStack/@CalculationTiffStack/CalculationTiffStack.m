classdef CalculationTiffStack < AbstractTiffStack
    %CalculationTiffStack
    %   stacks must be of equal size (same number of tiff images in stack)
    %   and images must be all of same size
    
    properties(SetAccess=private)
        stack1
        operation
        stack2
    end
    
    methods
        function this = CalculationTiffStack(stack1, operation, stack2)
            this.stack1 = stack1;
            this.operation = operation;
            this.stack2 = stack2;
        end
        
        function width = getWidth(this)
            width = this.stack1.width;
        end
        
        function height = getHeight(this)
            height = this.stack1.height;
        end
        
        function size = getSize(this)
            size = this.stack1.size;
        end
        
        function image = getUncachedImage(this, index)
            image1 = double(this.stack1.getImage(index));
            if (isnumeric(this.stack2))
                image2 = this.stack2;
            else
                image2 = double(this.stack2.getImage(index));
            end
            switch this.operation
                case '+'
                    image = image1 + image2;
                case '-'
                    image = image1 - image2;
                case '*'
                    image = image1 .* image2;
                case '/'
                    image = image1 ./ image2;
                case '^'
                    image = image1 .^ image2;
            end
        end
    end
    
    
    methods (Access=protected)
        function cp = copyElement(this)
            cp = copyElement@matlab.mixin.Copyable(this);
            cp.stack1 = copy(this.stack1);
            cp.stack2 = copy(this.stack2);
        end
    end
    methods(Static)
        stack = guiCalculate(stacks)
    end
end

