function droplet = merge(this)
%DROPLET.MERGE merges droplets to a new one

    numDataPoints = numel(this(1).radius);
    numIntensities = size(this(1).minIntensity, 2);

    droplet = Droplet(numDataPoints, 1, numIntensities);
    droplet.stacks = this(1).stacks;
    droplet.lastIndex = max([this.lastIndex]);
    
    oldDroplets = reshape(this, 1, []);
    areas = pi * [oldDroplets.radius].^2;
    positions = [oldDroplets.p];
    xPositions = positions(:, 1:2:end);
    yPositions = positions(:, 2:2:end);
    
    for t = 1:numDataPoints
        filter = ~isnan(areas(t, :));
        filterSum = sum(filter);
        if filterSum > 0
            area = sum(areas(t, filter));
            droplet.radius(t) = sqrt(area / pi);

            x = sum(xPositions(t, filter) .* areas(t, filter)) / area;
            y = sum(yPositions(t, filter) .* areas(t, filter)) / area;
            droplet.p(t, :) = [x, y];

            intensitySums = [oldDroplets(filter).intensitySum];

            for i = 1:numIntensities
                droplet.intensitySum(t, i) = sum(intensitySums(t, i:numIntensities:end));
            end

            if filterSum == 1
                droplet.perimeter(t, :) = oldDroplets(filter).perimeter(t, :);
                droplet.minIntensity(t, :) = oldDroplets(filter).minIntensity(t, :);
                droplet.maxIntensity(t, :) = oldDroplets(filter).maxIntensity(t, :);
                droplet.brightIntensitySum(t, :) = oldDroplets(filter).brightIntensitySum(t, :);
                droplet.brightArea(t, :) = oldDroplets(filter).brightArea(t, :);
            end
        end
    end
end

