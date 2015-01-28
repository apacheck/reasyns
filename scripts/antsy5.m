%
% ReaSyNS - REActive SYnthesis for Nonlinear Systems
%

% TODO:
% 1. Separate transition funnel generation into two parts to enforce
% containment by the critical reactive funnel -- also #7 below
% 2. Join/Reactive Join operations: check if constructed funnels are big
% enough to contain final set of the incoming funnel
% 3. Transition funnels are entering avoid regions by more than 0.1
% 4. Rare events where RRT doesn't obey dynamics
% 5. Better way of declaring RRT finished so that we end up with final
% point more inside the goal set (thus widening the join/reactive join
% funnels)
% 6. Non-critical reactive join
% 7. Cases where the mouth of critical reactive funnels come BEFORE the
% tail of sequenced funnels
% 8. NEED A FUNNEL CLASS STRUCTURE!!


clear funnel funnelIn ellFunnel ellFunnelIn ellInit trans error

warning off

format compact
clear all
close all
global xyPath x debugFlg l TstepTraj

set(0, 'DefaultFigureRendererMode', 'manual')
set(0,'DefaultFigureRenderer','zbuffer')

clk = fix(clock);
fid = fopen(['reasyns_log_',date,'_',num2str(clk(4)),num2str(clk(5)),num2str(clk(6)),'.txt'],'w');


TstepTraj = 0.02;
maxTrajLength = 10/TstepTraj; % 10 seconds; otherwise we're probably spiraling

clear t Xk
ellFunnel = [];
ellFunnelIn = [];
funnel = [];
funnelIn = [];

% load antsy4_urbanDelivery_uni

% Model parameters
Hout = eye(2);

modelType = 'unicycle';

switch modelType
    
    case 'unicycle'
        f0 = @(t,x,u) CreateKinematicsPoly(t,x,u);
        n = 3;
        
        limsNonRegState = [-pi; pi];
        isCyclic = [0 0 1]';
        
        % LQR controller parameters
%         S0 = 1e4*eye(n);   % Qf in terminal cost
%         Q = @(t) 1e0*diag([100 100 0.0001]);
%         % R = @(t) 1e2*eye(2);
%         R = @(t) diag([1e4 1e2]);

        S0 = 1e-4*eye(n);   % Qf in terminal cost
        Q = @(t) 1e-4*diag([1 1 1]);
        % R = @(t) 1e2*eye(2);
        R = @(t) diag([1e-5 1e-6]);% @(t) diag([1e4 1e-6]);
        
    case 'car'
        f0 = @(t,x,u) CarKinematicsPoly(t,x,u);
        n = 4;
        
        limsNonRegState = [-pi -pi/2; pi pi/2]; % for a car-like robot
        isCyclic = [0 0 1 0]';
        
        % LQR controller parameters
        S0 = 1e4*eye(n);   % Qf in terminal cost
        Q = @(t) 1e0*diag([1000 1000 10 10]);
        % R = @(t) 1e2*eye(2);
        R = @(t) diag([1e3 1e2]);
end

debugFlg = false;

% Get map and transitions
% inspectionTaskMap
% inspectionTaskMap_noshortcut
% gotoStay2regionsMap
% gotoStay3regionsMap
threeRegionMap
% threeRegionMap_forTesting
% fourRegionMap
% urbanDelivery
% pursuerEvaderMap

Qrand = 2;

Ncover = 10000;
Nterm = 10;  % number of consecutive failures before coverage terminates
coverPct = 0.8;

Ntrans = length(aut.trans);
Nmodes = length(aut.q);

% Number of funnels/controllers for each state
maxFunnelsTrans(1:Nmodes) = 1;
% maxFunnelsInward(1:Nmodes) = [0 2 0 0]; % for threeRegionMap
% maxFunnelsInward(1:Nmodes) = [3 0 0];
maxFunnelsInward(1:Nmodes) = zeros(1,Nmodes);
maxFunnelsReactJoin(1:Nmodes) = 10;

