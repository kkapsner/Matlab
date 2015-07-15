function stdValue = std(this)
    stdValue = sqrt(this.secondMoment() - this.mean() .^ 2);
end