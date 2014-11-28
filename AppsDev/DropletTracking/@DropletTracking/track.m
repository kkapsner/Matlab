function track(this)
    numBF = numel(this.bfStacks);
    height = 2*10 + numBF * (20 + 5 + 20) + (numBF - 1) * 5;
    f = handle(figure( ...
        'Position', [5, 5, 400, height], ...
        'HandleVisibility', 'callback', ...
        'Toolbar', 'none', ...
        'Menubar', 'none', ...
        'Name', 'tracking progress', ...
        'NumberTitle', 'off' ...
    ));

    wbar = cell(numBF, 1);
    for i = 1:numBF
        y = height - 5 - (i - 1) * (20 + 5 + 20 +5);
        y = y - 20;
        uicontrol('Parent', f, 'Style', 'text', ...
            'String', this.bfStacks{i}.char(), ...
            'Position', [10, y, 380, 20]);
        y = y - 5 - 20;
        wbar{i} = Gui.Waitbar(0, 'Parent', f, 'Position', [10, y, 380, 20]);
    end

    movegui(f, 'center');

    for i = 1:numBF
        wbar{i}.resetTime();
        wbar{i}.Value = 0;

        segmentStack = this.bfStacks{i};
        intensityStacks = this.fluoStacks{i};
        numIntensityStacks = numel(intensityStacks);
        this.tracker.numIntensities = numIntensityStacks;
        
        segmentImage = segmentStack.getImage(1);
        roi = this.segmenter.segment(segmentImage, segmentStack);
        
        for filterIdx = 1:numel(this.filters)
            filter = this.filters(filterIdx);
            roi = roi.select(filter.property, filter.min, true, filter.max, true);
        end
        
        for stackIndex = 1:numIntensityStacks
            intensityImage = intensityStacks{stackIndex}.getImage(1);
            roi.loadIntensity(intensityImage, 5, stackIndex, intensityStacks{stackIndex})
        end
        this.tracker.addFirstDroplets(roi);

        wbar{i}.Value = 1/this.tracker.dataSize;

        for imageIndex = 2:this.tracker.dataSize;

            segmentImage = segmentStack.getImage(imageIndex);
            roi = this.segmenter.segment(segmentImage, segmentStack);

            for stackIndex = 1:numIntensityStacks
                intensityImage = intensityStacks{stackIndex}.getImage(imageIndex);
                roi.loadIntensity(intensityImage, 5, stackIndex, intensityStacks{stackIndex})
            end

            this.tracker.addDroplets(roi);
            wbar{i}.Value = imageIndex/this.tracker.dataSize;
        end
        saveFile = this.getDropletFile(segmentStack);
        
        droplets = this.tracker.droplets;
        junkSize = 50000;
        numDroplets = numel(droplets);
        if (numDroplets < junkSize)
            save(saveFile.fullpath, 'droplets');
        else
            droplets1 = droplets(1:junkSize);
            save(saveFile.fullpath, 'droplets1');
            clear droplets1;
            numberOfJunks = ceil(numDroplets / junkSize);
            for junkIdx = 2:numberOfJunks
                varName = sprintf('droplets%i', junkIdx);
                dropletJunk = droplets((1 + (junkIdx-1)*junkSize):min(numDroplets, junkIdx*junkSize));
                eval(sprintf('%s = dropletJunk;', varName));
                save(saveFile.fullpath, varName, '-append');
                clear(varName);
            end
            clear dropletJunk;
        end
        clear droplets;
    end
    delete(f);
    msgbox('tracking finished');
end