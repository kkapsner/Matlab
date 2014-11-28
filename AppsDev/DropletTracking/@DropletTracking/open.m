function dm = open(this)
%OPEN opens the GUI for DropletTracking
    
	imageDir = fullfile(fileparts(mfilename('fullpath')), 'private', 'images');
    
    okPath = fullfile(imageDir, 'ok.png');
    [okImg, map, alpha] = imread(okPath, 'png');
    
    
    dm = DialogManager(this);
    
    dm.width = 300;
    dm.lineHeight = 30;
    
    dm.open();
    
    dm.addPanel(6);
    selFolder = dm.addButton('select folder', @(a)a-35, @this.selectFolder);
    [~, okFolder] = addOK('folder');
    
    dm.newLine();
    selBF = dm.addButton('select BF stacks', @(a)a-35, @this.selectBFStacks);
    [~, okBF] = addOK('bfStacks');
    
    dm.newLine();
    selFluo = dm.addButton('select fluorescence stacks', @(a)a-35, @this.selectFluoStacks);
    [~, okFluo] = addOK('fluoStacks');
    
    dm.newLine();
    configureSegmenter = dm.addButton('configure segmenter', @(a)a-35, @this.configureSegmenter);
    [~, okSegmenter] = addOK('segmenter');
    
    dm.newLine();
    configureTracker = dm.addButton('configure tracker', @(a)a-35, @this.configureTracker);
    [~, okTracker] = addOK('tracker');
    
    dm.newLine();
    track = dm.addButton('track', @(a)a-35, @this.track);
    
    dm.show();
    
    listener([ ...
        addlistener(this, 'folder', 'PostSet', @handleEnable), ...
        addlistener(this, 'bfStacks', 'PostSet', @handleEnable), ...
        addlistener(this, 'fluoStacks', 'PostSet', @handleEnable), ...
        addlistener(this, 'segmenter', 'PostSet', @handleEnable), ...
        addlistener(this, 'tracker', 'PostSet', @handleEnable) ...
    ]);
    handleEnable();
    
    
    
    function handleEnable(~,~)
        hasFolder = ~(isempty(this.folder) || this.folder == 0);
        hasBF = ~(isempty(this.bfStacks));
        hasFluo = hasBF && numel(this.bfStacks) == numel(this.fluoStacks);
        hasSegmenter = ~(isempty(this.segmenter));
        hasTracker = ~(isempty(this.tracker));
        
        visible(okFolder, hasFolder);
        visible(okBF, hasBF);
        visible(okFluo, hasFluo);
        visible(okSegmenter, hasSegmenter);
        visible(okTracker, hasTracker);
        
        
        enable(selBF, hasFolder);
        enable(selFluo, hasFolder && hasBF);
        enable(configureSegmenter, hasFolder && hasBF);
        enable(configureTracker, hasFolder && hasFluo);
        enable(track, hasFolder && hasBF && hasFluo && hasSegmenter && hasTracker);
    end

    function enable(el, v)
        if (v)
            value = 'on';
        else
            value = 'off';
        end
        
        el.Enable = value;
    end

    function visible(el, v)
        if (v)
            value = 'on';
        else
            value = 'off';
        end
        el.Visible = value;
    end

    function [ax, img] = addOK(prop)
        ax = handle(axes( ...
            'Parent', dm.currentPanel, ...
            'Units', 'pixels', ...
            'Position', [dm.innerWidth - 30, 0, 30, 22], ...
            'Visible', 'off', ...
            'HandleVisibility', 'callback' ...
        ));
        img = handle(imshow(okImg, map, 'Parent', ax));
        img.AlphaData = alpha;
        ax.XLim = [0, 21.5];
    %     selImage.YLim = [-0.5, 21.5];
        dm.addElement(ax, {@(a)a-22, @(a)22});
    end

    function listener(l)
        addlistener(dm, 'closeWin', @(~,~)delete(l));
    end
end

