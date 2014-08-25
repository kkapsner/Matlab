function rgbVideo = gray2rgb(video)
    rgbVideo = zeros( ...
        size(video, 1), ...
        size(video, 2), ...
        3, ...
        size(video, 3) ...
    );
    for i = 1:size(video, 3)
        rgbVideo(:, :, 1, i) = video(:, :, i);
        rgbVideo(:, :, 2, i) = video(:, :, i);
        rgbVideo(:, :, 3, i) = video(:, :, i);
    end
end