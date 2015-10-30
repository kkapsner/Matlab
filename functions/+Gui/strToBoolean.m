function bool = booleanToStr( str )
%BOOLEANTOSTR returns true if the input is 'on' and false otherwise
    switch (str)
        case {'on', 'yes'}
            bool = true;
        otherwise
            bool = false;
    end
end