% Tree depth
depthTrans = 1;
depthInward = 1;

% Downsampling
sampSkipColl = 5;  % skipped samples in collision check -- higher value speed up collision checks but may miss parts of the trajectory
sampSkipFun = 3;  % skipped samples in funnel computation
sampSkipValid = 5;  % skipped samples in misbehavior check

maxFunTrials = 40;  % number of tries before giving up
maxTrials1 = 30; % set to a high value
maxTrials2 = 20;
maxTrials3 = 2;  % set to a low value because funFail takes care of final point interations.
maxNonRegTrials = 30;

% for state = 1:Ntrans
%     initState = getRandom(vReg{state},'discrep');
%     regPoint{state} = initState;
% end
% regPoint{state+1} = regPoint{1};  %close the loop

for imode = 1:Nmodes
    qReg = aut.q{imode};
    qCover{imode} = getCoverPts(vReg,{qReg},1,Ncover,Hout,n,limsNonRegState);
    finalPtMode{imode} = [];
end

figure(5)
axis([min(regBnd{1}.v(:,1)) max(regBnd{1}.v(:,1)) min(regBnd{1}.v(:,2)) max(regBnd{1}.v(:,2))])


%%  Main

tic

plotWS(pReg)

countReach = 0;
iModeToPatch = 0;
% while countReach < 20 && iModeToPatch ~= Nmodes
for j = 1:Ntrans
    for i = 1:max(maxFunnelsTrans(aut.trans{j}(1)),size(funnel,1))
        funnel{i,j} = [];
        rhoMinArray{i,j} = [];
        ellFunnel{i,j} = [];
        trajFunnel{i,j} = [];
        IsectTrans{i,j} = [];
    end
end
for j = 1:Nmodes
    for i = 1:max(maxFunnelsInward(j),size(funnelIn,1))
        funnelIn{i,j} = [];
        rhoMinArrayIn{i,j} = [];
        ellFunnelIn{i,j} = [];
        trajFunnelIn{i,j} = [];
    end
%     if isReactive(j) && maxFunnelsInward(j) == 0
%         error('Reactive join requires at least one inward funnel')
%     end
end

%%
NmodesReach = Nmodes;
% NmodesReach = 1;

tic
toc
fprintf(fid,'%f : Starting ....\n',toc);
for iModeToPatch = 1:NmodesReach
    %% Reach Operation
    reachOp
    if countReach >= 20
        break
    end
    toc
    fprintf(fid,'%f : Finished Reach operation for mode %d.\n',toc,iModeToPatch);
    
    %% Sequence Operation
    sequenceOp
    fprintf(fid,'%f : Finished Sequence operation for mode %d.\n',toc,iModeToPatch);
    
end
% end
toc
fprintf(fid,'%f : Finished Reach operation for all modes. Now performing Join operation.\n',toc)

save test

%%
joinedModes = false*ones(Nmodes,1);  % keep a list of modes which need joining

