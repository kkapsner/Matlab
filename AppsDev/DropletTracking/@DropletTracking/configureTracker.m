function configureTracker(this)
    this.tracker = DropletTracker(this.numImages, this.numFluo);
    this.tracker.readFromConfigFile(this.config, 'tracker');

    this.tracker.dialog().wait();
    this.tracker.writeToConfigFile(this.config, 'tracker');

    this.config.write();
end