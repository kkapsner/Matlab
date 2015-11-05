function openVeraTraceApp()
    stepper = VeraTrace();
    
    dm = DialogManager(stepper);
    dm.height = 300;
    dm.width = 600;
    dm.lineHeight = 40;
    dm.padding = 20;
    dm.open('Vera Trace App');
    dm.addPanel(1, 'What du you want to analyse?');
    dm.addButton('peak', @(w)w/2-20, @peakCallback);
    dm.addButton('step', {@(w)w/2+20 @(w)w/2-20}, @stepCallback);
    dm.show();
    
    function stepCallback(~,~)
        stepper.step();
        assignin('base', 'domainData', stepper.data);
    end
    
    function peakCallback(~,~)
        data = stepper.peak( ...
            @detectEvent, ...@detect_single_events, ...
            EventSettings  ...
        );
        assignin('base', 'peakData', data);
    end
end