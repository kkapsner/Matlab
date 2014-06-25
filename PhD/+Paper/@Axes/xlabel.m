function xlabel(a, str, unit)
%AXES.XLABEL like normal xlabel
    if (nargin < 3)
        unit = '';
    else
        unit = [' (' unit ')'];
    end
    xlabel( ...
        a.ax, [str unit], ...
        'FontSize', a.labelFontSize ...
    );
end

