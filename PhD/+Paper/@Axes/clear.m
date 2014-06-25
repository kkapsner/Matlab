function clear(a)
%AXES.CLEAR removes all plots
    for ax = a
        cla(ax.ax);
    end

end

