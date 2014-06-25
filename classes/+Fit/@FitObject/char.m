function str = char(obj)
%CHAR converts fit object to string

    par = obj.arguments(obj.parameter);
    str = '';
    for p = par
        str = [str sprintf('%s: %1.3g, ', p.name, p.value)];
    end
    
    str = str(1:end-2);
    
    if (~isempty(obj.lastResult))
        if (isempty(obj.lastResult.goodness))
            str = [str, ' Fit failed!'];
        else
            str = [str, sprintf(' (std. error: %1.3g)', obj.lastResult.goodness.rmse)];
        end
    end
end

