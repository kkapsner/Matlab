function configureSegmenter(this)
    if (isempty(this.segmenter))
        this.segmenter = Segmenter();
        this.segmenter.readFromConfigFile(this.config, 'segmenter');
    end

    bfDm = this.bfStacks{1}.dialog(false, this.segmenter);
    sDm = this.segmenter.dialog();

    listeners = [
        addlistener(sDm, 'closeWin', @(~,~)bfDm.close()), ...
        addlistener(sDm, 'propertyChange', @(~,~)notify(bfDm, 'propertyChange')) ...
    ];
    addlistener(bfDm, 'closeWin', @(~,~)delete(listeners));
    dms = [sDm, bfDm];
    dms.arrange([1, 1]);

    sDm.wait();
    this.segmenter.writeToConfigFile(this.config, 'segmenter');

    this.config.write();
end