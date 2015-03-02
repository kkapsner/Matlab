function [varargout] = dialog(seg)
% SEGMENTER.DIALOG opens a GUI to inspect and modify the segmenter
% properties
    
    dm = DialogManager(seg);
    
    if (nargout == 1)
        varargout{1} = dm;
    end
    
    dm.height = 340;
    dm.open();
    
    %% threshold panel
    dm.addPanel(1, 'Threshold');
    
    % create controlls
    computeThreshold = dm.addPropertyCheckbox('compute', 'computeThreshold', [0 0 80 20]);

    thresholdSlider = dm.addPropertySlider('threshold', 0, 1, ...
        [80, 0, dm.innerWidth - 80, 20] ...
    );
    dm.checkboxHides(computeThreshold, thresholdSlider, true);
    
    %% BW enhancement panel
    dm.addPanel(6, 'BW enhancements');
    
    % create controlls
    dm.checkboxHides( ...
        dm.addPropertyCheckbox('fill', 'performFilling', {@(w)0, @(w)100}),...
        dm.addPropertySlider('fillingMaxHoleSize', 0, 20, {@(w)100, @(w)w - dm.innerPadding-100}) ...
    );
    dm.newLine();
    dm.addPropertyCheckbox('dead ends', 'performDeadEndRemoving', {@(w)0, @(w)w/2});
    dm.addPropertyCheckbox('bridging', 'performBridging', {@(w)w/2, @(w)w/2});
    dm.newLine();
    dm.checkboxHides( ...
        dm.addPropertyCheckbox('extrude', 'performExtrude', 100), ...
        dm.addPropertySlider('extrudeStrength', 0, 10, {@(w)100, @(w)w - dm.innerPadding-100}) ...
    );
    
    dm.newLine();
    dm.checkboxHides( ...
        dm.addPropertyCheckbox('thinning', 'performThinning', {@(w)0, @(w)w/2}), ...
        dm.addPropertyCheckbox('keep connection to image border', 'preserveBorderConnectionsOnThinning', {@(w)w/2, @(w)w/2}) ... 
    );
    dm.newLine();
    dm.addPropertyCheckbox('clear border', 'clearBorder', {@(w)0, @(w)w});
    
    %% watershed panel
    dm.addPanel(3, 'Watershed');
    
    % create controlls
    performWatershed = dm.addPropertyCheckbox('perform', 'performWatershed', [0 0 80 20]);
    
    watershedEccentricityText = dm.addText( ...
        'threshold', [80, 0, 50, 20] ...
    );

    watershedEccentricitySlider = dm.addPropertySlider('watershedEccentricityThreshold', 0, 1, ...
        [130, 0, dm.innerWidth - 130, 20] ...
    );
    watershedEccentricitySlider.TooltipString = 'eccentricity threshold';
    dm.checkboxHides(performWatershed, watershedEccentricityText);
    dm.checkboxHides(performWatershed, watershedEccentricitySlider);

    dm.newLine();
    
    watershedHoleThresholdText = dm.addText( ...
        'hole threshold', [80, 0, 50, 20] ...
    );

    watershedHoleThresholdSlider = dm.addPropertySlider('watershedHoleThreshold', 0, 200, ...
        [130, 0, dm.innerWidth - 130, 20] ...
    );
    dm.checkboxHides(performWatershed, watershedHoleThresholdText);
    dm.checkboxHides(performWatershed, watershedHoleThresholdSlider);

    dm.newLine();
    
    watershedFilterText = dm.addText( ...
        'filter', [80, 0, 50, 20] ...
    );

    watershedFilterSlider = dm.addPropertySlider('watershedFilter', 0, 20, ...
        [130, 0, dm.innerWidth - 130, 20] ...
    );
    dm.checkboxHides(performWatershed, watershedFilterText);
    dm.checkboxHides(performWatershed, watershedFilterSlider);
    
    %% area panel
    dm.addPanel(2, 'Area Range');
    
    % create controlls
    dm.addText('min', [0 0 30 20]);
    minAreaSlider = dm.addPropertySlider('areaRange(1)', 0, min(1000, seg.areaRange(2)) - 1.6, ...
        [30, 0, dm.innerWidth - 30, 20], @minAreaCallback ...
    );

    dm.newLine();
    dm.addText('max', [0 0 30 20]);
    maxAreaSlider = dm.addPropertySlider('areaRange(2)', max(0, seg.areaRange(1)) + 1.6, 1000, ...
        [30, 0, dm.innerWidth - 30, 20], @maxAreaCallback ...
    );
    
    %% filter
    dm.newLine();
    dm.addText('ToDo: filter configuration');
    
    %%

    dm.show();
    
    function minAreaCallback(~,~)
        minAreaSlider.Value = round(minAreaSlider.Value);
        maxAreaSlider.Min = minAreaSlider.Value + 1.6;
    end
    function maxAreaCallback(~,~)
        maxAreaSlider.Value = round(maxAreaSlider.Value);
        minAreaSlider.Max = maxAreaSlider.Value - 1.6;
    end
end