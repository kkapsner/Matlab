classdef (Abstract) TraceDecorator < AbstractTrace & handle
    
    properties (SetAccess=protected)
        trace
    end
    
    methods
        function this = TraceDecorator(trace)
            if (nargin > 0)
                trace = TraceDecorator.uniformTrace(trace);
                
                if (numel(trace) > 1)
                    c = class(this);
                    this = this(ones(size(trace)));
                    for i = 1:numel(trace)
                        this(i) = feval(c);
                        this(i).trace = trace{i};
                    end
                elseif (numel(trace) == 1)
                    this.trace = trace;
                end
            end
        end
        
        function timeUnit = getTimeUnit(this)
            timeUnit = this.trace.getTimeUnit();
        end
        function timeName = getTimeName(this)
            timeName = this.trace.getTimeName();
        end
        function valueUnit = getValueUnit(this)
            valueUnit = this.trace.getValueUnit();
        end
        function valueName = getValueName(this)
            valueName = this.trace.getValueName();
        end
        function name = getName(this)
            name = this.trace.getName();
        end
    end
    
    methods (Access=private, Static)
        function trace = uniformTrace(trace)
            if (iscell(trace))
                for i = 1:numel(trace)
                    trace{i} = TraceDecorator.uniformTrace(trace{i});
                end
                if (numel(trace) == 1)
                    trace = trace{1};
                end
            elseif (isempty(trace))
                
            elseif (~isa(trace, 'AbstractTrace'))
                error('TraceDecorator:incompatibleType', ...
                    'Only traces can be decorated.');
            elseif (numel(trace) > 1)
                s = size(trace);
                trace = mat2cell(trace, ones(s(1), 1), ones(1, s(2))); %#ok<MMTC>
            end
        end
    end
    
    methods (Abstract)
        dm = propertyDialog(this)
    end
    
%     methods (Abstract, Static)
%         [panel, getParameter] = getGUIParameterPanel(parent)
%     end
%     
%     methods (Static)
%         obj = guiAddDecorator(obj)
%     end
end