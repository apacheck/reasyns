
close all
clc

clear M

global Xk Uk K t

load threeregions_10-8-14

vidObj = VideoWriter('threeregions.avi');
set(vidObj,'FrameRate',60);
open(vidObj);

% aut.trans(19)=[];
% aut.trans(20)=[];

X0 = funnel{1,1}.x(1,:)' + [0.1;-0.02;0];

tt = [];  Xt = [];

figure(101)
clf
hold on
axis equal
set(gcf,'RendererMode','manual','Renderer','OpenGL');

vBndMin = min(vBnd{:});  vBndMax = max(vBnd{:});

set(gca,'FontSize',12)
set(gcf,'Position',[0 0 1280 720])
xlabel('x_r'); ylabel('y_r'); zlabel('\theta')

color = {'y','g','y','b','y','b','y','b','y',[0.1 0.1 0.1],[0.1 0.1 0.1],[0.1 0.1 0.1],[0.1 0.1 0.1],[0.1 0.1 0.1],[0.1 0.1 0.1],[0.1 0.1 0.1],[0.1 0.1 0.1]};
Options.shade = 0.5;
hold on
for j = 1:length(pReg)
    Options.color = color{j};
    H=plot(pReg{j},Options);
    if any(j==[2])
        set(H,'ZData',-10*ones(size(get(H,'XData'))))
    else
        set(H,'FaceAlpha',1)
        set(H,'ZData',-5*ones(size(get(H,'XData'))))
    end
end

plot([vBndMin(1) vBndMin(1)],[vBndMin(2) vBndMax(2)],'k--','LineWidth',2,'Color',[0.5 0.5 0.5])
plot([vBndMin(1) vBndMax(1)],[vBndMin(2) vBndMin(2)],'k--','LineWidth',2,'Color',[0.5 0.5 0.5])
plot([vBndMax(1) vBndMax(1)],[vBndMin(2) vBndMax(2)],'k--','LineWidth',2,'Color',[0.5 0.5 0.5])
plot([vBndMin(1) vBndMax(1)],[vBndMax(2) vBndMax(2)],'k--','LineWidth',2,'Color',[0.5 0.5 0.5])

plot([vReg{1}(2,1) vReg{1}(3,1)],[vReg{1}(2,2) vReg{1}(3,2)],'k--','LineWidth',2,'Color',[0.5 0.5 0.5])
plot([vReg{1}(3,1) vReg{1}(4,1)],[vReg{1}(3,2) vReg{1}(4,2)],'k--','LineWidth',2,'Color',[0.5 0.5 0.5])
% plot([vRegB{1}(2,1) vRegB{1}(3,1)],[vRegB{1}(2,2) vRegB{1}(3,2)],'b:','LineWidth',2)
% plot([vRegB{1}(3,1) vRegB{1}(4,1)],[vRegB{1}(3,2) vRegB{1}(4,2)],'b:','LineWidth',2)
% plot([vRegBN{1}(2,1) vRegBN{1}(3,1)],[vRegBN{1}(2,2) vRegBN{1}(3,2)],'b:','LineWidth',2)
% plot([vRegBN{1}(3,1) vRegBN{1}(4,1)],[vRegBN{1}(3,2) vRegBN{1}(4,2)],'b:','LineWidth',2)

plot([vReg{3}(1,1) vReg{3}(2,1)],[vReg{3}(1,2) vReg{3}(2,2)],'k--','LineWidth',2,'Color',[0.5 0.5 0.5])
plot([vReg{3}(4,1) vReg{3}(1,1)],[vReg{3}(4,2) vReg{3}(1,2)],'k--','LineWidth',2,'Color',[0.5 0.5 0.5])
% plot([vRegB{3}(1,1) vRegB{3}(2,1)],[vRegB{3}(1,2) vRegB{3}(2,2)],'b:','LineWidth',2)
% plot([vRegB{3}(4,1) vRegB{3}(1,1)],[vRegB{3}(4,2) vRegB{3}(1,2)],'b:','LineWidth',2)
% plot([vRegBN{3}(1,1) vRegBN{3}(2,1)],[vRegBN{3}(1,2) vRegBN{3}(2,2)],'b:','LineWidth',2)
% plot([vRegBN{3}(4,1) vRegBN{3}(1,1)],[vRegBN{3}(4,2) vRegBN{3}(1,2)],'b:','LineWidth',2)

