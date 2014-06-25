function maximizeFigure(fig)
%MAXIMIZEFIGURE maximizes a figure to full screen
%   Gui.maximizeFigure() maximizes the current figure
%   Gui.macimizeFigure(f) maximizes figure f.
    
    if (nargin < 1)
        fig = gcf;
    end
    
    warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
    jf = get(fig, 'JavaFrame');
    set(jf ,'maximized', 1);
    warning('on','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
end

