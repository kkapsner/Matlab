function displayImage(obj, img)
%DISPLAYIMAGE displays an image in the ImageDisplay
    
    image(img, 'Parent', obj.handles.axes);
    notify(obj, 'newImage');
end

