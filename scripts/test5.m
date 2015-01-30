
joinedModes = false*ones(Nmodes,1);  % keep a list of modes which need joining
reactJoinedModes = false*ones(Nmodes,1);

for imode = 1:Nmodes
    patchedAndUnvistedModesToJoin = ~(joinedModes(1:imode) & reactJoinedModes(1:imode));
    
    for iJoinTry = 1:10  % max number of tries
        for iModeToJoin = find(patchedAndUnvistedModesToJoin)'  % recursively patch successor modes, if necessary
            disp(['... Attempting to join mode ',num2str(iModeToJoin)])
             %% Join Operation
            if iJoinTry == 1, joinedModes = [1;1;0;0]; end
            
            if joinedModes(iModeToJoin)
                disp(['... Successfully joined mode ',num2str(iModeToJoin),'. Now attempting to reactively join this mode.'])
                %% Reactive Join Operation
                for iReactTry = 1:10
                    if iJoinTry == 1, reactJoinedModes = [1;0;0;0]; end
                    if reactJoinedModes(iModeToJoin), break, end
                end
            end
            
            if ~joinedModes(iModeToJoin) || ~reactJoinedModes(iModeToJoin)
                disp(['... Failed to join or reactively join mode ',num2str(iModeToJoin),'. Need to re-patch.'])
                break
            end
        end
        if ~joinedModes(imode) || ~reactJoinedModes(imode)       
            keyboard
            % update the list of modes which have already been joined but are affected by the patch and concatenate with the list of unvisited modes
            patchedAndUnvistedModesToJoin = find(~(joinedModes(iModeToJoin:imode) & reactJoinedModes(iModeToJoin:imode))) + (iModeToJoin-1);  % everything left on the todo list
            patchedAndUnvistedModesToJoin = [setdiff(transTmp(transTmp(:,1)==iModeToJoin,2),imode+1:Nmodes); patchedAndUnvistedModesToJoin];  % every successor to the current mode which had been joined
            if ~joinedModes(iModeToJoin) 
                patchedAndUnvistedModesToJoin = [setdiff(transTmp(transTmp(:,1)==iPreModeToJoin,2),imode+1:Nmodes); patchedAndUnvistedModesToJoin]; 
                patchedAndUnvistedModesToJoin = [setdiff(iPreModeToJoin,imode+1:Nmodes); patchedAndUnvistedModesToJoin];
            end    
            
            patchedAndUnvistedModesToJoin = unique(patchedAndUnvistedModesToJoin);
            patchedAndUnvistedModesToJoin
            joinedModes = [~ismember(1:imode,patchedAndUnvistedModesToJoin)'; joinedModes(imode+1:Nmodes)];
            reactJoinedModes = [~ismember(1:imode,patchedAndUnvistedModesToJoin)'; reactJoinedModes(imode+1:Nmodes)];
            
            %% Patch Operation
            disp(['... Patching the failed current mode (mode ',num2str(iModeToJoin),') ...'])
            iModeToPatch = iModeToJoin;
            %reachOp
            %sequenceOp
            
            if ~joinedModes(iModeToJoin)  % if join failed, also patch the pre mode
                disp(['... Also patching the pre-mode (mode ',num2str(iPreModeToJoin),') ...'])
                iModeToPatch = iPreModeToJoin;
                %reachOp
                %sequenceOp
            end
            keyboard
        end
        if all(joinedModes(1:imode) & reactJoinedModes(1:imode))
            break
        end
    end
end