
global Xk Uk K t l Xss Uss Kss

% Model parameters
l = 1.0;

% Model parameters
Hout = eye(2);

modelType = 'unicycle';

switch modelType
    
    case 'unicycle'
        f0 = @(t,x,u) CreateKinematicsPoly(t,x,u);
        n = 3;
        n1 = n;

        limsNonRegState = [-pi; pi];
        isCyclic = [0 0 1]';
        
        % LQR controller parameters
        S0 = 1e4*eye(n);   % Qf in terminal cost
        Q = @(t) 1e0*diag([100 100 0.0001]);
        % R = @(t) 1e2*eye(2);
        R = @(t) diag([1e4 1e2]);
        
%         initState = [0;0;0];
        initState = [0;0;pi/2];
%         initState = [0;0;pi];
        
        initState1 = initState;
        % initial valus of test traj
%         X0 = initState1;
        X0 = initState1 + 1*[1 1 1]';
%         X0 = initState1 + -1*[-1 1 1]';
%         X0 = initState1 + -1*[-1 -1 1]';
        
    case 'car'
        f0 = @(t,x,u) CarKinematicsPoly(t,x,u);
        n = 4;
        n1 = n;

        limsNonRegState = [-pi -pi/2; pi pi/2]; % for a car-like robot
        isCyclic = [0 0 1 0]';
        
        % LQR controller parameters
        S0 = 1e4*eye(n);   % Qf in terminal cost
        Q = @(t) 1e0*diag([1000 1000 10 10]);
        % R = @(t) 1e2*eye(2);
        R = @(t) diag([1e3 1e2]);
        
        initState = [0;0;0;0];
        initState1 = initState;
        X0 = initState1 + [0.1 0.1 0.1 0.1]';
end

isCyclic1 = isCyclic;
cycIndx = find(isCyclic);

% if n == 4 && ~any(isCyclic)
%     tmp = initState(3);
%     initState1(3) = sin(tmp);
%     initState1(4) = cos(tmp);
% else
%     initState1 = initState;
% end

initOutput = initState(1:2);

% goalState = [-10;1;3];  % "west"
goalState = [-1;-10;3];  % "south"
% goalState = [10;-1;3];  % "east"
goalState1 = goalState;
% if n == 4 && ~any(isCyclic)
%     tmp = goalState(3);
%     goalState1(3) = sin(tmp);
%     goalState1(4) = cos(tmp);
% else
%     goalState1 = goalState;
% end
goalOutput = goalState(1:2);

[t,Xk,Uk] = genNominalTrajectory(initState,[initOutput';goalOutput'],Hout,n1,isCyclic1,modelType);

% kludge to get Uk to behave for us
% Uk(abs(Uk(:,1))<0.1,1) = 0.1;

if any(isCyclic)
    % Transform from x-y to x'-y' rotated by initial theta
    invTmotion = [cos(-Xk(1,cycIndx)) -sin(-Xk(1,cycIndx)); sin(-Xk(1,cycIndx)) cos(-Xk(1,cycIndx))];
    T = blkdiag(invTmotion,eye(n-length(Hout)));
else
    T = eye(n);
end

Xkur = Xk;
% rotate the whole trajectory
X0 = T*X0 - [0 0 Xk(1,cycIndx)]';
Xk = Xk*T' - repmat([0 0 Xk(1,cycIndx)],length(Xk),1);

figure(10)
clf
hold on
axis equal
plot(Xk(:,1),Xk(:,2),'r',Xkur(:,1),Xkur(:,2),'b')

% if n == 4 && ~any(isCyclic)
%     Xk1 = Xk(:,1:2);
%     Xk1(:,3) = sin(Xk(:,3));
%     Xk1(:,4) = cos(Xk(:,3));
% else
    Xk1 = Xk;
% end

[traject] = computeControllerNoFunnel(f0,t,Xk1,Uk,S0,Q,R,Hout,n,isCyclic);

Xk0 = traject.x;
Uk0 = traject.u;
K0 = traject.K;
t0 = traject.t;

% figure(10)
% plot(Xk(:,1),Xk(:,2),'k')

%%

Xk = Xk0; Uk = Uk0; K = K0; t = t0;
% clear nrm K1 K2
% for i = 1:size(Xk,1), nrm(i) = norm(X0' - Xk(i,:)); end
% startIdx = max(find(min(nrm) == nrm), 1);
% Xk(1:startIdx-1,:) = [];
% Uk(1:startIdx-1,:) = [];
% K(:,:,1:startIdx-1) = [];
% t(1:startIdx-1) = [];
% K1 = squeeze(K(1,:,:))';
% K2 = squeeze(K(2,:,:))';
% 
% % reset time
% t = t - t(1);

xpoly = spline(t,Xk');
upoly = spline(t,Uk');
Kpoly = spline(t,K);
Xss = @(t) ppval(xpoly,t);
Uss = @(t) ppval(upoly,t);
Kss = @(t) ppval(Kpoly,t);

%         isinternal(ellTmp1(1),X0)
switch modelType
    case 'unicycle'
        [t2,Xk2] = ode45(@ CreateKinematicsNL, t, X0);
    case 'car'
        [t2,Xk2] = ode23s(@ CarKinematicsNL, t, X0);
end    
% sim('simCreateKinematicsNL');
% Wrap theta from -pi to pi
Xk1(:,cycIndx) = mod(Xk1(:,cycIndx)+pi,2*pi)-pi;

%%
if n == 4 && any(isCyclic)
    figure(11)
    clf
    hold on
    plot(t,Xk(:,4))
    plot(t,pi/2*ones(1,length(t)),'r:',t,-pi/2*ones(1,length(t)),'r:')
end

figure(12)
clf
hold on 
axis equal
% plot(Xk1(:,1),Xk1(:,2))
plot(Xk2(:,1),Xk2(:,2),'g')
plot(Xk(:,1),Xk(:,2),'r')
drawnow