text(vReg{1}(1,1)+0.2,vReg{1}(1,2)+0.5,'r_1','FontSize',16)
text(vReg{1}(2,1)+0.2,vReg{1}(1,2)+0.5,'r_2','FontSize',16)
text(vReg{3}(1,1)+0.2,vReg{3}(1,2)+0.5,'r_3','FontSize',16)

% M(1) = getframe;
% writeVideo(vidObj,M(1));

%% 1

itransList = [1 2 4 5 1 3 1];

kiter = 1;
disp('computing trajectory...')
iter = 0;
tend = 0;
minorIter = 1;
foundReactiveX0 = [];
for itrans = itransList;
    iter = iter+1;
    % [~,~,~,~,~,~,~,reg1,reg2,~,~,Xbnd1,Xbnd2,~,~,Xin1,Xin2,ellBnd1,ellBnd2,ellIn1,ellIn2] ...
    %     = getRegionsEllipses(kiter,itrans,aut.trans,reg,funnel,ellFunnel,funnelIn,ellFunnelC);
    [~,~,~,~,~,~,~,reg1,reg2,ellBnd1,ellBnd2,Xbnd1,Xbnd2,ellIn1,ellIn2,Xin1,Xin2] ...
        = getRegionsEllipses(kiter,itrans,aut,reg,funnel,[],funnelIn,[]);

    options.color = [0.2 0.2 0.9];
    figure(101)
    plotFunnelProj(funnel{1,itrans},Hout,options)
    
%     for tidx = 19:length(aut.trans)
%         aut.trans(length(aut.trans))=[];
%     end
    X0
    [XbndR,XinR,tmpV,tmpV1,tmpV2] = getCurrentFunnel(X0,regBnd,reg1,reg2,ellBnd1,ellBnd2,Xbnd1,Xbnd2,ellIn1,ellIn2,Xin1,Xin2);
    XbndR'
    n = itrans;
%     indx = [];
%     for m = 1:size(XbndR,1) % for all transition funnels
%         if ~isempty(XbndR{m,n})
%             indx = [indx;m];
%         end
%     end
%     funIndx = indx(1);
    funIndx = 1;
    [t1{iter},Xk1{iter},t,Xk,funIndx] = getControlledTrajTrans(X0,itrans,kiter,funnel,funIndx,modelType);
    
    X0 = Xk1{iter}(end,:)'
    Xt = [Xt; Xk1{iter}(1:end,:)];
    tt = [tt; t1{iter}(1:end)+tend];
    tend = tt(end);
    
    t01 = t;
    Xk01 = Xk;
    fi1 = funIndx
    
%     figure(1)
%     plot(Xk1{iter}(:,1),Xk1{iter}(:,2),'k')
%     hold on
%     plot(Xk(:,1),Xk(:,2),'r')
%     drawnow
    
    figure(101)
%     plot(Xk1{iter}(:,1),Xk1{iter}(:,2),'k')
    if iter == 7
        t1{iter}(110:end)=[];
        Xk1{iter}(110:end,:)=[];
        X0 = Xk1{iter}(end,:)'
    end
    if iter == 9
        t1{iter}(135:end)=[];
        Xk1{iter}(135:end,:)=[];
        X0 = Xk1{iter}(end,:)'
    end
    if iter == 13
        t1{iter}(140:end)=[];
        Xk1{iter}(140:end,:)=[];
        X0 = Xk1{iter}(end,:)'
    end
    for j = 1:length(t1{iter})
        if iter < 11 | iter > 12
            plot3(Xk1{iter}(j,1),Xk1{iter}(j,2),1,'.','Color',[0.3 0.3 0.3])
        else
            plot3(Xk1{iter}(j,1),Xk1{iter}(j,2),1,'.','Color',[0.9 0.1 0.1])
        end
        H = drawUnicycle(Xk1{iter}(j,:),2);
        M(minorIter) = getframe; writeVideo(vidObj,M(minorIter)); minorIter = minorIter+1;
        delete(H)
    end
    
    options.color = [0.8 0.8 0.8];
    figure(101)
    plotFunnelProj(funnel{1,itrans},Hout,options)
    
    % Join funnels
    iter = iter+1;
    options.color = [0.9 0.2 0.2];
    figure(101)
    plotFunnelProj(funnelJoin{1,itrans},Hout,options)
    
    [t1{iter},Xk1{iter},t,Xk,funIndx] = getControlledTrajTrans(X0,itrans,kiter,funnelJoin,funIndx,modelType);
    
    X0 = Xk1{iter}(end,:)'
    Xt = [Xt; Xk1{iter}(1:end,:)];
    tt = [tt; t1{iter}(1:end)+tend];
    tend = tt(end);
    
