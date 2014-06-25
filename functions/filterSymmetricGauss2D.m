function filtered = filterSymmetricGauss2D(sigmaX, sigmaY, data)
    %filterSymmetricGuass2D(SIGMAX, SIGMAY, DATA)
    %
    %
    % see filterSymmetricWindow2D
    
    if (nargin < 3)
        data = sigmaY;
        sigmaY = sigmaX;
    end
    if (sigmaX == 0 && sigmaY == 0)
        filtered = data;
    else
        if (sigmaX == 0)
            filterX = 1;
        else
            filterX = exp(-(0:ceil(3*sigmaX)).^2/sigmaX^2);
        end
        if (sigmaY == 0)
            filterY = 1;
        else
            filterY = exp(-(0:ceil(3*sigmaY)).^2/sigmaY^2);
        end
%         filtered = transpose(filterY) * filterX;
        filtered = filterSymmetricWindow2D(transpose(filterY) * filterX, data);
    end
end