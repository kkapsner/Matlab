function filter = slice(obj, startTime, endTime)
    for o = obj
        if (nargin < 3)
            filter = o.slice@Trace(startTime);
        else
            filter = o.slice@Trace(startTime, endTime);
        end
        
        o.intensity = o.intensity(filter);
        o.area = o.area(filter);
        o.normalisation = o.normalisation(filter);
        o.radius = o.radius(filter);
    end
end

