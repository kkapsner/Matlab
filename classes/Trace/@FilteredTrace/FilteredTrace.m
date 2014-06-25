classdef FilteredTrace < TraceDecorator & handle
    
    properties (SetObservable)
        filterValue = 3
        filterType = 'gauss'
    end
    
    properties (Access=private,Transient)
        filteredValue
    end
    
    methods
        function this = FilteredTrace(trace)
            if (nargin == 0)
                trace = [];
            end
            
            this = this@TraceDecorator(trace);
            
            if (nargin ~= 0)
                this.registerListeners();
            end
        end
        
        function registerListeners(this)
            for i = 1:numel(this)
                fTrace = this(i);
                l = addlistener(fTrace.trace, 'change', @fTrace.resetFiltered);
                addlistener(fTrace, 'ObjectBeingDestroyed', @(~,~)delete(l));
                addlistener(fTrace, 'filterValue', 'PostSet', @fTrace.resetFiltered);
                addlistener(fTrace, 'filterType', 'PostSet', @fTrace.resetFiltered);
            end
        end
        
        function value = getValue(this)
            if (isempty(this.filteredValue))
                this.performFilter();
            end
            value = this.filteredValue;
        end
        
        function time = getTime(this)
            time = this.trace.time;
        end
        
        function setFilterValue(this, value)
            if (numel(value) ~= 1)
                error('FilteredTrace:invalidFilterValue', ...
                    'Filter value has to be scalar.');
            end
            for o = this
                o.filterValue = value;
            end
        end
        
        function setFilterType(this, type)
            if (~isa(type, 'char'))
                error('FilterTrace:invalidFilterType', ...
                    'Filter type has to be a char');
            end
            for o = this
                o.filterType = type;
            end
        end
    end
    
    methods
        dm = inspectFilteredProperties(this, referenceTrace)
    end
    
    methods (Access=private)
        function resetFiltered(this, ~, ~)
            for o = this
                o.filteredValue = [];
                o.notify('change');
            end
        end
        function performFilter(this)
            for o = this
                value = o.trace.value;
                localsigma = o.filterValue / (o.trace.time(2) - o.trace.time(1));
                switch (this.filterType)
                    case 'gauss'
                        filtered = Filter.gauss(value, localsigma);
                    case 'median'
                        filtered = Filter.median1d(value, round(localsigma));
                    case 'average'
                        filtered = Filter.average(value, round(localsigma));
                    case 'none'
                        filtered = value;
                    otherwise
                        error('FilteredTrace:unknownFilter', ...
                            'Unknown filter type');
                end

                o.filteredValue = filtered;
            end
        end
    end
end