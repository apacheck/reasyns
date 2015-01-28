function [rho,info,L1] = computeRhoBilinearAlternationWhole(V,xdot,tau,X)

global t x bloatFlag initRhoConst1 initRhoConst2

N = size(xdot,2);
rho_runningMax = 1e-9*ones(N,1);
for k = 1:N
    Vdot(k) = diff(V(k),t) + diff(V(k),x)*xdot(:,k);
end

% Instantiate rho: start small
rho = initRhoConst1*ones(N,1).*exp(-(0:N-1))' + initRhoConst2;
%rho = 1e-2*ones(N,1).*exp(-(0:N-1))' + 1e-6;
rhodot = [0; (rho(2:N)-rho(1:N-1))./tau];  % piecewise "derivative"

for i = 1:20
    lastRho = rho;
    
    % Find a feasible multiplier
    for k = 1:N
        prog = mssprog;
        neggamma = msspoly('g',1);
        prog.psd = neggamma;
        
        Lxmonom = monomials(x,0:1*(deg(Vdot(k),x)-deg(V(k),x)));  % order is a design choice
        [prog,l] = new(prog,length(Lxmonom),'free');
        L1t = l'*Lxmonom;
%         prog.sos = L1t;
        prog.sos = -neggamma - (Vdot(k) - rhodot(k) + L1t*(rho(k) - V(k)));
        
        if nargin == 4
            % Unsafe set constraints for exterior sets
            if bloatFlag
                XmssExt = X.mssExtB;
            else
                XmssExt = X.mssExt;
            end
            if ~isempty(XmssExt)
                clear Luet
                for i = 1:length(XmssExt)
                    degL = 1;
                    Lxmonom = monomials(x,0:degL);
                    [prog,lu] = new(prog,length(Lxmonom),'free');
                    Luet(i) = lu'*Lxmonom;
                    prog.sos = Luet(i);
                    prog.sos = (V(k) - rho(k)) + Luet(i)*XmssExt(i);
                end
            end
            
            % Unsafe set constraints for interior sets
            if bloatFlag
                XmssInt = X.mssIntB;
            else
                XmssInt = X.mssInt;
            end
            for j = 1:length(XmssInt)
                if ~isempty(XmssInt{j})
                    clear Luit
                    for i = 1:length(XmssInt{j})
                        degL = 1;
                        Lxmonom = monomials(x,0:degL);
                        [prog,lu] = new(prog,length(Lxmonom),'free');
                        Luit(i) = lu'*Lxmonom;
                        prog.sos = Luit(i);
                    end
                    prog.sos = (V(k) - rho(k)) + Luit*XmssInt{j}';
                end
            end
        end
        
        opt = -1;  % +1: minimize the cost function; -1: maximize the cost function; 0: solve a feasibility problem (no cost function)
        
        pars.fid = 0; % 0 to suppress screen output; 1 to show screen output
        [prog,info] = sedumi(prog,1e6*neggamma,0,pars,opt);
        if info.pinf  % if this step fails, then use the previous iteration's rho or the initial rho
            disp('fail.')
            break
            %                 L1(k) = NaN;
            %                 rho(1:N) = 1e9
        else
            disp(num2str(-double(prog([neggamma]))))
            L1(k) = prog([L1t]);
            if ~isempty(XmssExt)
                for i = 1:length(XmssExt)
                    Lue{k} = prog([Luet]);
                end
            end
            for j = 1:length(XmssInt)
                if ~isempty(XmssInt{j})
                    for i = 1:length(XmssInt{j})
                        Lui{k} = prog([Luit]);
                    end
                end
            end
        end
    end
    if info.pinf % if this step fails, then use the previous iteration's rho or the initial rho
        if ~exist('L1'), L1 = []; end
        disp('stopping.')
        break
    end
    
    % Next, find a feasible rho
    prog = mssprog;
    [prog,rhot] = new(prog,N,'pos');
    rhodott = [0; rhot(2:N)-rhot(1:N-1)];  % piecewise "derivative"
    for k=1:N-1, rhodott(k) = rhodott(k)/tau(k); end
    prog.sos = -(Vdot' - rhodott + L1'.*(rhot - V'));
    
    if nargin == 4
        % Unsafe set constraints for exterior sets
        if bloatFlag
            XmssExt = X.mssExtB;
        else
            XmssExt = X.mssExt;
        end
        if ~isempty(XmssExt)
            clear Luet
            for i = 1:length(XmssExt)
                degL = 1;
                Lxmonom = monomials(x,0:degL);
                [prog,lu] = new(prog,length(Lxmonom),'free');
                Luet(i) = lu'*Lxmonom;
                prog.sos = Luet(i);
                prog.sos = (V(k) - rhot(k)) + Luet(i)*XmssExt(i);
                
%                 Lxmonom = monomials(x,0:degL);
%                 [prog,lu] = new(prog,length(Lxmonom),'free');
%                 Lued(i) = lu'*Lxmonom;
%                 prog.sos = Lued(i);
%                 prog.sos = -(Vdot(k) - rhodott(k) + Lued(i)*XmssExt(i));
            end
        end
        
        % Unsafe set constraints for interior sets
        if bloatFlag
            XmssInt = X.mssIntB;
        else
            XmssInt = X.mssInt;
        end
        for j = 1:length(XmssInt)
            if ~isempty(XmssInt{j})
                clear Luit
                for i = 1:length(XmssInt{j})
                    degL = 1;
                    Lxmonom = monomials(x,0:degL);
                    [prog,lu] = new(prog,length(Lxmonom),'free');
                    Luit(i) = lu'*Lxmonom;
                    prog.sos = Luit(i);
                    
%                     Lxmonom = monomials(x,0:degL);
%                     [prog,lu] = new(prog,length(Lxmonom),'free');
%                     Luid(i) = lu'*Lxmonom;
%                     prog.sos = Luid(i);
                end
                prog.sos = (V(k) - rhot(k)) + Luit*XmssInt{j}';
%                 prog.sos = -(Vdot(k) - rhodott(k) + Luid*XmssInt{j}');
            end
        end
    end
    
%     if nargin == 4
%         for k = 1:N
%             if ~isempty(XmssExt)
%                 for i = 1:length(XmssExt)
%                     prog.sos = (V(k) - rho(k)) + Lue{k}(i)*XmssExt(i);
%                 end
%             end
%             for j = 1:length(XmssInt)
%                 if ~isempty(XmssInt{j})
%                     prog.sos = (V(k) - rho(k)) + Lui{k}*XmssInt{j}';
%                 end
%             end
%         end
%     end
    
%     objFn = sum(rhot) - 1e1*exp(1:N)/exp(N)*rhot;
    objFn = exp(-1:-1:-N)/exp(-1)*rhot - 1e3*exp(1:N)/exp(N)*rhot;
    opt = -1;  % +1: minimize the cost function; -1: maximize the cost function; 0: solve a feasibility problem (no cost function)
    
    pars.fid = 0; % 0 to suppress screen output; 1 to show screen output
    [prog,info] = sedumi(prog,objFn,0,pars,opt);
    info
    if info.pinf % if this step fails, then use the previous iteration's rho or the initial rho
        disp('fail.')
        break
        %             clear rho
        %            rho = 1e9*ones(N,1)
    else
        rho = double(prog([rhot]))
        rhodot = [0; rho(2:N)-rho(1:N-1)];  % piecewise "derivative"
        
        if sum(rho) > sum(rho_runningMax)
            disp('updating rho_runningMax...')
            rho_runningMax = rho;
        end
    end
    
    abs((sum(rho) - sum(lastRho))/sum(rho))
    if abs((sum(rho) - sum(lastRho))/sum(rho)) < 0.01 || max(rho) < 1e-10 || (sum(lastRho)/sum(rho) > 5 && i > 5)
        break; % break if it appears that we are at a fixed point or if we're no longer improving
    end
end

end
