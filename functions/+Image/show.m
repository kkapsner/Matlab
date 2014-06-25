function h = show(image, h, varargin)
%SHOW displays the image in a new figure and with adjusted brightness
    if (nargin < 2)
        f = figure();
        h = axes('Parent', f);
    end
    if (isa(image, 'logical'))
        mi = 0;
        ma = 1;
    else
        mi = min(image(:));
        ma = max(image(:));
    end
    
%     mi = -10;
%     ma = 480;
    s = warning('off', 'images:initSize:adjustingMag');
    h = imshow(image, [mi, ma], varargin{:}, 'Parent', h);
    warning(s.state, 'images:initSize:adjustingMag');
end

