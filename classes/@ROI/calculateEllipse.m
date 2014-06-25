function calculateEllipse(this)
    %CALCULATEELLIPSE calculates the ellipse properties of a region
    
    % copied from regionprops
    if (this.Area == 0)
        this.MajorAxisLength_ = 0;
        this.MinorAxisLength_ = 0;
        this.Eccentricity_ = 0;
        this.Orientation_ = 0;

    else
        % Assign X and Y variables so that we're measuring orientation
        % counterclockwise from the horizontal axis.
        
        centorid = this.Centroid;
        xbar = centorid(1);
        ybar = centorid(2);

        x = this.subX - xbar;
        y = -(this.subY - ybar); % This is negative for the
        % orientation calculation (measured in the
        % counter-clockwise direction).

        N = length(x);

        % Calculate normalized second central moments for the region. 1/12 is
        % the normalized second central moment of a pixel with unit length.
        uxx = sum(x.^2)/N + 1/12;
        uyy = sum(y.^2)/N + 1/12;
        uxy = sum(x.*y)/N;

        % Calculate major axis length, minor axis length, and eccentricity.
        common = sqrt((uxx - uyy)^2 + 4*uxy^2);
        this.MajorAxisLength_ = 2*sqrt(2)*sqrt(uxx + uyy + common);
        this.MinorAxisLength_ = 2*sqrt(2)*sqrt(uxx + uyy - common);
        this.Eccentricity_ = sqrt( ...
            1 - (this.MinorAxisLength_/this.MajorAxisLength_).^2 ...
        );
%         this.Eccentricity_ = 2*sqrt( ...
%             (this.MajorAxisLength_/2)^2 - ...
%             (this.MinorAxisLength_/2)^2 ...
%             ) / this.MajorAxisLength_;

        % Calculate orientation.
        if (uyy > uxx)
            num = uyy - uxx + sqrt((uyy - uxx)^2 + 4*uxy^2);
            den = 2*uxy;
        else
            num = 2*uxy;
            den = uxx - uyy + sqrt((uxx - uyy)^2 + 4*uxy^2);
        end
        if (num == 0) && (den == 0)
            this.Orientation_ = 0;
        else
            this.Orientation_ = (180/pi) * atan(num/den);
        end
    end
end


