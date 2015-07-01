function [varargout] = dialog(tracker)
    
    dm = DialogManager(tracker);
    
    if (nargout == 1)
        varargout{1} = dm;
    end
    
    dm.height = 175;
    dm.open();
    
    %% data size
    dm.addPanel(3);
    
    % create controlls
    dm.addText('start index', 80);
    startIndexSlider = dm.addPropertySlider('startIndex', 0, max(100, tracker.startIndex), ...
        [80, 0, dm.innerWidth - 80, 20], @startIndexCallback ...
    );

    function startIndexCallback(value)
        startIndexSlider.Value = round(value);
        tracker.startIndex = round(value);
    end

    dm.newLine();
    dm.addText('stop index', 80);
    stopIndexSlider = dm.addPropertySlider('stopIndex', 0, max(100, tracker.stopIndex), ...
        [80, 0, dm.innerWidth - 80, 20], @stopIndexCallback ...
    );

    function stopIndexCallback(value)
        stopIndexSlider.Value = round(value);
        tracker.stopIndex = round(value);
    end

    dm.newLine();
    dm.addText('data size', 80);
    dataSizeSlider = dm.addPropertySlider('dataSize', 0, max(100, tracker.dataSize), ...
        [80, 0, dm.innerWidth - 80, 20], @dataSizeCallback ...
    );

    function dataSizeCallback(value)
        dataSizeSlider.Value = round(value);
        tracker.dataSize = round(value);
    end
    
    %% radius panel
    dm.addPanel(2, 'Radius change');
    
    % create controlls
    dm.addText('max', 80);
    dm.addPropertySlider('maxRadiusChange', 0, 1, ...
        [80, 0, dm.innerWidth - 80, 20] ...
    );

    dm.newLine();
    dm.addText('min-max', 80);
    dm.addPropertySlider('minMaxRadiusChange', 0, 10, ...
        [80, 0, dm.innerWidth - 80, 20] ...
    );
    
    %% border distance
    dm.addPanel(1, 'border distance');
    
    % create controlls
    dm.addText('max', 80);

    dm.addPropertySlider('maxBorderDistance', 0, 10, ...
        [80, 0, dm.innerWidth - 80, 20] ...
    );

    dm.show();
end