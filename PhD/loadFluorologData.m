function traces = loadFluorologData(file)
    if (nargin < 1)
        file = File.get;
    end
    
    disp('read file');
    lines = file.readLines();
    
    dLength = (length(lines) - 1) / 2;
    
    disp('extract data');
    %disp(' ... line 1');
    traces(dLength) = Trace();
    
    for i = 1:dLength
        timeHeader = regexp(lines{i * 2 - 1}, '^([^\t]*)\t', 'tokens');
        timeHeader = timeHeader{1}{1};
        time = cell2mat( ...
            textscan( ...
                lines{i * 2 - 1}(length(timeHeader) + 2:end), ...
                '%n', 'delimiter', '\t' ...
            ) ...
        );
        
        name = regexp(lines{i * 2}, '^([^\t]*)\t', 'tokens');
        name = name{1};
        value = cell2mat( ...
            textscan( ...
                lines{i * 2}(length(name{1}) + 2:end), ...
                '%n', 'delimiter', '\t' ...
            ) ...
        );
        traces(i) = Trace(name, time, value);
    end
end