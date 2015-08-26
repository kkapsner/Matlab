function trackBacteriaByHand(invert, filter)
	if (nargin < 1)
		invert = true;
	end
	if (nargin < 2)
		filter = true;
	end
    bfFile = File.get({'*.tif;*.tiff', 'TIFF stacks';'*.mat', 'MATLAB data file';'*.*', 'All files'}, 'Select bright field TIFF stack');
    if (bfFile ~= 0)
        if (strcmpi(bfFile.extension, '.mat'))
            data = load(bfFile.fullpath);
            if (isfield(data, 'bfStack') && isfield(data, 'fluoStack'))
                bfStack = data.bfStack;
                fluoStack = data.fluoStack;
            else
                errordlg('Data file does not contain stacks.');
                return;
            end
        else
            rawBF = TiffStack.guiCreateStack(bfFile);
            if (filter)
                rawBF = rawBF.filter([1.2, 10]);
            end
            if (invert)
                rawBF = rawBF.invert();
            else
                rawBF = rawBF.normalise();
            end
%             croppedBG = rawBF.guiCrop('Select bacteria region');
%             background = rawBF.guiCrop('Select background region');
%             croppedBG = CroppedTiffStack(rawBF);
%             croppedBG.dialog().wait();
%             background = CroppedTiffStack(rawBF);
%             background.dialog().wait();

%             bfStack = FunctionTiffStack( ...
%                 croppedBG, ...
%                 @(img, idx)0.5*img/mean(mean(background.getImage(idx)))...
%             );
            bfStack = rawBF;

            fluoFile = File.get({'*.tif;*.tiff', 'TIFF stacks'}, 'Select fluorescence TIFF stack', 'on');
            fluoStack = CroppedTiffStack( ...
                TiffStack.guiCreateStack(fluoFile), ...
                croppedBG.xRange, ...
                croppedBG.yRange ...
            );

            if (isempty(fluoFile) || strcmp(bfFile.path, fluoFile(1).path))
                dataFile = File.get({'*.mat'}, 'Save stacks', 'put');
                if (dataFile ~= 0)
                    save(dataFile.fullpath, 'bfStack', 'fluoStack');
                end
            end
        end
        segmenter = Segmenter();
        segmenter.performWatershed = false;
        segmenter.computeThreshold = false;
        segmenter.threshold = 0.49;
        segmenter.areaRange = [5, 3000];
        
        dm = DialogManager(bfStack);
        dm.open('select start frame');
        dm.addPanel();
        display = TiffStackDisplay(dm.currentPanel, bfStack, 1);
        dm.addPanel(1);
        display.createIndexSlider(dm);
        dm.addPanel(1);
        selectButton = dm.addButton('select', [], @(~,~)dm.close());
        uicontrol(double(selectButton));
        dm.show();
        dm.wait();

        assignin('base', 'bacteria', trackByHand(bfStack, fluoStack, segmenter, display.currentImageIndex));

    end
end

