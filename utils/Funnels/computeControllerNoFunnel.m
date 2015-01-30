function [funnel] = computeControllerNoFunnel(f0,t,Xk,Uk,S0,Q,R,H,n,isCyclic)

global x

% warning('off','MATLAB:nearlySingularMatrix');
% rmpath('D:\Cornell\Research\CreatePath\ParametricVerification\ellipsoids');

Nsteps = size(Xk,1);%2000;
tspan = [0 t(Nsteps)]; % duration of input.

t0s = t(1:Nsteps);
x0s = Xk(1:Nsteps,:)';
u0s = Uk(1:Nsteps,:)';

xpp = spline(t0s,x0s);
upp = spline(t0s,u0s);

if isCyclic
    % Transform from x-y to x'-y' rotated by initial theta
    invTmotion = [cos(-Xk(1,length(H)+1)) -sin(-Xk(1,length(H)+1)); sin(-Xk(1,length(H)+1)) cos(-Xk(1,length(H)+1))];
    T = blkdiag(invTmotion,eye(n-length(H)));
else
    T = eye(n);
end

% Find a quadratic lyapunov function based on application of an LQR control
% law about the trajectory
[A,B] = tv_poly_linearize(f0,@(t) ppval(xpp,t),@(t) ppval(upp,t));

[ts,Ss] = tv_lqr_riccati_Abias(tspan,A,B,Q,R,S0,T);
Spp = spline(ts,Ss);
S = @(t) ppval(Spp,t);
K = @(t) inv(R(t))*B(t)'*S(t);
Ac = @(t) A(t) - B(t)*K(t);
Q0  = @(t) (Q(t) + S(t)*B(t)*inv(R(t))*B(t)'*S(t));
taus = ts;

N = length(taus);
% Ppp = interp1(taus,reshape(permute(Ss,[3 1 2]),N,n*n),'linear','pp');

% interpolate to determine Ps
for i = 1:Nsteps;%length(t)
    indx = find(min(abs(t(i) - ts)) == abs(t(i) - ts));
    Ps{i} = Ss(:,:,indx);
    Ks{i} = K(t(i));
    xMu(i,:) = Xk(i,:);
end
% ts = ts(1:Nsteps);

for i = 1:length(ts)
    Ks1(:,:,i) = K(ts(i));
end
Kpp = spline(ts,Ks1);

% figure(5), clf
% hold on
% for i = 1:50:length(xMu)
%     xMu(i,1:2)
%     Ptmp = inv(Ps{i});
%     Ellipse_plot(inv(Ptmp(1:2,1:2)),xMu(i,1:2));
% end
% figure(6), clf
% hold on
% Ptmp = inv(Ps{1});
% Ellipse_plot(inv(Ptmp(1:2,1:2)),xMu(1,1:2));
% Ptmp = inv(Ps{end});
% Ellipse_plot(inv(Ptmp(1:2,1:2)),xMu(end,1:2));


% Upsample the ellipsoids
ts = flipud(ts);
% ts = t;
xup = ppval(xpp,ts);
uup = ppval(upp,ts);
Pup = ppval(Spp,ts);
Kup = ppval(Kpp,ts);

% we want to allow theta to wrap so that it stays within limits
if isCyclic
    for indx = length(H)+1:n
        % Wrap theta from -pi to pi
        xup(indx,:) = mod(xup(indx,:)+pi,2*pi)-pi;
    end
end

funnel.t = ts;
funnel.x = xup';
funnel.u = uup';
for i = 1:length(ts)
    PupInvTmp = inv(Pup(:,:,i));
    PupInvTmp = (PupInvTmp'+PupInvTmp)/2;  % to ensure it is symmetric
    Pup(:,:,i) = inv(PupInvTmp);
end
funnel.P = Pup;
funnel.K = Kup;

