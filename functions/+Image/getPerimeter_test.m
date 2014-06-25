%% calculate errors for perimeter and area estimation
pError = zeros(100, 1); aError = zeros(100, 1);circ = zeros(100, 1);
for r = 1:100
    img = Image.circle(r);
    p = Image.getPerimeter(img);
    pError(r) = 1 - p/(2*pi*r);
    a = sum(img(:));
    aError(r) = 1 - a/(pi*r^2);
    circ(r) = p/2/pi / sqrt(a/pi);
end
figure;plot(circ);figure;plot(pError);figure;plot(aError);

%% compare to MATLABs functions
pError = zeros(100, 1); aError = zeros(100, 1);circ = zeros(100, 1);
for r = 1:100
    img = Image.circle(r);
    p = regionprops(img, 'Perimeter');p = p.Perimeter;
    pError(r) = 1 - p/(2*pi*r);
    a = sum(img(:));
    aError(r) = 1 - a/(pi*r^2);
    circ(r) = p/2/pi / sqrt(a/pi);
end
figure;plot(circ);figure;plot(pError);figure;plot(aError);