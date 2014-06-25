function image = circle(radius)
    image = false(radius * 2 + 2, radius * 2 + 2);
    idx = 1:((2*radius + 2)^2);
    [x, y] = ind2sub2D([radius * 2 + 2, radius * 2 + 2], idx);
    
    x = x - 1.5 - radius;
    y = y - 1.5 - radius;
    circleIdx = idx(x.^2.+ y.^2 <= radius^2);
    image(circleIdx) = true;
end