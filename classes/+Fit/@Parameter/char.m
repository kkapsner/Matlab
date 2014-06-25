function c = char(this)
% PARAMETER.CHAR converter to char - returns the name

    c = this.name;
    
    if (~strcmpi(arg.type, 'independent'))
        c = sprintf('%s = %f', c, arg.name, arg.value);
    end
end