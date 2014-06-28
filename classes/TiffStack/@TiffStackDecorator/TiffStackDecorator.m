classdef (Abstract) TiffStackDecorator < AbstractTiffStack
    properties (SetAccess=protected)
        stack
    end
    
    methods
        function obj = TiffStackDecorator(stack)
            if (nargin > 0)
                stack = TiffStackDecorator.uniformStack(stack);
                
                if (numel(stack) > 1)
                    c = class(obj);
                    s = num2cell(size(stack));
                    obj(s{:}) = feval(c);
                    for i = 1:numel(stack)
                        obj(i).stack = stack{i};
                    end
                elseif (numel(stack) == 1)
                    obj.stack = stack;
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
    
    methods (Abstract)
        image = getUncachedImage(obj, index)
    end
    
    methods (Static)
        obj = guiAddDecorator(obj)
    end
end