
classdef map
    
    properties
        n;
        reg;
    end
    
    methods
        function mapobj = MapData
            
        end
            
        function [regAvoid] = getAvoidStartReg(mapobj,aut,imode)
            % Avoid regions for starting region
            count = 0;
            for j = 1:mapobj.n
                if ~(aut.q{imode} == j)
                    count = count+1;
                    regAvoid{count} = mapobj.reg{j};
                end
            end
        end
        
        function [regAvoid] = getAvoidStartGoalReg(mapobj,aut,itrans)
            % Avoid regions for start and goal regions
            count = 0;
            for j = 1:mapobj.n
                if ~(aut.q{aut.trans{itrans}(1)} == j) && ~(aut.q{aut.trans{itrans}(2)} == j)
                    count = count+1;
                    regAvoid{count} = mapobj.reg{j};
                end
            end
        end
        
        function [regAvoid] = getAvoidGoalReg(mapobj,aut,itrans)
            % Avoid regions for goal region
            count = 0;
            for j = 1:mapobj.n
                if ~(aut.q{aut.trans{itrans}(2)} == j)
                    count = count+1;
                    regAvoid{count} = mapobj.reg{j};
                end
            end
        end
    end
end