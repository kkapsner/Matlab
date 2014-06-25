function area = convexArea(image)
%convexArea calculates the area of the convex hull of an image
    convexImage = Image.convexHull(image);
    area = sum(convexImage(:));
end