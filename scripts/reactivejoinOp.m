%
% Reactive Join Operation -- join last point of the "gamma"-zone funnels to
% the reactively-composable set
%

reactJoinedThisMode = [];

%hindx = 1e8;  % reset Halton seed
%hindx1 = 1;  % reset Halton seed

% Avoid regions for starting region
% TODO: helper function
[vAvoid1,vAvoid1B,regAvoid1,vAvoid1Bcomp] = deal([]);
count = 0;
for j = 1:length(reg)
    if ~(aut.q{iModeToReactJoin} == j)
        count = count+1;
        vAvoid1{count} = reg{j}.v;
        vAvoid1B{count} = reg{j}.vB;
        regAvoid1{count} = reg{j};
    else
        regSafe{1} = reg{j};
    end
end
% count = 0;
% for j = 1:length(reg)
%     if aut.q{iModeToReactJoin} == j
%         count = count+1;
%         vAvoid1Bcomp{count} = reg{j}.vB;
%     end
% end

% Avoid regions for seeding the initial funnel sample.
% TODO: impose a limit on the size of transition funnels so that at
% least one ellipse fits in between this buffer zone. We'll need to
% check if that ellipse is completely contained by r.c. funnels created
% in this step.
% vAvoidReactInit = vAvoid1;
% for indx = 1:length(vAvoid1Bcomp)
%     vAvoidReactInit{length(vAvoid1)+indx} = vAvoid1Bcomp{indx};
% end

[Vbnd1,ellBndInv11] = deal([]);
% Get transition reach tubes from initial state
count = 0;
% TODO: helper function
for indx = 2%1:length(aut.trans)
    if iModeToReactJoin == aut.trans{indx}(1)  % when isReactive is false, we can ignore both ellCInv11 and ellBndInv11 in funnel construction
        count = count+1;
        count1 = 0;
        for ii = 1:size(funnel,1)
            if ~isempty(funnel{ii,indx})
                count1 = count1+1;
                for j = 1:20%length(funnel{ii,indx}.t)
                    ellBndInv11{count1,count}(j,1).x = funnel{ii,indx}.x(j,:)';
                    ellBndInv11{count1,count}(j,1).P = funnel{ii,indx}.P(:,:,j)/funnel{ii,indx}.rho(j);  % <-- assume rho is constant (here only)
                end
                Vbnd1{count1,count} = ones(size(funnel{ii,indx}.V)) - funnel{ii,indx}.V;
            end
        end
    end
end
% Get inward-directed funnels for the two regions from the
% previous iteration
count1 = 0;
[Vin1,ellCInv1,ellCInv11] = deal([]);
for ii = 1:size(funnelIn,1)
    if ~isempty(funnelIn{ii,iModeToReactJoin})
        count1 = count1+1;
        for j = 1:length(funnelIn{ii,iModeToReactJoin}.t)
            ellCInv11{count1}(j,1).x = funnelIn{ii,iModeToReactJoin}.x(j,:)';
            ellCInv11{count1}(j,1).P = funnelIn{ii,iModeToReactJoin}.P(:,:,j)/funnelIn{ii,iModeToReactJoin}.rho(j);  % <-- assume rho is constant (here only)
        end
        Vin1{count1} = ones(size(funnelIn{ii,iModeToReactJoin}.V)) - funnelIn{ii,iModeToReactJoin}.V;
    end
end

for itrans = find(transTmp(:,1)==iModeToReactJoin)'
    
    [vAvoid,vAvoid2,vAvoidB,vAvoid2B,regAvoid,regAvoid2] = deal([]);
    
    % Get transition reach tubes from final state
    % TODO: helper function
    [ellBnd1,ellBnd2,Vbnd2,ellC2,Vin2,ellBndInv21,ellCInv21,reactEllBndInv21,isectReactZone,isolReactZone] = deal([]);
    count1 = 0;  % a substitute for ii, only considering those which are not empty
    count_i = 0;
    for ii = 1:size(funnel,1)
        if ~isempty(funnel{ii,itrans})
            count1 = count1+1;

            for j = 1:length(funnel{ii,itrans}.t)
                ellBndInv21{count1,1}(j,1).x = funnel{ii,itrans}.x(j,:)';
                ellBndInv21{count1,1}(j,1).P = funnel{ii,itrans}.P(:,:,j)/funnel{ii,itrans}.rho(j);
