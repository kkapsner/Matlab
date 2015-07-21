function hull = localConvexHull(image, radius)
%LOCALCONVEXHULL creates a local convex hull with a fixed radius.
%   A local image is generated for every pixel which contains all
%   surrounding information within the radius. The convex hull of this
%   image is generated and the resulting image is pasted in the final hull
%   image.
%
%   hull = localConvexHull(image, radius)
%
% SEE ALSO: Image.convexHull
    radius2 = radius * radius;
    radius = floor(radius);
    hull = double(image);
    imageSize = size(image);
    for xO = 1:imageSize(2)
        for yO = 1:imageSize(1)
            
            % get local image
            localImage = zeros(radius * 2 + 1);
            for x = -radius:radius
                maxY = floor(sqrt(radius2 - x*x));
                for y = -maxY:maxY
                    if ( ...
                        xO + x > 0 && yO + y > 0 && ...
                        xO + x <= imageSize(2) && yO + y <= imageSize(1) ...
                    )
                        localImage(radius + y + 1, radius + x + 1) = ...
                            image(yO + y, xO + x);
                    end
                end
            end
            
            % get local hull
            localHull = Image.convexHull(localImage);
            
            % paste the local hull
            for x = -radius:radius
                maxY = floor(sqrt(radius2 - x*x));
                for y = -maxY:maxY
                    if ( ...
                        xO + x > 0 && yO + y > 0 && ...
                        xO + x <= imageSize(2) && yO + y <= imageSize(1) ...
                    )
                        hull(yO + y, xO + x) = hull(yO + y, xO + x) || ...
                            localHull(radius + y + 1, radius + x + 1);

                    end
                end
            end
        end
    end
end