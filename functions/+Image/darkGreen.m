function map = darkGreen(s)
    if (nargin < 1)
        s = 256;
    end
    startColor = [0, 0, 0];
    endColor = [0, 141, 54] * 1.5 / 265;
    
    map = zeros(s, 3);
    for i = 1:s
        map(i, :) = startColor + (endColor - startColor) * (i-1)/(s-1);
    end
end