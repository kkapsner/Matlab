classdef CalculationTiffStack < AbstractTiffStack
    %CalculationTiffStack
    %   stacks must be of equal size (same number of tiff images in stack)
    %   and images must be all of same size
    
    properties(SetAccess=private)
        stack1
        operation
        stack2
    end
    
    properties(Access=private, Transient)
        eventListeners
    end
    
    methods
        function this = CalculationTiffStack(stack1, operation, stack2)
            this.stack1 = stack1;
            this.operation = operation;
            this.stack2 = stack2;
            
            this.renewListeners();
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
        
        function renewListeners(this, all)
            for o = this
                delete(o.eventListeners);
                o.eventListeners = [
                    addlistener(o.stack1, 'cacheCleared', @(~,~)o.clearCache())
                    addlistener(o.stack1, 'nameChanged', @(~,~)notify(o, 'nameChanged'))
                    addlistener(o.stack1, 'sizeChanged', @(~,~)notify(o, 'sizeChanged'))
                    addlistener(o.stack2, 'cacheCleared', @(~,~)o.clearCache())
                    addlistener(o.stack2, 'nameChanged', @(~,~)notify(o, 'nameChanged'))
                    addlistener(o.stack2, 'sizeChanged', @(~,~)notify(o, 'sizeChanged'))
                ];
                if (nargin > 1 && all)
                    o.stack1.renewListeners(all);
                    o.stack2.renewListeners(all);
                end
            end
        end
    end
    
    
    methods (Access=protected)
        function cp = copyElement(this)
            cp = copyElement@matlab.mixin.Copyable(this);
            if (this.doDeepCopy)
                cp.stack1 = copy(this.stack1);
                cp.stack2 = copy(this.stack2);
            end
            cp.renewListeners();
        end
        
        function [cpStack, originalStacks, copiedStacks] = copyStructureElement(this, originalStacks, copiedStacks)
            [cpStack, originalStacks, copiedStacks] = copyStructureElement@AbstractTiffStack(this, originalStacks, copiedStacks);
            [cpStack.stack1, originalStacks, copiedStacks] = AbstractTiffStack.getCopiedStack(this.stack1, originalStacks, copiedStacks);
            [cpStack.stack2, originalStacks, copiedStacks] = AbstractTiffStack.getCopiedStack(this.stack2, originalStacks, copiedStacks);
            cpStack.renewListeners();
        end
    end
    methods(Static)
        stack = guiCalculate(stacks)
    end
end

