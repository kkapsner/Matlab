function value = secondMoment(this)
    value = nan(1, numel(this));
    for i = 1:numel(this)
        o = this(i);
        if o.dataSize > 2
            x1 = o.time(1:(end - 1));
            x2 = o.time(2:end);
            y1 = o.value(1:(end - 1));
            y2 = o.value(2:end);
            
            % slope of the linear slope between tow adjacent data points
            slope = (y2 - y1) ./ (x2 - x1);
            
            % calculate the intersection of the x-axis and the linear
            % slope between two adjacent data points
            alpha = (y2.*x1 - y1.*x2) ./ (y2 - y1);
            
            % the equation of the linear slope is:
            %   y(x) = slope * (x - alpha)
            
            % calculate the integration of the squared linear slope
            integration = ...
                slope .^2 .* (...
                    (x2 .* (alpha.^2 + x2 .* (-alpha + x2./3))) ...
                    - ...
                    (x1 .* (alpha.^2 + x1 .* (-alpha + x1./3))) ...
                ) ...
            ;
            value(i) = sum(integration) / (o.time(end) - o.time(1));
        end
    end
end