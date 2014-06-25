classdef MicroscopePosition < handle
    %MicroscopePosition defines a position in a microscope time lapse
    %experiment
    %   
    
    properties (SetAccess=protected)
        stacks = struct()
        stackNames = {}
        trackingStack = 0
    end
    
    methods
        function addStack(this, stack, name, isTracking)
            assert(~all(strcmp(this.stackNames, name)), ...
                'MicroscopePosition:nameAlreadyInUse', ...
                'Stack name already in use.');
            this.stacks.(name) = stack;
            this.stackNames{end} = name;
            if (isTracking)
                this.trackingStack = numel(this.stackNames);
            end
        end
    end
    
end