%%
for imode = 1:NmodesReach
    patchedAndUnvistedModesToJoin = ~(joinedModes(1:imode));
    
    for iJoinTry = 1:10  % max number of tries
        for iModeToJoin = find(patchedAndUnvistedModesToJoin)'  % recursively patch successor modes, if necessary
            disp(['... Attempting to join mode ',num2str(iModeToJoin)])
            toc
            fprintf(fid,'%f : Attempting to join mode %d.\n',toc,iModeToJoin);
             % Join Operation
            joinOp
            
            
            if ~joinedModes(iModeToJoin)
                disp(['... Failed to join mode ',num2str(iModeToJoin),'. Need to re-patch.'])
                toc
                fprintf(fid,'%f : Failed to join mode %d. Re-performing the Reach operation\n',toc,iModeToJoin);
                break
            else
                toc
                fprintf(fid,'%f : Successfully joined mode %d.\n',toc,iModeToJoin);
            end
        end
        if ~joinedModes(imode) 
            % update the list of modes which have already been joined but are affected by the patch and concatenate with the list of unvisited modes
            patchedAndUnvistedModesToJoin = find(~(joinedModes(iModeToJoin:imode))) + (iModeToJoin-1);  % everything left on the todo list
            patchedAndUnvistedModesToJoin = [setdiff(transTmp(transTmp(:,1)==iModeToJoin,2),imode+1:Nmodes); patchedAndUnvistedModesToJoin];  % every successor to the current mode which had been joined
            if ~joinedModes(iModeToJoin) 
                patchedAndUnvistedModesToJoin = [setdiff(transTmp(transTmp(:,1)==iPreModeToJoin,2),imode+1:Nmodes); patchedAndUnvistedModesToJoin];
                patchedAndUnvistedModesToJoin = [setdiff(iPreModeToJoin,imode+1:Nmodes); patchedAndUnvistedModesToJoin];
            end    
            
            patchedAndUnvistedModesToJoin = unique(patchedAndUnvistedModesToJoin);
            patchedAndUnvistedModesToJoin
            joinedModes = [~ismember(1:imode,patchedAndUnvistedModesToJoin)'; joinedModes(imode+1:Nmodes)];
            
            % Patch Operation
            disp(['... Patching the failed current mode (mode ',num2str(iModeToJoin),') ...'])
            toc
            fprintf(fid,'%f : Patching the failed current mode %d.\n',toc,iModeToJoin);
            iModeToPatch = iModeToJoin;
            reachOp
            toc
            fprintf(fid,'%f : ... Finished Reach operation for mode %d.\n',toc,iModeToJoin);
            sequenceOp
            fprintf(fid,'%f : ... Finished Sequence operation for mode %d.\n',toc,iModeToJoin);
            
            if ~joinedModes(iModeToJoin)  % if join failed, also patch the pre mode
                disp(['... Now patching the pre-mode (mode ',num2str(iPreModeToJoin),') ...'])
                toc
                fprintf(fid,'%f : Now Patching the pre-mode %d to the failed mode (%d).\n',toc,iPreModeToJoin,iModeToJoin);
                iModeToPatch = iPreModeToJoin;
                reachOp
                toc
                fprintf(fid,'%f : ... Finished Reach operation for pre-mode %d.\n',toc,iPreModeToJoin);
                sequenceOp
                fprintf(fid,'%f : ... Finished Sequence operation for pre-mode %d.\n',toc,iPreModeToJoin);
            end
        end
        if all(joinedModes(1:imode))
            break
        end
    end
end
toc
fprintf(fid,'%f : Finished Join operation for all modes. Now performing Reactive Join operation.\n',toc);

save test_joined

%%
reactJoinedModes = false*ones(Nmodes,1);

for iModeToReactJoin = unique(transTmp(isReactive,1))'
    disp(['... Attempting to reactively join the mode ',num2str(iModeToReactJoin),'.'])
    % Reactive Join Operation
    for iReactTry = 1:10
        reactivejoinOp
        if reactJoinedModes(iModeToReactJoin), break, end
        toc
        fprintf(fid,'%f : ... Reactive Join operation failed for mode %d.  Retrying... (%d)\n',toc,iModeToReactJoin,iReactTry);
    end
    toc
    fprintf(fid,'%f : Finished Reactive Join operation for mode %d.\n',toc,iModeToReactJoin);
end
toc
fprintf(fid,'%f : Finished Reactive Join operation for all modes. Success!\n',toc);


%%
clk = fix(clock);
if strcmp(modelType,'unicycle')
    eval(['save antsy5_uni_',date,'_',num2str(clk(4)),num2str(clk(5)),num2str(clk(6))])
elseif strcmp(modelType,'car')
    eval(['save antsy5_car_',date,'_',num2str(clk(4)),num2str(clk(5)),num2str(clk(6))])
end

toc
fclose(fid);
