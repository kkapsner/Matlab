function image = overlay(image, overlayImage, varargin)
    p = inputParser();
    p.addParameter('color', [1, 1, 1], @(c)isnumeric(c) && numel(c) == 3);
    p.addParameter('opacity', 1, @(o)isnumeric(o) && isscalar(o));
    p.addParameter('mixMode', 'mix', @ischar);
    p.addParameter('clipping', true, @islogical);
    p.parse(varargin{:});
    
    if (ismatrix(image))
        image = image | overlayImage;
    else
        
        overlayImage = overlayImage * p.Results.opacity;
        
        image(:, :, 1) = mix(image(:, :, 1), overlayImage, p.Results.color(1));
        image(:, :, 2) = mix(image(:, :, 2), overlayImage, p.Results.color(2));
        image(:, :, 3) = mix(image(:, :, 3), overlayImage, p.Results.color(3));

        if (p.Results.clipping)
            image = min(1, max(0, image));
        end
        
    end
    
    function c = mix(c1, c2, color)
        switch p.Results.mixMode
            case 'mix'
                c = (1 - c2) .* c1 + c2 .* color;
            case 'add'
                c = c1 + c2 .* color;
            case 'sub'
                c = c1 - c2 .* color;
            otherwise
                error('Image:overlay:unknownMixMode', 'Unknown mix mode.');
        end
    end
end