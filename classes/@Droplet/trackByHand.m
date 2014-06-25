function [droplet, jumpIdx] = trackByHand(this)
%DROPLETS.TRACKBYHAND provides an interface for manual tracking
    if (isempty(this))
        % no tracking of no droplets
        return;
    end
    droplet = Droplet( ...
        numel(this(1).radius), ...
        1, ...
        size(this(1).intensitySum, 2) ...
    );
    jumpIdx = NaN(size(droplet.radius));
    
    droplet.stacks = this(1).stacks;
    
    allDroplets = [this, droplet];
    selectionDisplay = DropletSelectionDisplay(allDroplets);
    allDroplets.dialog(selectionDisplay);
    
    noSelection = false(numel(this) + 1, 1);
    dropletSelection = noSelection;
    dropletSelection(end) = true;
    selectionDisplay.selections = {noSelection, dropletSelection};
    addlistener(selectionDisplay, 'selections', 'PostSet', @disableLastDroplet);
    
    dm = DialogManager(this);
    selectionDisplay.dm.dependsOn(dm);
    dm.dependsOn(selectionDisplay.dm);
    
    dm.open();
    
    dm.addPanel(1);
    jump = dm.addButton('jump to selected droplet', 0, @doJump);
    addlistener(selectionDisplay, 'selections', 'PostSet', @updateJumpEnable);
    
    dm.show();
    dm.wait();
    
    function doJump()
        imageIndex = selectionDisplay.currentImageIndex;
        dropletIndex = find(selectionDisplay.selections{1}, 1, 'first');
        droplet.copyDataFromDroplet( ...
            this(dropletIndex), ...
            imageIndex ...
        );
        jumpIdx(selectionDisplay.currentImageIndex: end) = dropletIndex;
        selectionDisplay.selections{1} = noSelection;
    end
    function updateJumpEnable(~, ~)
        if (sum(selectionDisplay.selections{1}(:)) == 1)
            jump.Enable = 'on';
        else
            jump.Enable = 'off';
        end
    end

    function disableLastDroplet(~, ~)
        if (selectionDisplay.selections{1}(end))
            selectionDisplay.selections{1}(end) = false;
        end
    end
end

