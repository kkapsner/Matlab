function setEventListener(obj)
%SETEVENTLISTENER adds the event listener to the controls
    
    obj.setControlProperty('panel', 'ResizeFcn', @(~,~)obj.repaint());

    addlistener(obj.controls.valueInput, 'valueChange', @valueChange);
    addlistener(obj.controls.minInput, 'valueChange', @minChange);
    addlistener(obj.controls.maxInput, 'valueChange', @maxChange);
    
    addlistener(obj.controls.slider, 'Value', 'PostSet', @sliderChange);
    obj.setControlProperty('slider', 'Callback', @notifyCallback);
    
    addlistener(obj.controls.imline, 'newPosition', @imlineChange);
    addlistener(obj.controls.imline, 'dragStop', @notifyCallback);
    
    
    function valueChange(~,~)
        obj.value = obj.controls.valueInput.value;
        notifyCallback();
    end
    function minChange(~,~)
        obj.min = obj.controls.minInput.Value;
    end
    function maxChange(~,~)
        obj.max = obj.controls.maxInput.Value;
    end
    function sliderChange(~,~)
        obj.value = obj.controls.slider.Value;
    end
    function imlineChange(imline,~)
        obj.value = imline.position;
    end
    function notifyCallback(varargin)
        notify(obj, 'callback');
    end
end

