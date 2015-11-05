classdef (Abstract) TiffStackDecorator < AbstractTiffStack
    properties (SetAccess=protected)
        stack
    end
    
    properties(Access=private, Transient)
        eventListeners
    end
    
    methods
        function this = TiffStackDecorator(stack)
            if (nargin > 0)
                stack = TiffStackDecorator.uniformStack(stack);
                
                if (numel(stack) > 1)
                    c = class(this);
                    s = num2cell(size(stack));
                    this(s{:}) = feval(c);
                    for i = 1:numel(stack)
                        this(i) = feval(c);
                        this(i).stack = stack{i};
                    end
                elseif (numel(stack) == 1)
                    this.stack = stack;
                end
                
                if (numel(stack) > 0)
                    this.renewListeners();
                end
            end
        end
        
        function size = getSize(this)
            size = this.stack.size;
        end
        
        function width = getWidth(this)
            width = this.stack.width;
        end
        
        function height = getHeight(this)
            height = this.stack.height;
        end
        
        function renewListeners(this, all)
            for o = this
                delete(o.eventListeners);
                o.eventListeners = [
                    addlistener(o.stack, 'cacheCleared', @(~,~)o.clearCache())
                    addlistener(o.stack, 'nameChanged', @(~,~)notify(o, 'nameChanged'))
                    addlistener(o.stack, 'sizeChanged', @(~,~)notify(o, 'sizeChanged'))
                ];
                if (nargin > 1 && all)
                    o.stack.renewListeners(all);
                end
            end
        end
    end
    
    methods (Access=private, Static)
        function stack = uniformStack(stack)
            if (iscell(stack))
                for i = 1:numel(stack)
                    stack{i} = TiffStackDecorator.uniformStack(stack{i});
                end
                if (numel(stack) == 1)
                    stack = stack{1};
                end
            elseif (isempty(stack))
                
            elseif (~isa(stack, 'AbstractTiffStack'))
                stack = TiffStackDecorator.uniformStack(TiffStack(stack));
            elseif (numel(stack) > 1)
                s = size(stack);
                stack = mat2cell(stack, ones(s(1), 1), ones(1, s(2))); %#ok<MMTC>
            end
        end
    end
    
    methods (Access=protected)
        function cp = copyElement(this)
            cp = copyElement@matlab.mixin.Copyable(this);
            if (this.doDeepCopy)
                cp.stack = copy(this.stack);
            end
            cp.renewListeners();
        end
        
        function [cpStack, originalStacks, copiedStacks] = copyStructureElement(this, originalStacks, copiedStacks)
            [cpStack, originalStacks, copiedStacks] = copyStructureElement@AbstractTiffStack(this, originalStacks, copiedStacks);
            [cpStack.stack, originalStacks, copiedStacks] = AbstractTiffStack.getCopiedStack(this.stack, originalStacks, copiedStacks);
            cpStack.renewListeners();
        end
    end
    
    methods (Abstract)
        image = getUncachedImage(obj, index)
    end
    
    methods (Static)
        obj = guiAddDecorator(obj)
    end
end