function isV = isVisible(h)
%ISVISIBLE checks if the Visibile-property is on
%   

    isV = ishandle(h) & strcmpi(get(h, 'Visible'), 'on');
end

