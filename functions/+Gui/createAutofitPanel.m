function [panel, api] = createAutofitPanel(varargin)
    %CREATEAUTOFITPANEL
    
    p = inputParser();
    p.KeepUnmatched = true;
    p.addOptional('margin', 5, @(m)isnumeric(m) && isscalar(m));
    p.addOptional('stackSpacing', 0, @(m)isnumeric(m) && isscalar(m));
    p.addOptional('direction', 'v', @(d)any(strcmp(d, {'v', 'h'})));
    p.addOptional('pinEnd', false, @(p)islogical(p) && isscalar(p));
    p.parse(varargin{:});
    
    margin = p.Results.margin;
    stackSpacing = p.Results.stackSpacing;
    pinEnd = p.Results.pinEnd;
    switch p.Results.direction
        case 'v'
            zeroIndex = 1;
            fullIndex = 3;
            stackIndex = 2;
            measureIndex = 4;
        case 'h'
            zeroIndex = 2;
            fullIndex = 4;
            stackIndex = 1;
            measureIndex = 3;
    end
    
    panel = handle(uipanel(p.Unmatched, 'Units', 'pixels'));
    l = [];
    api = struct( ...
        'layout', @layout, ...
        'addPanel', @addPanel, ...
        'removePanel', @removePanel, ...
        'childrenChanged', @childrenChanged, ...
        'renewListeners', @renewListeners, ...
        'deleteListeners', @deleteListeners ...
    );
    inLayout = false;
    
    renewListeners();
    function layout(varargin)
        if (~inLayout)
            inLayout = true;
            panelPosition = panel.Position;
            measure = margin;
            full = panelPosition(fullIndex) - 2 * margin;
            children = reshape(panel.Children, 1, []);
            for child = children
                if (Gui.strToBoolean(child.Visible))
                    pos = zeros(1, 4);
                    pos(zeroIndex) = margin;
                    pos(fullIndex) = full;
                    pos(stackIndex) = measure;
                    pos(measureIndex) = child.Position(measureIndex);
                    measure = measure + stackSpacing + pos(measureIndex);
                    child.Position = pos;
                end
            end
            measure = measure + margin - stackSpacing;
            if (~pinEnd)
                panelPosition(stackIndex) = ...
                    panelPosition(stackIndex) + ...
                    panelPosition(measureIndex) - ...
                    measure;
            end
            panelPosition(measureIndex) = measure;
            panel.Position = panelPosition;
            inLayout = false;
        end
    end
    function newPanel = addPanel(varargin)
        newPanel = handle(uipanel( ...
            'BorderType', 'none', ...
            varargin{:}, ...
            'Units', 'pixels', ...
            'HandleVisibility', 'on', ...
            'Parent', panel ...
        ));
        childrenChanged();
    end
    function removePanel(oldPanel)
        if (oldPanel.Parent == panel)
            delete(oldPanel);
            layout();
        end
    end
    function childrenChanged(varargin)
        for child = reshape(panel.Children, 1, [])
            child.Units = 'pixels';
        end
        layout();
        renewListeners();
    end
    function renewListeners(varargin)
        deleteListeners();
        l = [
            addlistener(panel, 'ObjectBeingDestroyed', @deleteListeners)
            addlistener(panel, 'SizeChanged', @layout)
            addlistener(panel.Children, 'ObjectBeingDestroyed', @renewListeners)
            addlistener(panel.Children, 'SizeChanged', @layout)
            addlistener(panel.Children, 'Visible', 'PostSet', @layout)
        ];
    end
    function deleteListeners(varargin)
        delete(l);
    end
end

