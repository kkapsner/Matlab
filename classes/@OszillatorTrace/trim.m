function trim(obj)
    for o = obj
        filter = obj.area ~= 0 & ~isnan(obj.area);
        if (~isempty(obj.normalisation))
            filter = filter & obj.normalisation ~= 0 & ~isnan(obj.normalisation);
        end
        startI = find(filter, 1, 'first');
        endI = find(filter, 2, 'last');
        o.time = o.time(startI:endI);
        o.intensity = o.intensity(startI:endI);
        o.area = o.area(startI:endI);
        if ~isempty(o.normalisation)
            o.normalisation = o.normalisation(startI:endI);
        end
    end
end

