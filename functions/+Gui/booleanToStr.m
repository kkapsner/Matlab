function str = booleanToStr( bool )
%BOOLEANTOSTR returns 'on' if the input is true and 'off' otherwise
    if (bool)
        str = 'on';
    else
        str = 'off';
    end
end

