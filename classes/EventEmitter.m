classdef EventEmitter < handle
    properties 
        
    end
    properties (Access=private)
        Events = struct();
    end
    
    %constructor
    methods
        function this = EventEmitter(eventListeners)
            if (nargin > 0 && isa(eventListeners, 'struct'))
                fNames = fieldnames(eventListeners);
                if (~isempty(fNames))
                    for name = fNames
                        this.on(name{1}, eventListeners.(name{1}));
                    end
                end
            end
        end
    end
    methods
        function on(this, event, callback)
            if (~isa(event, 'char'))
                error('EventEmitter:noEventName', 'Eventname must ba a string.');
            end
            if (~isa(callback, 'function_handle'))
                error('EventEmitter:noFunction', 'Only function handles can be registered.');
            end
            if (~isfield(this.Events, event))
                this.Events.(event) = {callback};
            else
                this.Events.(event)(end + 1) = callback;
            end
        end
        
        function emit(this, event, varargin)
            if (~isa(event, 'char'))
                error('EventEmitter:noEventName', 'Eventname must ba a string.');
            end
            if (isfield(this.Events, event))
                for c = this.Events.(event)
                    c{1}(this, varargin{:});
                end
            end
        end
    end
end