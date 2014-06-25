function str = logicalToString(log)
%LOGICALTOSTRING converts a logical to an on|off string

    if log
        str = 'on';
    else
        str = 'off';
    end
end

