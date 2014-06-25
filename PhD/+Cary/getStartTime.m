function time = getStartTime(file)
    if (nargin < 1)
        file = File.get;
    end
    if (~isa(file, 'File'))
        file = File(file);
    end
    lines = file.readLines();
    
    dataEnd = find((strcmp(lines, '')), 1, 'first');
    
    time = zeros(1, 6);
    
    for i = dataEnd:numel(lines)
        if (numel(lines{i}) >= 18 && strcmp(lines{i}(1:17), 'Collection Time: '))
            disp(lines{i});
            time = datevec(lines{i}(18:end), 'dd.mm.yyyy HH:MM:SS');
            break;
        end
    end
end