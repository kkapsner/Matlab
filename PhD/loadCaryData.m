function traces = loadCaryData(file)
    if (nargin < 1)
        file = File.get;
    end
    
    disp('read file');
    lines = file.readLines();
    
    disp('extract data');
    %disp(' ... line 1');
    names = regexp(lines{1}, ',', 'split');
    names = names(1:2:end-1);
    
    %disp(' ... line 2');
    columns = regexp(lines{2}, ',', 'split');
    columns = columns(1:end-1);
    
    i = 1:length(lines);
    emptyLines = i(strcmp(lines, ''));
    dataEnd = emptyLines(1);
    
    data = zeros(dataEnd - 3, length(columns));
    
    for i = 3:dataEnd - 1
        %disp(sprintf(' ... line %u', i));
        data(i-2, :) = cell2mat(textscan(lines{i}, '%n', length(columns), 'delimiter', ','));
%         charCell = regexp(lines{i}, ',', 'split');
%         for j = 1:numel(charCell)
%             data(i-2, j) = str2double(charCell(j));
%         end
    end
    
    times = data(:, 1:2:end);
    values = data(:, 2:2:end);
    
    disp('create traces');
    traces = RawDataTrace(times, values, names);
end