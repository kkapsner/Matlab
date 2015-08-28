function run()
    seg = Segmenter();
    seg.performWatershed = false;
    for i=1:7
        ax = Paper.Axes();
        roi = seg.segmentEnhancedBW(rgb2gray(imread(sprintf('+test/test%d.png', i))));
        Image.show(roi.toImage(), ax.ax);
        [x, y] = roiToPolyline(roi);
        ax.plot(x, y);
    end
end

