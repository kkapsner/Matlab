function setEvents(obj)
%SETEVENTS set all used events
%   
    f = obj.drawApi.figure;
    set(obj.drawApi.hg, 'ButtonDownFcn', @mousePressCallback);

    buttonDown = false;
    motionListener = [];
    buttonUpListener = [];
    startPosition = obj.position;
    mouseStart = [];
    function mousePressCallback(~, ~)
        if (strcmp(get(f, 'SelectionType'), 'normal'))
            buttonDown = true;
            startPosition = obj.position;
            mouseStart = obj.drawApi.getCurrentPoint();
            startDrag();
        end
    end
    function mouseReleaseCallback(~, ~)
        buttonDown = false;
        stopDrag();
    end
    function mouseMoveCallback(~,~)
        if (buttonDown)
            mousePos = obj.drawApi.getCurrentPoint();
            obj.position = startPosition + mousePos - mouseStart;
        else
            stopDrag();
        end
    end

    function startDrag()
        iptPointerManager(f, 'disable');
        
        motionListener = iptaddcallback(f, ...
            'WindowButtonMotionFcn', @mouseMoveCallback);
        buttonUpListener = iptaddcallback(f, ...
            'WindowButtonUpFcn', @mouseReleaseCallback);
        notify(obj, 'dragStart');
    end

    function stopDrag()
        if isempty(motionListener)
            return
        end
        iptremovecallback(f, 'WindowButtonMotionFcn', motionListener);
        iptremovecallback(f, 'WindowButtonUpFcn', buttonUpListener);
        motionListener = [];
        buttonUpListener = [];
        iptPointerManager(f, 'enable')
        notify(obj, 'dragStop');
    end
end

