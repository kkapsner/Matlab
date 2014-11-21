function str = logicalToString(log)
%LOGICALTOSTRING converts a logical to an on|off string
    if (ischar(log))
        str = log;
    else
        if log
            str = 'on';
        else
            str = 'off';
        end
    end
end

