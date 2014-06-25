function ylabel(a, str, unit)
%AXES.YLABEL like normal ylabel
    if (nargin < 3)
        unit = '';
    else
        unit = [' (' unit ')'];
    end
    ylabel( ...
        a.ax, [str unit], ...
        'FontSize', a.labelFontSize ...
    );
end