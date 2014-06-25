classdef SegmentFilter < handle & Abstract.Filter
    properties (SetAccess=protected)
        property
        range = [0, 1]
    end
    
    properties (Dependent)
        lowerRangeLimit
        upperRangeLimit
    end
    
    methods
        function this = SegmentFilter(property, range)
            this.property = property;
            if (nargin > 1 && SegmentFilter.validateRange(range))
                this.range = range;
            end
        end
        
        function set.range(this, range)
            assert(SegmentFilter.validateRange(range), '');
            this.range = range;
        end
        
        function lowerLimit = get.lowerRangeLimit(this)
            lowerLimit = this.range(1);
        end
        function set.lowerRangeLimit(this, lowerLimit)
            assert( ...
                isnumeric(lowerLimit) && ...
                isscalar(lowerLimit) && ...
                lowerLimit <= this.upperRangeLimit, ...
                'Invalid lower limit.' ...
            );
            this.range(1) = lowerLimit;
        end
        
        function upperLimit = get.upperRangeLimit(this)
            upperLimit = this.range(2);
        end
        function set.upperRangeLimit(this, upperLimit)
            assert( ...
                isnumeric(upperLimit) && ...
                isscalar(upperLimit) && ...
                upperLimit >= this.lowerRangeLimit, ...
                'Invalid upper limit.' ...
            );
            this.range(2) = upperLimit;
        end
    end
    
    methods
        json = toJSON(this)
    end
    
    methods (Access=private,Static)
        function valid = validateRange(range)
            valid = ...
                isnumeric(range) && ...
                numel(range) == 2 && ...
                range(1) <= range(2);
        end
    end
end