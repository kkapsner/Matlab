function [panel, api] = createAutofitPanel(varargin)
    %CREATEAUTOFITPANEL
    
    p = inputParser();
    p.KeepUnmatched = true;
    p.addOptional('panel', [], @(p)ishandle(p) && isscalar(p));
    p.addOptional('margin', 5, @(m)isnumeric(m) && (numel(m) <= 4));
    p.addOptional('stackSpacing', 0, @(m)isnumeric(m) && isscalar(m));
    p.addOptional('direction', 'v', @(d)any(strcmp(d, {'v', 'h'})));
    p.addOptional('pinEnd', false, @(p)islogical(p) && isscalar(p));
    p.parse(varargin{:});
    
    margin = [];
    setMargin(p.Results.margin);
    
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
    if (isempty(p.Results.panel))
        panel = handle(uipanel(p.Unmatched, 'Units', 'pixels'));
    else
        panel = p.Results.panel;
    end
    
    l = [];
    api = struct( ...
        'layout', @layout, ...
        'setMargin', @setMargin, ...
        'setStackSpacing', @setStackSpacing, ...
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
            measure = margin(1);
            full = panelPosition(fullIndex) - margin(2) - margin(4);
            for child = Gui.getAllChildren(panel)
                if (Gui.strToBoolean(child.Visible))
                    pos = zeros(1, 4);
                    pos(zeroIndex) = margin(4);
                    pos(fullIndex) = full;
                    pos(stackIndex) = measure;
                    pos(measureIndex) = child.Position(measureIndex);
                    measure = measure + stackSpacing + pos(measureIndex);
                    child.Position = pos;
                end
            end
            measure = measure + margin(3) - stackSpacing;
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
    function setMargin(newMargin)
        assert(isnumeric(newMargin), 'Margin has to be numeric.');
        switch numel(newMargin)
            case 0
                margin = [5, 5, 5, 5];
            case 1
                margin = newMargin(ones(1, 4));
            case 2
                margin = newMargin([1 2 1 2]);
            case 3
                margin = newMargin([1, 2, 3, 2]);
            case 4
                margin = newMargin;
            otherwise
                margin = newMargin(1:4);
        end
    end
    function setStackSpacing(newStackSpacing)
        stackSpacing = newStackSpacing;
    end
end