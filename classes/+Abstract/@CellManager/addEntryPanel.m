function panel = addEntryPanel(this, entry)
%ADDENTRYPANEL adds a panel for the entry
    panel = this.handles.innerAPI.addPanel( ...
        'Units', 'Pixels', ...
        'BorderWidth', 0, ...
        'Position', [0, 0, 30, 30]...
    );
    this.fillEntryPanel(entry, panel);
end

