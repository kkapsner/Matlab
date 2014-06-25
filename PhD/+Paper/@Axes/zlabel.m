function zlabel(a, str, unit)
%AXES.ZLABEL like normal zlabel
    if (nargin < 3)
        unit = '';
    else
        unit = [' (' unit ')'];
    end
    zlabel(a.ax, [str unit]);
end