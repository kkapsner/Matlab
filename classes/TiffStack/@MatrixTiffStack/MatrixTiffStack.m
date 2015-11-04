classdef MatrixTiffStack < AbstractTiffStack
    %MatrixTiffStack takes a 3D matrix and creates a stack to work with
    %other stacks
    
    properties(SetAccess=private)
        matrix
    end
    
    methods
        function this = MatrixTiffStack(matrix)
            if (nargin >= 1)
                this.matrix = matrix;
            end
        end
        
        function height = getHeight(this)
            height = size(this.matrix, 1);
        end
        
        function width = getWidth(this)
            width = size(this.matrix, 2);
        end
        
        function length = getSize(this)
            length = size(this.matrix, 3);
        end
        
        function fillNamePanel(this, dm, panel, addText)
        end
        
        function text = getNamePanelText(this)
            text = 'Matrix';
        end
    end
end

