%
% Reach operation -- construct transition funnels
%


IsectInAll{iModeToPatch} = zeros(1,size(qCover{iModeToPatch},1));

% Avoid regions for starting region
% TODO: helper function
[vAvoid1,vAvoid1B,vAvoid1BN,regAvoid1] = deal([]);
count = 0;
for j = 1:length(reg)
    if ~(aut.q{iModeToPatch} == j)
        count = count+1;
        vAvoid1{count} = reg{j}.v;
        vAvoid1B{count} = reg{j}.vB;
        vAvoid1BN{count} = reg{j}.vBN;
        regAvoid1{count} = reg{j};
    end
end

[Vbnd1tmp,ellBndInv11tmp] = deal([]);

if true
    % ==========================
    % Compute transition funnels
    
    hindx = 1;  % reset Halton seed
    hindx1 = 1;  % reset Halton seed
    
    transTmp = cell2mat(aut.trans');
    
    funFail = true;
    
    if countReach >= 20
        break
    end
    
    for funindx = 1:maxFunTrials
        funindx
        % while funFail
        
        countReach = 0;
        i = 1;
        while true  % will also break if region is considered covered as per a coverage metric
            countReach = countReach+1;
            countReach
            if countReach >= 20
                break
            end
            
            k2 = 1;  % Keep tree depth at 1 for now.
            
            disp('Computing initial point....')
            if k2 == depthTrans;
                qCenter = [];
%                 if length(find(transTmp(:,2)==iModeToPatch)') - length(find(transTmp(:,1)==iModeToPatch & transTmp(:,2)==iModeToPatch)') == 1 % only one incoming edge not counting self-loops
%                 if length(find(transTmp(:,2)==iModeToPatch)') - length(find(transTmp(:,1)==iModeToPatch & transTmp(:,2)==iModeToPatch)') > 0 % one or more incoming edge not counting self-loops
%                     if ~isempty(find(transTmp(:,2)==iModeToPatch)) % valid predecessor exists
%                         qCenter = finalPtMode{find(transTmp(:,2)==iModeToPatch)'};
%                     end
%                 end
                try 
                    [initState] = getCenterRand(vReg{aut.q{iModeToPatch}},vAvoid1BN,vBnd{1},[],[],Hout,n,limsNonRegState,'rand',Qrand,qCenter);
                catch
                    qCenter = finalPtMode{find(transTmp(:,2)==iModeToPatch)'};
                    [initState] = getCenterRand(vReg{aut.q{iModeToPatch}},vAvoid1BN,vBnd{1},[],[],Hout,n,limsNonRegState,'rand',Qrand,qCenter);
                end
            else
                [initState,hindx] = getRandom2(vReg{aut.q{iModeToPatch}},vAvoid1,[],[],'discrep',[],hindx,Hout,n,limsNonRegState,isCyclic);  % Get initial point
            end
            if isempty(initState)
                error('getRandom1: Cannot obtain an initial point.')
            end
            initState
            initOutput = initState(1:length(Hout))*Hout;
            
            for itrans = find(transTmp(:,1)==iModeToPatch)'
                
                [Vbnd1,ellBndInv11] = deal([]);
                if isReactive(itrans)
                    ellBndInv11 = ellBndInv11tmp;
                    Vbnd1 = Vbnd1tmp;
                else
                    ellBndInv11 = [];
                    Vbnd1 = 1;  % not actually used in comps; it's used to tell computeConstantRho3 that we need transition funnels
                end
                
                [vAvoid,vAvoid2,vAvoidB,vAvoid2B,regAvoid,regAvoid2] = deal([]);
                % TODO: helper function
                count = 0;
                for j = 1:length(reg)
                    if ~(aut.q{aut.trans{itrans}(1)} == j) && ~(aut.q{aut.trans{itrans}(2)} == j)
                        count = count+1;
                        vAvoid{count} = reg{j}.v;
                        vAvoidB{count} = reg{j}.vB;
                        regAvoid{count} = reg{j};
                    end
                end
                % TODO: helper function
                count = 0;
                for j = 1:length(reg)
                    if ~(aut.q{aut.trans{itrans}(2)} == j)
                        count = count+1;
                        vAvoid2{count} = reg{j}.v;
                        vAvoid2B{count} = reg{j}.vB;
                        regAvoid2{count} = reg{j};
                    end
                end
                
                % TODO: helper function
                if k2 ~= 1  % we're trying to create sequentially-composable reach tubes for this transition
                    ellBndInv111 = [];  ellBnd111 = [];
                    count1 = 0;
                    for ii = 1:size(funnel,1)
                        if ~isempty(funnel{ii,itrans})
                            count1 = count1+1;
                            for j = 1:length(funnel{ii,itrans}.t)
                                ellBndInv111{count1,1}(j,1).x = funnel{ii,itrans}.x(j,:)';
                                ellBndInv111{count1,1}(j,1).P = funnel{ii,itrans}.P(:,:,j)/funnel{ii,itrans}.rho(j);  % <-- assume rho is constant (here only)
                            end
                        end
                    end
                end
                
                Isect{itrans} = [];
                
                % clear entries in ellFunnel for current transition
                %                     if k2 == 1
                %                         for mm = 1:size(funnel,1)
                %                             ellFunnel{mm,itrans} = [];
                %                             funnel{mm,itrans} = [];
                %                         end
                %                     end
                
                goodIndx = [];
                
                % ellFunnel{:,itrans} = [];  % Clear the reach tube for the current transition
                trial1 = 1;
                if k2 == 1
                    try
                        disp('Computing final point....')
                        finalPt = getCenterRand(vReg{aut.q{aut.trans{itrans}(2)}},vAvoid2,vBnd{1},[],[],Hout,n,limsNonRegState,'rand',Qrand);  % Get final point
                        finalPt
                        if isempty(finalPt)
                            error('getRandom1: Cannot obtain a point.')
                        end
                        goalOutput = finalPt(1:length(Hout))*Hout;
                        pathTmp.q = [initOutput; goalOutput];
                        [t,Xk,Uk] = genNominalTrajectory(initState,pathTmp.q,Hout,n,isCyclic,modelType);
                        [~,redindx] = downsampleUniformly(t,sampSkipColl);
                        xRed = Xk(redindx,:);
                        disp('Simulating trajectory....')
                        isect = checkIntersection(vAvoid,vBnd{:},[],Xk,Hout);
                        goodIndx = [];
                    catch error
                        rethrow(error)
                        isect = true;
                    end
                    trial2 = 1;
                    if ~(~isect && length(t) > 1 && length(t) < 300)
                        for trial2 = 1:maxTrials2
                            if debugFlg
                                trial2
                            end
                            disp('Trajectory incompatible with constraints; recomputing...')
                            try
                                disp('... Computing final point....')
                                [finalPt,hindx] = getRandom2(vReg{aut.q{aut.trans{itrans}(2)}},vAvoid2,[],[],'discrep',[],hindx,Hout,n,limsNonRegState,isCyclic);  % Give up on trying to have a nice compact set; randomly select the final point
                                finalPt
                                if isempty(finalPt)
                                    error('getRandom1: Cannot obtain a point.')
                                end
                                goalOutput = finalPt(1:length(Hout))*Hout;
                                pathTmp.q = [initOutput; goalOutput];
                                [t,Xk,Uk] = genNominalTrajectory(initState,pathTmp.q,Hout,n,isCyclic,modelType);
                                [~,redindx] = downsampleUniformly(t,sampSkipColl);
                                xRed = Xk(redindx,:);
                                disp('Simulating trajectory....')
                                isect = checkIntersection(vAvoid,vBnd{:},[],Xk,Hout);
                                goodIndx = [];
                            catch error
%                                 rethrow(error)
                                isect = true;
                            end
                            if ~isect && length(t) > 1 && length(t) < maxTrajLength,
                                break,
                            end
                        end
                    end
                    if trial2 == maxTrials2
                        funFail = true;
                        %                             error('Cannot find a feasible trajectory for this mode. Consider increasing the tree depth.')
                    else
                        funFail = false;
                    end
                    
                else  % create sequentially-composable reach tubes
                    % TODO: debug this ELSE statement
                    try
                        for trial1 = 1:maxTrials1
                            [finalPt,hindx] = getRandom2(vReg{aut.q{iModeToPatch}},vAvoid1,ellBndInv111,[],'discrep','inside',hindx,Hout,n,limsNonRegState,isCyclic);  % Get final point
                            goalOutput = finalPt(1:length(Hout))*Hout;
                            % TODO: ensure each final funnel ellipse is contained inside the transition reach tube
                            for nonRegTrial = 1:maxNonRegTrials
                                nonRegTrial
                                if k2 == depthTrans;
                                    qCenter = [];
%                                     if size(find(transTmp(:,2)==iModeToPatch)') - size(find(transTmp(:,1)==iModeToPatch && transTmp(:,2)==iModeToPatch)') == 1 % only one incoming edge not counting self-loops
%                                         if ~isempty(find(transTmp(:,2)==iModeToPatch)) % valid predecessor exists
%                                             qCenter = finalPtMode{find(transTmp(:,2)==iModeToPatch)'};
%                                         end
%                                     end
                                    [initState] = getCenterRand(vReg{aut.q{iModeToPatch}},vAvoid1,vBnd{1},[],[],Hout,n,limsNonRegState,'rand',Qrand,qCenter);
                                else
                                    [initState,hindx] = getRandom2(iModeToPatch,vAvoid1,[],[],'discrep',[],hindx,Hout,n,limsNonRegState,isCyclic);  % Get initial point
                                end
                                initState
                                if isempty(initState)
                                    disp('getRandom1: Cannot obtain an initial point.')
                                    error('getRandom1: Cannot obtain an initial point.')
                                end
                                initOutput = initState(1:length(Hout))*Hout;
                                pathTmp.q = [initOutput; goalOutput];
                                if ~isempty(pathTmp.q)
                                    [t,Xk,Uk] = genNominalTrajectory(initState,pathTmp.q,Hout,n,isCyclic,modelType);
                                    redindx = 1:length(t);
                                    [isectNonReg] = checkIntersection4(ellBndInv111,Xk(end,:),Hout,n,isCyclic);
                                    if ~isectNonReg && length(t) > 1 && length(t) < 300, break, end
                                end
                            end
                            isect = checkIntersection(vAvoid,vBnd{:},[],Xk,Hout);
                            goodIndx = [];
                            if ~isect && length(t) > 1 && length(t) < 300, break, end
                        end
                    catch error
                        rethrow(error)
                        isect = true;
                    end
                    if trial1 == maxTrials1 || nonRegTrial == maxNonRegTrials
                        funFail = true;
                        %                             error('Cannot find a feasible trajectory for this mode. Consider increasing the tree depth.')
                    else
                        funFail = false;
                    end
                end
                
                if ~funFail
                    if trial1 == maxTrials1 && trial2 == maxTrials2
                        error('Cannot construct a reach tube for the current transition.')
                    end
                    
                    tsav = t;
                    disp('Computing funnel....')
                    
                    chopIfInfeas = true;
                    try % to deal with spurious cases where PinvTmp in computeFunnel is not psd.
                        % TODO: separate into two trajectories -- with the split occurring in the "gamma" zone.
                        clear tR1 XkR1 UkR1
                        [tR1,XkR1,UkR1] = deal(t,Xk,Uk);
                        %                         initRhoConst1 = 1e-5;
                        %                         initRhoConst2 = 1e-5;
                        Qf = 20*eye(n);
                        if chopIfInfeas
                            disp('   infeasible: chopping...')
                            [funnelIR1,rhoMinR1,rho_dR1,infoR1,redindxR1] = computeFunnelByDrakeRecursive(tR1,UkR1,XkR1,Qf,sampSkipFun);
                        else
                            [funnelIR1,rhoMinR1,rho_dR1,infoR1,redindxR1] = computeFunnelByDrake(tR1,UkR1,XkR1,Qf,sampSkipFun);
                        end
                        %                         [funnelIR1,rhoMinR1,rho_dR1,infoR1,redindxR1] = computeFunnel(f0,tR1,XkR1,UkR1,S0,Q,R,Hout,n,isCyclic,sampSkipFun,regBnd,regX{itrans},regAvoid);
                        %                         [funnelIR2,rhoMinR2,rho_dR2,infoR2,redindxR2] = computeFunnel(f0,tR2,XkR2,UkR2,S0,Q,R,Hout,n,isCyclic,sampSkipFun,regBnd,regX{itrans},regAvoid);
                        [funnelI,rhoMin,rho_d,info,redindx] = deal(funnelIR1,rhoMinR1,rho_dR1,infoR1,redindxR1);
                        
                        % Check if the funnel is misbehaving
                        if sum(rho_d < 1e9) > 3 && sum(rho_d == 1e9) < 5 && min(rho_d(rho_d < 1e9)) < 1e3 && rhoMin ~= 1e9 || max(rho_d) <= 1e-6
                            funFail = false;
                        else
                            funFail = true;
                        end
                    catch ERR
                        rethrow(ERR)
                        funFail = true;
                    end
                    
                    if ~funFail
                        isectBnd = false;
                        for j = 1:sampSkipValid:size(funnelI.x,1)
                            tmp = inv(funnelI.P(:,:,j));
                            tmp = (tmp+tmp')/2;
                            E1 = ellipsoid(funnelI.x(j,:)',tmp*funnelI.rho(j));
                            E = projection(E1,[Hout; zeros(n-length(Hout),length(Hout))]);
                            figure(5)
                            axis([min(regBnd{1}.v(:,1)) max(regBnd{1}.v(:,1)) min(regBnd{1}.v(:,2)) max(regBnd{1}.v(:,2))])
                            plot(E)
                            if any(intersect(E,regX{itrans}.hExtB))
                                isectBnd = true;
                                break
                            end
                            if ~isempty(double(regX{itrans}.pIntB))
                                if any(intersect(E,regX{itrans}.pIntB2))
                                    isectBnd = true;
                                    break
                                end
                            end
                        end
                        if ~isectBnd && max(rho_d) > 1e-6
                            funFail = false;
                        else
                            funFail = true;
                        end
                    end
                end
                
                if funFail     % Need to repeat this iteration
                    % Optional: plot the failed result
                    if exist('Xk')
                        figure(5)
                        plot(Xk(:,1),Xk(:,2),'k','LineWidth',2)
                        drawnow
                        %                         figure(6)
                        %                         ellArrayCurr = [];
                        %                         indxSet = 1:1:size(funnelI.x,1);
                        %                         for j = indxSet
                        %                             tmp = inv(funnelI.P(:,:,j));
                        %                             tmp = (tmp+tmp')/2;
                        %                             E1 = ellipsoid(funnelI.x(j,:)',tmp*rhoMin);
                        %                             E = projection(E1,[Hout; zeros(n-length(Hout),length(Hout))]);
                        %                             ellArrayCurr = [ellArrayCurr; E1];
                        %                         end
                        %                         clear pAvoid
                        %                         plot(projection(ellArrayCurr,[Hout; zeros(n-length(Hout),length(Hout))]))
                        %                         plot(Xk(:,1),Xk(:,2),'m','LineWidth',2)
                    end
                    
                    break
                end
                
                t = tsav;  % to protect t - it's being overwritten as an mss symbol (why?!?)
                figure(3)
                plot(Xk(:,1),Xk(:,2),'k','LineWidth',2)
                
                figure(4)
                ellArrayCurr = [];
                if debugFlg
                    indxSet = 1:1:size(funnelI.x,1);
                else
                    clear redindxFun
                    for j = 1:length(redindx)
                        redindxFun(j) = find(abs(funnelI.t - t(redindx(j))) == min(abs(funnelI.t - t(redindx(j)))));
                    end
                    indxSet = redindxFun;
                end
                for j = indxSet
                    Psav(:,:,j) = funnelI.P(:,:,j);%Ps{j};
                    Ksav(:,:,j) = funnelI.K(:,:,j);%Ks{j};
                    tmp = inv(funnelI.P(:,:,j));
                    tmp = (tmp+tmp')/2;
                    E1 = ellipsoid(funnelI.x(j,:)',tmp*funnelI.rho(j));
                    E = projection(E1,[Hout; zeros(n-length(Hout),length(Hout))]);
                    ellArrayCurr = [ellArrayCurr; E1];
                end
                
                plot(projection(ellArrayCurr,[Hout; zeros(n-length(Hout),length(Hout))]))
                drawnow
                %         figure(7)
                %         plot(ellArrayCurr)
                
                i1 = i + (k2-1)*maxFunnelsTrans(iModeToPatch);
                funnel{i1,itrans} = funnelI;
                rhoMinArray{i1,itrans} = funnelI.rho;
                ellFunnel{i1,itrans} = ellArrayCurr;
                trajFunnel{i1,itrans} = funnelI.x;
                
                IsectTrans{i1,itrans} = isinternal_quick(ellFunnel{i1,itrans},qCover{iModeToPatch}');
                
                finalPtMode{iModeToPatch} = funnelI.x(end,:);
                
                disp(['Iteration #',num2str(i),' / ',num2str(maxFunnelsTrans(iModeToPatch))])
            end
            
            if ~funFail,
                if i == maxFunnelsTrans(iModeToPatch)
                    break
                end
                i = i+1;
            end
            disp(['    iteration #: ',num2str(i)]);
            
        end
        
        if ~funFail,
            break
        end
    end
    
    if funindx == maxFunTrials
        error('Cannot find feasible funnels for this mode. Consider increasing the tree depth.')
    end
end

