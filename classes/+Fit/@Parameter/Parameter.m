classdef Parameter < handle & Selectable & hgsetget & matlab.mixin.Copyable
    %PARAMETER Parameter of a Fit
    %   
    
    properties (SetObservable, AbortSet)
        type = 'parameter'
        lowerBound = -Inf
        value = 0
        upperBound = Inf
    end
    
    properties (SetAccess=private)
        name
    end
    
    methods
        function this = Parameter(name)
            if nargin
                this.name = name;
            end
        end
        
        char(this)
        double(this);
    end
    
end

