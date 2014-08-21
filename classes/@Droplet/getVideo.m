function video = getVideo(this, varargin)
    if (numel(this) == 1)

        p = inputParser;
        p.addOptional('margin', [0, 0, 0, 0], @(d)isnumeric(d) && numel(d) == 4);
        p.addOptional('stackIndex', 1, @(d)isnumeric(d) && isscalar(d) && d > 0 && d <= numel(this.stacks));
        p.addOptional('startIndex', 1, @(d)isnumeric(d) && isscalar(d) && d > 0 && d <= numel(this.radius));
        p.addOptional('endIndex', numel(this.radius), @(d)isnumeric(d) && isscalar(d) && d > 0 && d <= numel(this.radius));
        p.addOptional('verbose', false, @islogical);
        
        p.parse(varargin{:});

        positionFilter = ~isnan(this.radius);
        positionFilter(1:(p.Results.startIndex - 1)) = false;
        positionFilter((p.Results.endIndex + 1):end) = false;

        width = ceil(max( ...
            ceil(this.p(positionFilter, 1) + this.radius(positionFilter) + p.Results.margin(2)) ...
            - ...
            floor(this.p(positionFilter, 1) - this.radius(positionFilter) - p.Results.margin(4)) ...
        ) / 2) * 2 + 1;
        height = ceil(max( ...
            ceil(this.p(positionFilter, 2) + this.radius(positionFilter) + p.Results.margin(3)) ...
            - ...
            floor(this.p(positionFilter, 2) - this.radius(positionFilter) - p.Results.margin(1)) ...
        ) / 2) * 2 + 1;
        
        video = zeros(height, width, numel(this.radius));
        
        stack = this.stacks{p.Results.stackIndex};
        indices = find(positionFilter)';
        
        if (p.Results.verbose)
            wait = Gui.Waitbar(0);
        end
        for idx = indices
            if (p.Results.verbose)
                wait.Value = idx / numel(indices);
            end
            image = stack.getImage(idx);
            video(:, :, idx) = image( ...
                (round(this.p(idx, 2)) - ceil((width - 1) / 2)) ...
                : ...
                (round(this.p(idx, 2)) + floor((width - 1) / 2)), ...
                (round(this.p(idx, 1)) - ceil((height - 1) / 2)) ...
                : ...
                (round(this.p(idx, 1)) + floor((height - 1) / 2)) ...
            );
        end

    else
        video = arrayfun(@(d)d.getVideo(varargin{:}), this,  'Uniform', false);
    end
end