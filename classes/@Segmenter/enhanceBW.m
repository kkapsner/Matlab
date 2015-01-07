function image = enhanceBW(this, image)
    % ENHANCEBW performs the bw image enhancement
    %   ROI = SEGMENTER.ENHANCEBW(IMAGE)

    if (this.performFilling)
        image = Image.fill(image, this.fillingMaxHoleSize);
        %binImage = bwmorph(binImage, 'fill');
    end
    if (this.performDeadEndRemoving)
        image = Image.removeDeadEnds(image);
    end
    if (this.performBridging)
%                 binImage = ~bwmorph(~binImage, 'bridge');
        image = ~Image.bridge(~image);
    end
    if (this.performExtrude)
        image = ~bwmorph(~image, 'dilate', this.extrudeStrength);
%         binImage = ~bwmorph(~binImage, 'thicken', seg.extrudeStrength);
        image = ~bwmorph(~image, 'bridge');
    end
    if (this.performThinning)
        if (this.preserveBorderConnectionsOnThinning)
            img = zeros(size(image) + 2);
            img(2:end-1, 2:end-1) = image;
            image = img;
            delete img;
        end
        image = ~bwmorph(~image, 'thin', Inf);
        if (this.preserveBorderConnectionsOnThinning)
            image = image(2:end-1,2:end-1);
        end
    end

    if (this.clearBorder)
        image = imclearborder(image, 4);
    end
end