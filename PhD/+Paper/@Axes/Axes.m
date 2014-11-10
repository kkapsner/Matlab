classdef Axes < handle
    properties
        f
        ax
        UserData
        figureName
        
        textFontSize = 14 %30
        labelFontSize = 14 %30
    end
    
    methods
        function a = Axes(varargin)
            a.ax = Paper.getAxes(varargin{:});
            set(a.ax, 'UserData', a);
            a.f = get(a.ax, 'Parent');
            set(a.f, 'UserData', a);
            a.figureName = get(a.f, 'Name');
            hold(a.ax, 'all');
        end
    end
    
    methods
        clear(a)
        close(a)
        
        h = fillBetween(a, x1, y1, x2, y2)
        h = errorbar(a, x, y, r, c)
        h = plot(a, varargin)
        h = surface(a, varargin)
        h = scatter(a, varargin)
        
        h = text(a, varargin)
        
        setLogX(a)
        setLogY(a)
        
        xlim(a, varargin)
        ylim(a, varargin)
        
        xticks(a, ticks)
        
        xlabel(a, str, unit)
        ylabel(a, str, unit)
        zlabel(a, str, unit)
        h = legend(a, varargin)
        h = title(a, varargin)
        name(a, name)
        
        h = colorbar(a, varargin)
        
        save(a, file, formats)
    end
    
    methods (Static)
        styleLineObject(h, varargin)
        stylePointObject(h, varargin)
    end
end

