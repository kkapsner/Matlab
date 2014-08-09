classdef FitObject < handle
    %FITOBJECT Object to perform standard fits on data
    %   
    
    properties
        % name of the fit
        name
        
        % function that is used to fit
        func
        
        % if only the function body should be used to fit
        useFuncBody = true
        startX = -Inf
        endX = Inf
        startY = -Inf
        endY = Inf
        
        options = struct( ...
            'Method', 'NonLinearLeastSquares', ...
            'MaxFunEvals', 5000, ...
            'MaxIter', 5000 ...
        )
    end
    
    properties (SetAccess=private)
        lastResult
        numArguments
        arguments
        parameter
        problem
        independent
    end
    
    properties (Access=private)
        funcBody
        argumentType
        
        funcTex_
    end
    
    properties (Dependent)
        funcTex
        
        argumentNames
        parameterNames
        problemNames
        independentNames
    end
    
    events
        valueChange
    end
    
    methods
        function obj = FitObject(func)
            if (nargin)
                obj.func = func;
            end
        end
    end
    
    % SETTER
    methods
        function set.func(this, func)
            parNames = getFunctionArguments(func);
            this.numArguments = nargin(func);
            
            this.arguments = Fit.Parameter.empty();
            this.arguments(this.numArguments) = Fit.Parameter;
            this.parameter = 1:this.numArguments;
            this.argumentType = cell(this.numArguments, 1);
            
            for i = 1:this.numArguments
                this.arguments(i) = Fit.Parameter(this, parNames{i});
                addlistener( ...
                    this.arguments(i), ...
                    'type', 'PostSet', ...
                    @(~,~)this.addArgumentToList( ...
                        this.arguments(i).name, ...
                        this.arguments(i).type ...
                    ) ...
                );
                this.argumentType{i} = 'parameter';
            end
            
            this.problem = [];
            this.independent = [];
            this.setIndependent(parNames{end});
            
            this.func = func;
            str = func2str(func);
            this.funcBody = str(strfind(str, ')') + 1:end);
            
            this.funcTex = [];
        end
        
        function set.funcTex(this, funcTex)
            this.funcTex_ = funcTex;
        end
    end
    
    % GETTER
    methods
        function funcTex = get.funcTex(this)
            if (isempty(this.funcTex_))
                
                symbols = cell(this.numArguments, 1);
                for i = 1:this.numArguments
                    symbols{i} = sym(this.arguments(i).name);
                end
                try
                    this.funcTex = ['$', latex(this.func(symbols{:})), '$'];
                catch
                    this.funcTex = '... not spezified ...';
                end
            end
            funcTex = this.funcTex_;
        end
        function names = get.argumentNames(obj)
            names = {obj.arguments.name};
        end
        function names = get.parameterNames(obj)
            names = obj.getListProperties('parameter');
        end
        function names = get.problemNames(obj)
            names = obj.getListProperties('problem');
        end
        function names = get.independentNames(obj)
            names = obj.getListProperties('independent');
        end
    end
    
    methods
        function has = hasArgument(obj, argName)
            has = (sum(ismember(obj.argumentNames, argName) > 0));
        end
        function arg = arg(obj, argName)
            %OBJ.arg(NAME) alias to OBJ.getArgumentByName(NAME)
            
            arg = obj.getArgumentByName(argName);
        end
        function arg = getArgumentByName(obj, argName)
            arg = obj.arguments(obj.getArgumentIndex(argName));
        end
        
        function setParameter(obj, argName)
            obj.addArgumentToList(argName, 'parameter');
        end
        function setProblem(obj, argName)
            obj.addArgumentToList(argName, 'problem');
        end
        function setIndependent(obj, argName)
            obj.addArgumentToList(argName, 'independent');
        end
        
        function setArgumentValue(obj, argName, value)
            if isa(argName, 'cell')
                if length(value) == 1
                    value = ones(size(argName)) * value;
                end
                for i = 1:numel(argName)
                    obj.setArgumentValue(argName{i}, value(i));
                end
            else
                obj.arguments(obj.getArgumentIndex(argName)).value = value;
            end
        end
        
        [fitobj, goodness, output, warnstr, errstr, convmsg] = ...
                fit(obj, xData, yData)
        interval = confidenceInterval(fitObj, level, name)
    end
    
    % external functions
    methods
        guiChangeSettings(obj)
        y = feval(obj, x)
        h = plot(obj, x, varargin)
        str = getTextResult(this)
        % converter
        str = char(obj)
    end
    
    methods (Access=private)
        function is = isArgumentInList(obj, argIndex, list)
            is = any(obj.(list) == argIndex);
        end
        
        function removeArgumentFromList(obj, argIndex, list)
            if (nargin < 3)
                list = obj.argumentType{argIndex};
            end
            obj.(list) = obj.(list)(obj.(list) ~= argIndex);
        end
        
        function addArgumentToList(obj, argIndex, list)
            if (isa(argIndex, 'cell'))
                for i = 1:numel(argIndex)
                    obj.addArgumentToList(argIndex{i}, list);
                end
            elseif (isa(argIndex, 'char'))
                obj.addArgumentToList(obj.getArgumentIndex(argIndex), list);
            else
                assert(isnumeric(argIndex), ...
                    'Fit:addArgumentToList:argumentNoStringOrNumber', ...
                    'Argument must be a string or numeric.');
                
                if numel(argIndex) ~= 1
                    for i = argIndex
                        obj.addArgumentToList(i, list);
                    end
                else
                    if ~obj.isArgumentInList(argIndex, list)
                        obj.removeArgumentFromList(argIndex);
                        obj.(list)(end+1) = argIndex;
                        obj.argumentType{argIndex} = list;
                        if (~strcmp(list, obj.arguments(argIndex).type))
                            obj.arguments(argIndex).type = list;
                        end
                    end
                end
            end
        end
        
        function argIndex = getArgumentIndex(obj, argName)
            for i = 1:obj.numArguments
                if strcmp(argName, obj.arguments(i).name)
                    argIndex = i;
                    return;
                end
            end
            error('Fit:getArgumentIndex:notFound', ...
                ['Argument ' argName ' not found.']);
        end
        
        function [varargout] = getListProperties(obj, list)
            args = obj.arguments(obj.(list));
            
            if nargout > 0
                varargout{1} = {args.name};
            end
            if nargout > 1
                varargout{2} = [args.value];
            end
            if nargout > 2
                varargout{3} = [args.lowerBound];
            end
            if nargout > 3
                varargout{4} = [args.upperBound];
            end
        end
    end
    
    methods (Static)
        function this = loadobj(o)
            if (isstruct(o))
                this = Fit.FitObject();
                for fieldname = fieldnames(o)
                    this.(fieldname{1}) = o.(fieldname{1});
                end
            else
                this = o;
            end
            
            for arg = o.arguments
                arg.fit = o;
            end
        end
    end
end

