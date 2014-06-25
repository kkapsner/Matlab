classdef CalculationTiffStack < TiffStack
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
        
        function size = getSize(this)
            size = this.stack1.size;
        end
        function info = getInfo(this)
            info = this.stack1.info;
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
    
    methods(Static)
        stack = guiCalculate(stacks)
    end
end

