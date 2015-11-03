function maximizeFigure(fig)
%MAXIMIZEFIGURE maximizes a figure to full screen
%   Gui.maximizeFigure() maximizes the current figure
%   Gui.maximizeFigure(f) maximizes figure f.
    
    if (nargin < 1)
        fig = gcf;
    end
    
    start(timer('TimerFcn', @setMaximized, 'StartDelay', 0.1, 'TasksToExecute', 1, 'StopFcn', @(t, ~)delete(t)));
    
    function setMaximized(~,~)
        try
            if (ishandle(fig))
                warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
                jf = get(fig, 'JavaFrame');
                javaMethodEDT('setMaximized', jf, 1);
                warning('on','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
            end
        catch
            start(timer('TimerFcn', @setMaximized, 'StartDelay', 1, 'TasksToExecute', 1, 'StopFcn', @(t, ~)delete(t)));
        end
    end
end