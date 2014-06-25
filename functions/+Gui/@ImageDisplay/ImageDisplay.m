classdef ImageDisplay < handle
    events
        newImage
        rescale
    end
    
    properties(Access=private)
        handles
    end
    
    properties(Dependent)
        colormap
    end
    
    methods
        function obj = ImageDisplay(varargin)
            obj.createHandles(varargin{:});
        end
        
        function setColorMode(mode)
            
        end
    end
    
    methods
        function set.colormap(obj, map)
            if (isa(map, 'String'))
                
                colormaps = {
                    'gray', @gray;
                    'jet', @jet;
                    'hsv', @hsv;
                    'hot', @hot;
                    'cool', @cool;
                    'spring', @spring;
                    'summer', @summer;
                    'autumn', @autumn;
                    'winter', @winter;
                    'bone', @bone;
                    'copper', @copper;
                    'pink', @pink;
                    'lines', @lines
                };
                idx = strcmpi(map, colormaps(:, 1));
                if (sum(idx(:)) == 0)
                    return
                end
                func = colormaps{idx, 2};
                map = func(size(obj.colormap, 1));
            end
            colormap(obj.handles.axes, map);
        end
        function map = get.colormap(obj)
            map = colormap(obj.handles.axes);
        end
    end
    
    methods(Access=private)
        createHandles(obj, varargin)
    end
    methods
        displayImage(obj, image)
        
        %% GUI functions
        guiSetColormap(obj)
    end
end