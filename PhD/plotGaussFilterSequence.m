function plotGaussFilterSequence(sigmas, x, y)
    colors = ['xb'; 'xg'; 'xr'; 'xc'; 'ob'; 'og'; 'or'; 'oc'; '+b'; '+g'; '+r'; '+c'];
    figure;
    hold on;
    for i = 1:length(sigmas)
        plot(x, max(diff(filterSymmetricGauss(sigmas(i), y))), colors(mod(i-1,12)+1,:));
    end
    legend(num2str(sigmas'));
    hold off;
end