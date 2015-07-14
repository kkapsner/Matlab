function trace = createFromClipboard()
    trace = RawDataTrace.empty();
    data = importdata('-pastespecial');
    if (isstruct(data))
        if (isfield(data, 'data'))
            if (isfield(data, 'colheaders'))
                names = data.colheaders(2:end);
                data = data.data;
            elseif (isfield(data, 'rowheaders'))
                names = data.rowheaders(2:end);
                data = data.data';
            else
                sData = size(data.data);
                if (sData(1) < sData(2))
                    names = data.textdata(3:end, 1);
                    data = data.data';
                else
                    names = data.textdata(1, 3:end);
                    data = data.data;
                end
            end
            trace = RawDataTrace(data(:, 1), data(:, 2:end), names);
        end
    elseif (isnumeric(data))
        sData = size(data);
        if (sData(1) < sData(2))
            data = data';
        end
        trace = RawDataTrace(data(:, 1), data(:, 2:end));
    end
end