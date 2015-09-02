function run()
    seg = Segmenter();
    seg.performWatershed = false;
    for i=1:7
        ax = Paper.Axes();
        img = rgb2gray(imread(sprintf('+test/test%d.png', i)));
        roi = seg.segmentEnhancedBW(img);
        Image.show(roi.toImage(), ax.ax);
        tic;
        for j=1:10
            [x, y] = roiToPolyline(roi);
        end
        toc;
        ax.plot(x, y);
        img(end*10, end*10) = 0;
        roi = seg.segmentEnhancedBW(img);
        ax = Paper.Axes();
        Image.show(roi.toImage(), ax.ax);
        tic;
        for j=1:10
            [x, y] = roiToPolyline(roi);
        end
        toc;
        ax.plot(x, y);
    end
end

