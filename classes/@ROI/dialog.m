function dm = dialog(this)
    if (numel(this) ~= 1)
        error('Dialog can only be opened for scalar ROIs.');
        return;
    end
    
    dm = DialogManager(this);
    
    dm.width = 260;
    
    dm.open();
    
    axesPanel = dm.addPanel();
    ax = axes( ...
        'Parent', axesPanel, ...
        'Units', 'normalize', ...
        'HandleVisibility', 'callback', ...
        'Position', [0, 0, 1, 1] ...
    );

    Image.show(this.Image, ax);
    hold(ax, 'on');
    concaveImage = this.ConcaveImage;
    image(TiffStackDisplay.mat2rgb(concaveImage, [1, 0, 0]), 'Parent', ax, 'AlphaData', 0.5 * concaveImage);
    axis(ax, 'off');
    
    dm.addPanel(1);
    dm.addButton('save to workspace', @(w)w, @(~,~)assignin('base', 'regionOfInterest', this));
    
    dm.addPanel(6, 'First order properties');
    
    dm.addText('Area', 80);
    dm.addText(num2str(this.Area), [85, 0, 160, 0]);
    dm.newLine();
    
    dm.addText('Diameter', 80);
    dm.addText(sprintf('%.2f', this.EquivDiameter), [85, 0, 160, 0]);
    dm.newLine();
    
    dm.addText('Perimeter', 80);
    dm.addText(sprintf('%.2f', this.Perimeter), [85, 0, 160, 0]);
    dm.newLine();
    
    dm.addText('Centroid', 80);
    dm.addText(sprintf('(%.2f, %.2f)', this.Centroid(1), this.Centroid(2)), [85, 0, 160, 0]);
    dm.newLine();
    
    dm.addText('x range', 80);
    dm.addText(sprintf('%d - %d', this.minX, this.maxX), [85, 0, 160, 0]);
    dm.newLine();
    
    dm.addText('y range', 80);
    dm.addText(sprintf('%d - %d', this.minY, this.maxY), [85, 0, 160, 0]);
    
    dm.addPanel(6, 'Second order properties');
    
    dm.addText('Cyclicity', 80);
    dm.addText(sprintf('%.2f', this.Cyclicity), [85, 0, 160, 0]);
    dm.newLine();
    
    dm.addText('Concavity', 80);
    dm.addText(sprintf('%.2f', this.Concavity), [85, 0, 160, 0]);
    dm.newLine();
    
    dm.addText('Orientation', 80);
    dm.addText(sprintf('%.2f°', this.Orientation), [85, 0, 160, 0]);
    dm.newLine();
    
    dm.addText('Eccentricity', 80);
    dm.addText(sprintf('%.2f', this.Eccentricity), [85, 0, 160, 0]);
    dm.newLine();
    
    dm.addText('minor axis', 80);
    dm.addText(sprintf('%.2f', this.MinorAxisLength), [85, 0, 160, 0]);
    dm.newLine();
    
    dm.addText('major axis', 80);
    dm.addText(sprintf('%.2f', this.MajorAxisLength), [85, 0, 160, 0]);
    
    dm.show();
end