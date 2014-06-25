function fit = inversePoly(order)
%POLY creates an polynomial fit object
    
    funcStr = '@(';
    for i = 0:order;
        funcStr = [funcStr sprintf('a%u, ', i)];
    end
    funcStr = [funcStr 'x)a0'];
    
    tex = '$a_0';
    for i = 1:order;
        funcStr = [funcStr sprintf(' + (a%u * x.^-%u)', i, i)];
        tex = [tex sprintf(' + a_%u \\cdot x^{-%u}', i, i)];
            end
    tex = [tex '$'];
    fit = Fit.FitObject(eval(funcStr));
    
    fit.funcTex = tex;

end

