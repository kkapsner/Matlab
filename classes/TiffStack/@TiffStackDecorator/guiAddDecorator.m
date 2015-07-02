function decoratedStack = guiAddDecorator(stack)
%GUIADDDECORATOR adds a decorator to a tiff stack with a GUI
%   DECORATED_STACK = GUIADDDECORATOR(STACK)
    
    width = 400;
    padding = 10;
    innerWidth = width - 2*padding;
    height = 85;
    panelHeight = 45;
%     innerHeight = height - 2*padding;
    
    f = figure( ...
        'Name', 'Add decorator', ...
        'NumberTitle', 'off', ...
        'HandleVisibility', 'off', ...
        'Position', [50, 50, width, height], ...
        'CloseRequestFcn', @createStack, ...
        'Menubar', 'none', ...
        'Toolbar', 'none' ...
    );
    
    decorators = { ...
        'none', ...
        'FilteredTiffStack', ...
        'MultiChannelTiffStack', ...
        'BackgroundCorrectedTiffStack', ...
        'FunctionTiffStack' ...
    };
    
    uicontrol( ...
        'Parent', f, ...
        'HandleVisibility', 'off', ...
        'Style', 'text', ...
        'String', 'decorator', ...
        'Position', [padding, panelHeight + 15, 80, 20] ...
    );
    decInput = handle(uicontrol( ...
        'Parent', f, ...
        'HandleVisibility', 'off', ...
        'Style', 'popupmenu', ...
        'String', decorators, ...
        'Position', [padding + 80, panelHeight + 15, innerWidth - 80, 20], ...
        'Value', 1, ...
        'Callback', @decChange ...
    ));
    oldValue = 1;
    function decChange(~,~)
        if (oldValue ~= 1)
            panel{oldValue}.Visible  = 'off';
        end
        oldValue = decInput.Value;
        if (oldValue ~= 1)
            panel{decInput.Value}.Visible = 'on';
        end
    end
    
    panel = cell(size(decorators));
    getParameter = cell(size(decorators));
    
    for i = 2:numel(decorators)
        [panel{i}, getParameter{i}] = feval( ...
            sprintf('%s.getGUIParameterPanel', decorators{i}), f ...
        );
        panel{i}.Position = [padding, padding, innerWidth, panelHeight];
        if (i ~= 1)
            panel{i}.Visible = 'off';
        end
    end
    
    uiwait(f);
    
    function createStack(~,~)
        decI = decInput.Value;
        if (decI ~= 1)
            gP = getParameter{decI};
            param = gP();
            decoratedStack = feval( ...
                decorators{decI}, stack, param{:} ...
            );
        else
            decoratedStack = stack;
        end
        
        delete(f);
    end
end