%                 isectReactZone{count1,1}(j) = ~checkIntersection(vAvoid1,vBnd{:},[],ellBndInv21{count1,1}(j,1).x',Hout);
            end
            %             if ~any(isectReactZone{count1,1}), error('No trajectory points found in the initial region (shouldn''t happen).'), end
            
            % go backwards from final point and isolate only the last set of points
            % which are about to exit the region
            %isolReactZone{count1,1} = zeros(size(isectReactZone{count1,1}));
            %             reactEllBndInv21{count1,1} = [];
            idxToChkReactivity{count1,itrans} = 1;
            for j = length(funnel{ii,itrans}.t):-5:20
                %if j < length(funnel{ii,itrans}.t) && isectReactZone{count1,1}(j) < isectReactZone{count1,1}(j+1), break, end
                %isolReactZone{count1,1}(j) = isectReactZone{count1,1}(j);
                %if isolReactZone{count1,1}(j) ~= 0, reactEllBndInv21{count1,1} = [reactEllBndInv21{count1,1}; ellBndInv21{count1,1}(j,1)]; end
                
                funnelTmp.t = funnel{ii,itrans}.t(j);
                funnelTmp.x = funnel{ii,itrans}.x(j,:);
                funnelTmp.P = funnel{ii,itrans}.P(:,:,j);
                funnelTmp.rho = funnel{ii,itrans}.rho(j);
                if ~checkIntersection(vAvoid1,vBnd{1},[],funnelTmp.x,Hout)
                    if ~chkContainment(funnelTmp,regAvoid1,regSafe,regX{itrans},Hout,n,1)
                        idxToChkReactivity{count1,itrans} = j:-5:20;
                        break
                    end
                end
            end
            
            Vbnd2{count1,1} = ones(size(funnel{ii,itrans}.V)) - funnel{ii,itrans}.V;
            
            for idx = idxToChkReactivity{count1,itrans}(1:end)
                reactEllBndInv21{1,1} = ellBndInv21{count1,1}(idx,1);
                reactEllBndInv21_sav{count1,itrans} = reactEllBndInv21{1,1};
                reactIdx_sav{count1,itrans} = idx;
                
                for i = 1:maxFunnelsReactJoin(iModeToReactJoin)
                    count_i = count_i+1;
                    
                    disp('... Computing initial point inside the transition funnel and within gamma of the boundary ....')
                    initState = [];
                    initCount = 0;
                    while isempty(initState)
                        initState = getRandom2(vReg{aut.q{iModeToReactJoin}},vAvoid1,reactEllBndInv21,[],'discrep','inside',hindx1,Hout,n,limsNonRegState,isCyclic);  % initial point is the final point of the transition funnel
                        % if initState(1)<1
                        % initState = [];
                        % end
                        initCount = initCount+1;
                        if initCount >= 5
                            initState = funnel{ii,itrans}.x(idx,:);
                            disp('using center of ellipse-- funnel may be narrow')
                            break
                        end
                    end
                    initState
                    initOutput = initState(1:length(Hout))*Hout;
                    
                    % (not yet used):
                    %         ellBndInv12.x = funnel{i,itrans}.x(end,:)';
                    %         ellBndInv12.P = funnel{i,itrans}.P(:,:,end)/funnel{i,itrans}.rho(end);
                    
                    funFail = true;
                    if checkIntersection4(ellBndInv11,initState,Hout,n,isCyclic) || checkIntersection4(ellCInv11,initState,Hout,n,isCyclic) % if an inward funnel happens to succceed, then flag as successful without creating a conduit
                        for funindx = 1:maxFunTrials
                            funindx
                            % while funFail
                            
                            for trial3 = 1:maxTrials3
                                try
                                    disp('... Computing final point....')
                                    finalPt = [];
                                    while isempty(finalPt)
                                        [finalPt,hindx1] = getRandom2(vReg{aut.q{iModeToReactJoin}},vAvoid,ellBndInv11,ellCInv11,'discrep','inside',hindx1,Hout,n,limsNonRegState,isCyclic);  % Get a final point inside the existing outgoing funnels
                                    end
                                    %                             finalPt = ellBndInv11{count1,1}(1,1).x';
                                    goalOutput = finalPt(1:length(Hout))*Hout;
                                    goalOutput
                                    pathTmp.q = [initOutput; goalOutput];
                                    disp('... Simulating trajectory ....')
                                    %[t,Xk,Uk] = genNominalTrajectory(initState,pathTmp.q,Hout,n,isCyclic,modelType);
                                    stepSize = 1.0;
                                    [path] = buildCtrlSpaceRRT(vBnd{:},vAvoid1,[],ellBndInv11,[],ellCInv11,[],initState,finalPt,stepSize,Hout,n,isCyclic,modelType);
                                    if ~isempty(path)
                                        t = path.t;
                                        Xk = path.x;
                                        Uk = path.u;
                                        if ~isempty(t)
                                            isect = checkIntersection(vAvoid,vBnd{:},[],Xk,Hout);
                                            [isectFinal] = checkIntersection4(ellBndInv11,Xk(end,:),Hout,n,isCyclic);
%                                             if isectFinal == 0
%                                                 keyboard
%                                             end
                                        else
                                            isect = true;
                                            isectFinal = true;
                                        end
                                    else
                                        isect = true;
                                        isectFinal = true;
                                    end
                                catch error
                                    rethrow(error)
                                    isect = true;
                                end
                                if ~isect && ~isectFinal && length(t) < maxTrajLength,
                                    funFail = false;
                                    break,
                                end
                            end
%                             if trial3 == maxTrials3
%                                 funFail = true;
%                                 %                             error('Cannot find a feasible trajectory for this mode. Consider increasing the tree depth.')
%                             else
%                                 funFail = false;
%                             end
                            
                            if ~funFail
                                disp('... Computing funnel....')
                                
                                chopIfInfeas = true;
                                try % to deal with spurious cases where PinvTmp in computeFunnel is not psd.
                                    % TODO: separate into two trajectories -- with the split occurring in the "gamma" zone.
                                    Qf = 60*eye(n);
                                    if chopIfInfeas
                                        [funnelI,rhoMin,rho_d,info,redindx] = computeFunnelByDrakeRecursive(t,Uk,Xk,Qf,sampSkipFun);
                                    else
                                        error('not implemented')
%                                         Q = @(t) 1e-4*diag([1 1 1]);
%                                         [funnelI,rhoMin,rho_d,info,redindx] = computeFunnel(f0,t,Xk,Uk,S0,Q,R,Hout,n,isCyclic,sampSkipFun,regBnd,reg{aut.q{iModeToReactJoin}},regAvoid1,[],[],[],[],[],ellBndInv11);
                                    end
                                    
                                    %TODO: check if mouth of join funnel doesn't contain the outlet of the inward funnel
                                    
                                    % Check if the funnel is misbehaving
                                    if sum(rho_d < 1e9) > 1 && sum(rho_d == 1e9) < min(5,length(t)) && rhoMin ~= 1e9 || max(rho_d) <= 1e-6
                                        funFail = false;
                                    else
                                        funFail = true;
                                    end
                                    
                                catch ERR
                                    %                         rethrow(ERR)
                                    funFail = true;
                                end
                                
                                if ~funFail
                                   isectBnd = chkContainment(funnelI,regAvoid1,regSafe,regX,Hout,n,sampSkipValid);
                                   if ~isectBnd && max(rho_d) > 1e-6
                                       funFail = false;
                                   else
                                       funFail = true;
                                   end
                                end
                            end
                            
                            if ~funFail,
                                break
                            end
                        end
                        
                        if ~funFail
                            figure(3)
                            plot(Xk(:,1),Xk(:,2),'m','LineWidth',2)
                            
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
                            clear pAvoid
                            %         for mm = 1:length(vAvoid1), pAvoid(mm) = polytope(vAvoid1{mm}); end
                            %         isect = intersect(projection(ellArrayCurr,[Hout; zeros(n-length(Hout),length(Hout))]),pAvoid,'u')
                            %         if ~any(isect)
                            plot(projection(ellArrayCurr,[Hout; zeros(n-length(Hout),length(Hout))]))
                            drawnow
                            
                            funnelReactJoin{count_i,itrans} = funnelI;
                            rhoMinArrayReactJoin{count_i,itrans} = funnelI.rho;
                            ellFunnelReactJoin{count_i,itrans} = ellArrayCurr;
                            trajFunnelReactJoin{count_i,itrans} = funnelI.x;
                            
                            % check for coverage
                            ellArray = [];
                            for j = 1:length(funnelI.t)
                                tmp = inv(funnelI.P(:,:,j));
                                tmp = (tmp+tmp')/2;
                                E1 = ellipsoid(funnelI.x(j,:)',tmp*funnelI.rho(j));
                                ellArray = [ellArray; E1];
                            end
                            ellBndReact{count_i,1} = ellArray;  % for all reactive funnels found so far for this transition
                            tmp = inv(reactEllBndInv21{1,1}.P);
                            Q = (tmp+tmp')/2;
%                             [xbar,Q] = double(E);  % ellipse #idx in this transition funnel
                            qTest = ellipsoidrand(reactEllBndInv21{1,1}.x,Q,100);
                            clear badIndx isectReact
                            [isectReact,badIndx] = checkIntersection5(regBnd{1}.v,vReg,ellBndReact,[],qTest,Hout,n,isCyclic);
                            
                            if ~isectReact % success - the funnels found so far enclose the ellipse #idx of the transition funnel
                                break  % break the maxFunnelsReactJoin(imodeToJoin) for loop
                            end
                        else % we've exceeded the number of trial iterations; break and decrement idx.
                            isectReact = true;
                            break
                        end
                    end
                end % for i = 1:maxFunnelsReactJoin(imodeToJoin)
                
                if ~isectReact % success!
                    disp(['Iteration #',num2str(i),' / ',num2str(maxFunnelsReactJoin(iModeToReactJoin))])
                    reactJoinedThisMode = [reactJoinedThisMode; true]
                    break
                end
            end % for idx = idxToChkReactivity{count1,itrans}
            
            if idx == 1 && isectReact
                reactJoinedThisMode = [reactJoinedThisMode; false]
            end
        end
    end
end

if all(reactJoinedThisMode)
    reactJoinedModes(iModeToReactJoin) = true  % succeeded for all funnels for each incoming transition to this mode
else
    reactJoinedModes(iModeToReactJoin) = false
end