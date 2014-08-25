function video = getVideo(this, varargin)

    p = inputParser;
    p.addOptional('margin', [0, 0, 0, 0], @(d)isnumeric(d) && numel(d) == 4);
    p.addOptional('stackIndex', 1, @(d)isnumeric(d) && isscalar(d) && d > 0 && d <= numel(this(1).stacks));
    p.addOptional('startIndex', 1, @(d)isnumeric(d) && isscalar(d) && d > 0 && d <= numel(this(1).radius));
    p.addOptional('endIndex', numel(this(1).radius), @(d)isnumeric(d) && isscalar(d) && d > 0 && d <= numel(this(1).radius));
    p.addOptional('stepSize', 1, @(d)isnumeric(d));
    p.addOptional('verbose', false, @islogical);

    p.parse(varargin{:});
    
    boundingBox = dropletToBox(this(1));
    for i = 2:numel(this)
        boundingBox = joinBox(boundingBox, dropletToBox(this(i)));
    end
    video = boundingBoxToVideo(boundingBox, this(1).stacks{p.Results.stackIndex});
    
    function bb = dropletToBox(droplet)
        bb = struct( ...
            'width', [], 'height', [], 'length', [], ...
            'regions', struct('idx', {}, 'top', {}, 'bottom', {}, 'left', {}, 'right', {}) ...
        );

        positionFilter = ~isnan(droplet.radius);
        positionFilter(1:(p.Results.startIndex - 1)) = false;
        positionFilter((p.Results.endIndex + 1):end) = false;

        width = ceil(max( ...
            ceil(droplet.p(positionFilter, 1) + droplet.radius(positionFilter) + p.Results.margin(2)) ...
            - ...
            floor(droplet.p(positionFilter, 1) - droplet.radius(positionFilter) - p.Results.margin(4)) ...
        ) / 2) * 2 + 1;
        height = ceil(max( ...
            ceil(droplet.p(positionFilter, 2) + droplet.radius(positionFilter) + p.Results.margin(3)) ...
            - ...
            floor(droplet.p(positionFilter, 2) - droplet.radius(positionFilter) - p.Results.margin(1)) ...
        ) / 2) * 2 + 1;
        bb.width = width;
        bb.height = height;
        bb.length = numel(droplet.radius);
        indices = find(positionFilter)';
        for i = 1:numel(indices)
            idx = indices(i);
            bb.regions(i) = struct( ...
                'idx', idx, ...
                'top', (round(droplet.p(idx, 2)) - ceil((width - 1) / 2)), ...
                'bottom', (round(droplet.p(idx, 2)) + floor((width - 1) / 2)), ...
                'left', (round(droplet.p(idx, 1)) - ceil((height - 1) / 2)), ...
                'right', (round(droplet.p(idx, 1)) + floor((height - 1) / 2)) ...
            );
        end
    end

    function video = boundingBoxToVideo(bb, stack)
        if (p.Results.verbose)
            wait = Gui.Waitbar(0);
        end

        video = zeros(bb.height, bb.width, floor(numel(bb.regions) / p.Results.stepSize));
        for i = 1:p.Results.stepSize:numel(bb.regions)
            b = bb.regions(i);
            if (p.Results.verbose)
                wait.Value = i / numel(bb.regions);
            end
            image = stack.getImage(b.idx);
            video(:, :, (i - 1)/p.Results.stepSize + 1) = image(b.top:b.bottom, b.left:b.right);
        end
    end
end

function joinBox = joinBox(bb1, bb2)
    if (numel(bb1.regions) == numel(bb2.regions) && all([bb1.regions.idx] == [bb2.regions.idx]))
        top    = min([bb1.regions.top   ; bb2.regions.top   ], [], 1);
        bottom = max([bb1.regions.bottom; bb2.regions.bottom], [], 1);
        left   = min([bb1.regions.left  ; bb2.regions.left  ], [], 1);
        right  = max([bb1.regions.right ; bb2.regions.right ], [], 1);
        width = max(right - left) + 1;
        height = max(bottom - top) + 1;
        
        joinBox = struct( ...
            'width', width, ...
            'height', height, ...
            'length', bb1.length, ...
            'regions', struct( ...
                'idx', {bb1.regions.idx}, ...
                'top', num2cell(top), ...
                'bottom', num2cell(top + height - 1), ...
                'left', num2cell(left), ...
                'right', num2cell(left + width - 1) ...
            ) ...
        );
    else
        error('Unable to join boxes with different lengths.');
    end
end