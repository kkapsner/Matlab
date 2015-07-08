classdef (Abstract) AbstractTraceDecorator < AbstractTrace
    
    methods (Abstract)
        dm = propertyDialog(this, container)
    end
end

