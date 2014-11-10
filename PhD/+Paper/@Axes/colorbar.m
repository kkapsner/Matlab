function h = colorbar(a, varargin)
%COLORBAR 
    h = colorbar(varargin{:}, 'peer', a.ax);

end

