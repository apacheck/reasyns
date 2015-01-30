function [sys,acNom] = computeLQR(sys,acNom,skipFun,indices,map,acBnd,acIn)

global x

if sum(sys.isCyclic) > 1, error('number of cyclic dimensions cannot exceed 1'), end
if length(sys.isCyclic) ~= sys.n, error('number of entries in isCylic must be equal to n!'), end

bloatFlag = false;

x = msspoly('x',sys.n);

nn = length(sys.H)+1; % ??
cycIndx = find(sys.isCyclic);


Nsteps = size(acNom.x,1);%2000;
tspan = [0 acNom.t(Nsteps)]; % duration of input.

t0s = acNom.t(1:Nsteps);
x0s = acNom.x(1:Nsteps,:)';
xpp = spline(t0s,x0s);
u0s = acNom.u(1:Nsteps,:)';
upp = spline(t0s,u0s);

if any(sys.isCyclic)
    ithSet = 1:3;
    thSgn = [0 -1 1];
else
    ithSet = 1;
    thSgn = 0;
end

% looping needed for "unwrapping" of theta
for ith = ithSet
    %TODO: generalize the following to arb dimensions
    x0s = Xk(1:Nsteps,:)' + repmat(2*pi*thSgn(ith)*isCyclic',Nsteps,1)';
    xpp1 = spline(t0s,x0s);

    if any(isCyclic)
        % Transform from x-y to x'-y' rotated by initial theta
        invTmotion = [cos(-Xk(1,cycIndx)) -sin(-Xk(1,cycIndx)); sin(-Xk(1,cycIndx)) cos(-Xk(1,cycIndx))];
        T = blkdiag(invTmotion,eye(n-length(H)));
    else
        T = eye(n);
    end
    
    % Find a quadratic lyapunov function based on application of an LQR control
    % law about the trajectory
    [A,B] = tv_poly_linearize(f0,@(t) ppval(xpp1,t),@(t) ppval(upp,t));
    
    tspan = linspace(tspan(1),tspan(2),5000);
    [ts{ith},Ss{ith}] = tv_lqr_riccati_Abias(tspan,A,B,Q,R,S0,T);
    Spp{ith} = spline(ts{ith},Ss{ith});
    S = @(t) ppval(Spp{ith},t);
    K{ith} = @(t) inv(R(t))*B(t)'*S(t);
    Ac{ith} = @(t) A(t) - B(t)*K{ith}(t);
    Q0{ith} = @(t) (Q(t) + S(t)*B(t)*inv(R(t))*B(t)'*S(t));
    clear Ks1
    for ii = 1:length(ts{ith})
        Ks1(:,:,ii) = K{ith}(ts{ith}(ii));
    end
    Kpp{ith} = spline(ts{ith},Ks1);
end

% selecting taus is somewhat arbitrary.. we'll use the fine-grained result produced by tv_lqr_riccati_Abias
%taus = ts{1};
% choose taus to be the time vector from the trajectory generation
taus = flipud(t);

N = length(taus);
    
% interpolate to determine Ps, etc
for i = 1:Nsteps;%length(t)
    if any(isCyclic)
        ith(i) = 1;
        if Xk(i,nn) > pi
            ith(i) = 2;
        elseif Xk(i,nn) < -pi
            ith(i) = 3;
        end
    else
        ith(i) = 1;
    end
        
    indx = find(min(abs(t(i) - ts{ith(i)})) == abs(t(i) - ts{ith(i)}),1,'first');
    sys(i).P = Ss{ith(i)}(:,:,indx);
    sys(i).K = K{ith(i)}(t(i));
    sys(i).Acl = Ac{ith(i)}(t(i));
    ac(i).x_mod = Xk(i,:) + isCyclic'*thSgn(ith(i))*2*pi;
end
sys = interp(sys);



% we want to allow theta to wrap
% if isCyclic
%     for indx = nn:n
%         % Wrap theta from -pi to pi
%         xup(indx,:) = mod(xup(indx,:)+pi,2*pi)-pi;
%     end
% end

taus = flipud(taus);
xup = ppval(xpp,taus);
for i = 1:N
    if any(isCyclic)
        ith(i) = 1;
        if xup(nn,i) > pi
            ith(i) = 2;
        elseif xup(nn,i) < -pi
            ith(i) = 3;
        end
    else
        ith(i) = 1;
    end
    Pup(:,:,i) = ppval(Spp{ith(i)},taus(i));
    Kup(:,:,i) = ppval(Kpp{ith(i)},taus(i));
end

