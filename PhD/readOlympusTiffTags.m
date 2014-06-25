function data = readOlympusTiffTags(file)
%READOLYMPUSTIFFTAGS reads the file info of a tiff file created by olympus
%xcellence
    info = imfinfo(file);
    data = struct('originalInfo', info);
    
    fields = regexp(info(1).UnknownTags(1).Value, '[\n\r]+', 'split');
    for field = fields
        split = regexp(field{1}, '=', 'split');
        if numel(split) >= 2
            data.(split{1}) = parseValue(split{2});
        end
    end
    
    function parsedValue = parseValue(value)
        if (any(value == ','))
            values = regexp(value, ',', 'split');
            parsedValue = cell(size(values));
            for i = 1:numel(values)
                parsedValue{i} = parseValue(values{i});
            end
        elseif (regexp(value, '^\d+(?:\.\d*)?(?:e[+-]?\d+(?:\.\d*)?)?$'))
            parsedValue = str2double(value);
        else
            parsedValue = value;
        end
    end
end

