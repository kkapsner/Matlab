function f = dropletTracking()
%DROPLETTRACKING starts the DropletTracking App
    
    tr = DropletTracking();
    dm = tr.open();
    
    f = dm.getFigure();
end

