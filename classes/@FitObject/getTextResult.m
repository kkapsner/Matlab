function str = getTextResult(this)
%GETTEXTRESULT creates a textual result - e.g. for plots

    str = this.funcTex;
    
    for i = 1:numel(this.arguments)
        arg = this.arguments(i);
        if (~strcmpi(arg.type, 'independent'))
            if (strcmp(arg.type, 'problem'))
                str = sprintf('%s\n\t%s = %f', str, arg.name, arg.value);
            else
                pm = max(abs(arg.value - this.confidenceInterval(0.6827, arg.name))); 
                str = sprintf('%s\n\t%s = %f \\pm %f', str, arg.name, arg.value, pm);
            end
        end
    end
end

