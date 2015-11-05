function panel = getDialogPanel(this, dm, handles)
%GETDIALOGPANEL
    panel = dm.addPanel(2);
    textWidth = 100;
    dm.addText('number of channels', textWidth);
    handles.numChannel = dm.addPropertyInput('numChannel', {@(w)textWidth, @(w)w-textWidth});
    dm.newLine();
    dm.addText('channel', textWidth);
    handles.channel = dm.addPropertySlider('channel', 1, this.numChannel, {@(w)textWidth, @(w)w-textWidth});
    c = handles.channel;
    addlistener(handles.channel, 'Value', 'PostSet', @(~,~)set(c, 'Value', round(get(c, 'Value'))));
    
    l = [
        addlistener(this, 'numChannel', 'PostSet', @updateChannelSlider)
        addlistener(handles.channel, 'ObjectBeingDestroyed', @removeListener)
    ];
    updateChannelSlider();
    
    function updateChannelSlider(varargin)
        if (this.numChannel == 1)
            handles.channel.Visible = 'off';
        else
            handles.channel.Visible = 'on';
            handles.channel.SliderStep = ones(1, 2) / (this.numChannel - 1);
            handles.channel.Max = this.numChannel;
        end
    end
    function removeListener(varargin)
        delete(l);
    end
end

