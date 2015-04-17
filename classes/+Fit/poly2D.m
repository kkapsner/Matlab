function fit = poly2D(order)
%POLY creates an polynomial fit object
    
    funcStr = '@(a0, ';
    for i = 1:order;
        funcStr = [funcStr sprintf('a%u_1, a%u_2, ', i, i)];
    end
    funcStr = [funcStr 'x1, x2)a0'];
    
    tex = '$a_0';
    for i = 1:order;
        funcStr = [funcStr sprintf(' + (a%u_1 .* x1.^%u) + (a%u_2 .* x2.^%u)', i, i, i, i)];
        tex = [tex sprintf(' + a_{%u, 1} \\cdot x_1^%u + a_{%u, 2} \\cdot x_2^%u', i, i, i, i)];
            end
    tex = [tex '$'];
    fit = Fit.FitObject(eval(funcStr));
    
    fit.funcTex = tex;

    fit.setIndependent({'x1', 'x2'});
end

