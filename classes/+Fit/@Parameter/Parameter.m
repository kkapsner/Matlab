classdef Parameter < handle & Selectable & hgsetget & matlab.mixin.Copyable
    %PARAMETER Parameter of a Fit
    %   
    
    properties (SetObservable, AbortSet)
        type = 'parameter'
        lowerBound = -Inf
        value = 0
        upperBound = Inf
        stepLogarithmical = false
    end
    
    properties (SetAccess=private)
        name
    end
    
    properties (Transient)
        fit
    end
    
    properties (Dependent)
        error
        errorInterval
    end
    
    methods
        function this = Parameter(fit, name)
            if nargin
                this.fit = fit;
                this.name = name;
            end
        end
        
        function error = get.error(this)
            if (isempty(this.fit))
                error = [0; 0];
            else
                error = this.value - this.errorInterval;
            end
        end
        
        function errorInterval = get.errorInterval(this)
            if (isempty(this.fit))
                errorInterval = [1; 1] * this.value;
            else
                errorInterval = this.fit.confidenceInterval( ...
                    0.95, ...0.6827, ...
                    this.name ...
                );
            end
        end
        
        char(this)
        double(this);
    end
    
end