%     figure(1)
%     plot(Xk1{iter}(:,1),Xk1{iter}(:,2),'k')
%     hold on
%     plot(Xk(:,1),Xk(:,2),'r')
%     drawnow
    
    figure(101)
%     plot(Xk1{iter}(:,1),Xk1{iter}(:,2),'k')
%     M(minorIter) = getframe;  minorIter = minorIter+1;
    for j = 1:length(t1{iter})
        if iter < 11
            plot3(Xk1{iter}(j,1),Xk1{iter}(j,2),1,'.','Color',[0.3 0.3 0.3])
        else
            plot3(Xk1{iter}(j,1),Xk1{iter}(j,2),1,'.','Color',[0.9 0.1 0.1])
        end
        H = drawUnicycle(Xk1{iter}(j,:),2);
        M(minorIter) = getframe;  writeVideo(vidObj,M(minorIter));  minorIter = minorIter+1;
        delete(H)
    end
    options.color = [0.8 0.8 0.8];
    figure(101)
    plotFunnelProj(funnelJoin{1,itrans},Hout,options)
end

close(vidObj);
% foundReactiveX0 = Xk1{iter}(trajidx,:)';
foundReactiveX0 = funnel{1,16}.x(1,:)';

Xt(end-21:end,:) = [];
tt(end-21:end) = [];


%% 2 - reactive part

tt1 = [];  Xt1 = [];

itransList = [16:18];
X0 = foundReactiveX0;

kiter = 1;
disp('computing trajectory...')
iter = 0;
for itrans = itransList;
    iter = iter+1;
    % [~,~,~,~,~,~,~,reg1,reg2,~,~,Xbnd1,Xbnd2,~,~,Xin1,Xin2,ellBnd1,ellBnd2,ellIn1,ellIn2] ...
    %     = getRegionsEllipses(kiter,itrans,aut.trans,reg,funnel,ellFunnel,funnelIn,ellFunnelC);
    [~,~,~,~,~,~,~,reg1,reg2,ellBnd1,ellBnd2,Xbnd1,Xbnd2,ellIn1,ellIn2,Xin1,Xin2] ...
        = getRegionsEllipses(kiter,itrans,aut,reg,funnel,[],funnelIn,[]);
    
    for tidx = 19:length(aut.trans)
        aut.trans(length(aut.trans))=[];
    end
    X0
    [XbndR,XinR,tmpV,tmpV1,tmpV2] = getCurrentFunnel(X0,regBnd,reg1,reg2,ellBnd1,ellBnd2,Xbnd1,Xbnd2,ellIn1,ellIn2,Xin1,Xin2);
    XbndR'
    n = itrans;
%     indx = [];
%     for m = 1:size(XbndR,1) % for all transition funnels
%         if ~isempty(XbndR{m,n})
%             indx = [indx;m];
%         end
%     end
%     funIndx = indx(1);
    funIndx = 1;
    [t1{iter},Xk1{iter},t,Xk,funIndx] = getControlledTrajTrans(X0,itrans,kiter,funnel,funIndx,modelType);
    
    X0 = Xk1{iter}(end,:)';
    Xt = [Xt; Xk1{iter}(1:end,:)];
    tt = [tt; t1{iter}(1:end)+tend];
    Xt1 = [Xt1; Xk1{iter}(1:end,:)];
    tt1 = [tt1; t1{iter}(1:end)+tend];
    tend = tt(end);
    
    t01 = t;
    Xk01 = Xk;
    fi1 = funIndx
    
    figure(1)
    plot(Xk1{iter}(:,1),Xk1{iter}(:,2))
    hold on
    plot(Xk(:,1),Xk(:,2),'r')
    drawnow
end


%%
figure(101)
plot(Xt(:,1),Xt(:,2),'Color',[0.3 0.3 0.3],'LineWidth',2.5)
plot(Xt1(:,1),Xt1(:,2),'Color',[0.9 0 0],'LineWidth',2.5)

% set(gca, 'Box', 'off' )
% set(gca, 'TickDir', 'out')

ttmp = downsampleUniformly(tt,50)
for i = 1:length(ttmp)
    indx = find(tt == ttmp(i),1,'first');
    drawUnicycle(Xt(indx,:))
%     drawCar(Xt(indx,:))
end
