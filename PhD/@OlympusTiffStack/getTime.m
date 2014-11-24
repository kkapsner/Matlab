function time = getTime(this)
    time = zeros(this.size, 1);
    offset = this.olympusInfo.TimePos1;
    for i = 2:this.size
        currentInfo = OlympusTiffStack.readOlympusTags(this.info(i));
        time(i) = currentInfo.TimePos1;
    end
    time = time ./ 1000;
end