function close(a)
%CLOSE closes the figure
    for ax = a
        close(ax.f);
    end

end

