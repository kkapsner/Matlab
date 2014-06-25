function h = surface(a, varargin )
%SURFACE like surface
    h = surface(varargin{:}, 'Parent', a.ax);
    set(a.ax, 'box', 'off');
    colorbar('Eastoutside', 'peer', a.ax);
end

