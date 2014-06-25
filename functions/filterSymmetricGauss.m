function filtered = filterSymmetricGauss(sigma, data)
    %filterSymmetricGuass(SIGMA, DATA)
    %
    %
    % see filterSymmetricWindow
    if (sigma == 0)
        filtered = data;
    else
        filtered = filterSymmetricWindow(exp(-(0:ceil(3*sigma)).^2/sigma^2), data);
    end
end