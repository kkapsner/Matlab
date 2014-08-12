function [varargout] = dialog(this)
%TRACE.DIALOG generates a UI for the trace(s)
    allDm = DialogManager(this);
    
    dm = allDm(1);
    
    if (numel(this) == 1)
        traceStack = {this};
        lastTrace = this;
        while (isa(lastTrace, 'TraceDecorator'))
            lastTrace = lastTrace.trace;
            traceStack{end + 1} = lastTrace;
        end
        traceStack = traceStack(end:-1:1);
        
        propertyDm = [];
        for i = 1:numel(traceStack)
            lastTrace = traceStack{i};
            if (isa(lastTrace, 'TraceDecorator'))
                if (isempty(propertyDm))
                    propertyDm = DialogManager(this);
                    propertyDm.open('Settings');
                    allDm(2) = propertyDm;
                    propertyDm.dependsOn(dm);
                end

                lastTrace.propertyDialog(propertyDm);
            end
        end
        if (~isempty(propertyDm))
            propertyDm.show();
        end
    else
        traceStack = num2cell(this);
    end
    
    
    dm.open();
    set(dm.getFigure(), 'Toolbar', 'figure');
    dm.addPanel();
    a = handle(axes( ...
        'Parent', dm.currentPanel, ...
        'Units', 'normalize', ...
        'HandleVisibility', 'callback', ...
        'OuterPosition', [0, 0, 1, 1] ...
    ));
    hold(a, 'all');
    xlabel(a, sprintf('%s (%s)', this(1).getTimeName(), this(1).getTimeUnit()));
    ylabel(a, sprintf('%s (%s)', this(1).getValueName(), this(1).getValueUnit()));
    
    dm.addPanel(numel(traceStack));
    for i = 1:numel(traceStack)
        trace = traceStack{i};
        if (numel(this) ~= 1)
            h = handle(trace.plot('Parent', a, 'keepUpdated', true));
            dialogButton = dm.addButton( ...
                sprintf( ...
                    '<html><img src="file:/%s">', ...
                    fullfile(matlabroot, 'toolbox', 'matlab', 'icons', 'tool_zoom_in.png') ...
                ), ...
                [0, 0, 30, 20], ...
                @(~,~)trace.dialog() ...
            );
            checkbox = dm.addCheckbox(trace.traceName, 1, [30, 0, 0]);
            dm.checkboxHides(checkbox, dialogButton);
            
            l = [ ...
                addlistener( ...
                    trace, 'change', ...
                    @(~,~)set(checkbox, 'String', trace.traceName) ...
                ) ...
            ];
        else
            h = handle(trace.plot('Parent', a, 'keepValuesUpdated', true, 'DisplayName', trace.char()));
            checkbox = dm.addCheckbox(trace.char(), 1);
            
            l = [ ...
                addlistener( ...
                    trace, 'change', ...
                    @(~,~)set(h, 'DisplayName', trace.char()) ...   
                ), ...
                addlistener( ...
                    trace, 'change', ...
                    @(~,~)set(checkbox, 'String', trace.char()) ...
                ) ...
            ];
        end
        addlistener(dm, 'closeWin', @(~,~)delete(l));
        dm.checkboxHides(checkbox, h);
        
        dm.newLine();
    end
    legend(a, 'show');
    
    dm.show();
    
    
    allDm.arrange([1, numel(allDm) - 1]);
    
    if (nargout == 1)
        varargout{1} = allDm;
    end
end