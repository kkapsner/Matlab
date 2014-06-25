classdef imhline < handle
    %IMHLINE Create draggable, vertical line
    
    events
        newPosition
        dragStart
        dragStop
    end
    properties
        position
        positionConstraintFcn = @(a)a;
    end
    
    properties (Access=protected)
        drawApi
    end
    
    properties (Dependent)
        color
    end
        
    methods
        function obj = imhline(hparent, position, varargin)
            if (nargin < 1)
                hparent = gca;
            end
            if (nargin < 2)
                position = 0;
                interactive = true;
            else
                interactive = false;
            end
            
            obj.drawApi = createLineApi(hparent, position);
            obj.position = position;
            setEvents(obj);
            if interactive
                if interactivePosition(obj);
                    return;
                end
            end
            obj.drawApi.setVisible(true);
        end
        
        function set.position(obj, x)
            assert(all(size(x) == 1) && isnumeric(x), ...
                'images:imhline:invalidPositionSizeOrClass', ...
                'Position must be a numeric scalar');
            
            if (x == obj.position)
                return
            end
            
            x = obj.positionConstraintFcn(x);
            obj.drawApi.updateView(x);
            obj.position = x;
            notify(obj, 'newPosition')
        end
        
        function set.color(obj, color)
            obj.drawApi.setColor(color);
        end
        function color = get.color(obj)
           color = obj.drawApi.getColor();
        end
        function set.positionConstraintFcn(obj, func)
            try
                test = func(0);
            catch e
                error('images:imhline:badContraintFcn', ...
                    'Constraint function produces error with one argument');
            end
            
            assert(all(size(test) == 1) && isnumeric(test), ...
                'images:imhline:badConstraintFcn', ...
                'Return value of constraint function must be a numeric scalar');
            obj.positionConstraintFcn = func;
        end
        
        function ish = ishandle(obj)
            ish = ishandle(obj.drawApi.hg);
        end
        
        function complete = placeLine(obj, x)
            if (strcmp(get(obj.drawApi.figure, 'SelectionType'), 'normal'))
                obj.position = x;
                complete = true;
            else
                complete = false;
            end
        end
        
        function delete(obj)
            obj.drawApi.delete();
        end
    end
end