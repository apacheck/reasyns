

% Set up map
pix2m = 10/(100*2.65);

% bndPos = [145, 73]*pix2m;
bndPoints = [0, 0; 400, 0; 400, 300; 0, 300]*pix2m;
r1pos = [150, 0]*pix2m;
r1points = [0, 0; 74, 0; 70, 105; 10, 110]*pix2m;  % (counterclockwise)
r2pos = [0, 240]*pix2m;
r2points = [0, 0; 95, 5; 80, 60; 0, 60]*pix2m;
r3pos = [310, 170]*pix2m;
r3points = [0, 0; 90, -5; 70, 110; -5, 112]*pix2m;
r5pos = [60, 200]*pix2m;
r5points = [0, 0; 60, -50; 80, -5]*pix2m;
r6pos = [70, 50]*pix2m;
r6points = [0, 0; 40, 8; 42, 70; -2, 67]*pix2m;
r7pos = [200, 200]*pix2m;
r7points = [0, 0; 60, 30; 70, 3]*pix2m;
r8pos = [150, 250]*pix2m;
r8points = [0, 0; 50, 3; 54, 40; 6, 42]*pix2m;
r9pos = [200, 120]*pix2m;
r9points = [0, 0; 160, 3; 161, 20; 2, 25]*pix2m;
r10pos = [300, 20]*pix2m;
r10points = [0, 0; 70, 3; 74, 50; 6, 52]*pix2m;
r4pos = [0, 0]*pix2m;
r4points = [0, 0; r2pos+r2points(1,:); r2pos+r2points(2,:); r2pos+r2points(3,:); 
    bndPoints(3,:); r3pos+r3points(2,:); r3pos+r3points(3,:); r3pos+r3points(4,:); r3pos+r3points(1,:); r3pos+r3points(2,:); bndPoints(2,:);
    r1pos+r1points(2,:); r1pos+r1points(3,:); r1pos+r1points(4,:); r1pos+r1points(1,:)];

vReg{1} = [
    r1pos+r1points(1,:); 
    r1pos+r1points(2,:); 
    r1pos+r1points(3,:); 
    r1pos+r1points(4,:)];
vReg{2} = [
    r2pos+r2points(1,:); 
    r2pos+r2points(2,:); 
    r2pos+r2points(3,:); 
    r2pos+r2points(4,:)];
vReg{3} = [
    r3pos+r3points(1,:); 
    r3pos+r3points(2,:); 
    r3pos+r3points(3,:); 
    r3pos+r3points(4,:)];
vReg{4} = [
    r4pos+r4points(1,:); 
    r4pos+r4points(2,:); 
    r4pos+r4points(3,:); 
    r4pos+r4points(4,:);
    r4pos+r4points(5,:); 
    r4pos+r4points(6,:); 
    r4pos+r4points(7,:); 
    r4pos+r4points(8,:);
    r4pos+r4points(9,:); 
    r4pos+r4points(10,:); 
    r4pos+r4points(11,:);
    r4pos+r4points(12,:);
    r4pos+r4points(13,:);
    r4pos+r4points(14,:);
    r4pos+r4points(15,:)];

vReg{5} = [
    r5pos+r5points(1,:); 
    r5pos+r5points(2,:); 
    r5pos+r5points(3,:)];
vReg{6} = [
    r6pos+r6points(1,:); 
    r6pos+r6points(2,:); 
    r6pos+r6points(3,:);
    r6pos+r6points(4,:)];
vReg{7} = [
    r7pos+r7points(1,:); 
    r7pos+r7points(2,:); 
    r7pos+r7points(3,:)];
vReg{8} = [
    r8pos+r8points(1,:); 
    r8pos+r8points(2,:); 
    r8pos+r8points(3,:);
    r8pos+r8points(4,:)];
vReg{9} = [
    r9pos+r9points(1,:); 
    r9pos+r9points(2,:); 
    r9pos+r9points(3,:);
    r9pos+r9points(4,:)];
vReg{10} = [
    r10pos+r10points(1,:); 
    r10pos+r10points(2,:); 
    r10pos+r10points(3,:);
    r10pos+r10points(4,:)];

vBndOuter{1} = [
    bndPoints(1,:); 
    bndPoints(2,:); 
    bndPoints(3,:); 
    bndPoints(4,:)];
vBnd = vBndOuter;

% Bloated regions
dBloat = 0.2;
% positive bloat: smaller avoid regions
vRegB{1} = [
    r1pos+r1points(1,:)+dBloat*[1 0]; 
    r1pos+r1points(2,:)+dBloat*[-1 0]; 
    r1pos+r1points(3,:)+dBloat*[-1 -1]; 
    r1pos+r1points(4,:)+dBloat*[1 -1]];
vRegB{2} = [
    r2pos+r2points(1,:)+dBloat*[0 1]; 
    r2pos+r2points(2,:)+dBloat*[-1 1]; 
    r2pos+r2points(3,:)+dBloat*[-1 0]; 
    r2pos+r2points(4,:)+dBloat*[0 0]];
vRegB{3} = [
    r3pos+r3points(1,:)+dBloat*[1 1]; 
    r3pos+r3points(2,:)+dBloat*[0 1]; 
    r3pos+r3points(3,:)+dBloat*[0 0]; 
    r3pos+r3points(4,:)+dBloat*[1 0]];
vRegB{4} = [
    r4pos+r4points(1,:)+dBloat*[0 0]; 
    r4pos+r4points(2,:)+dBloat*[0 -1]; 
    r4pos+r4points(3,:)+dBloat*[1 -1]; 
    r4pos+r4points(4,:)+dBloat*[1 0];
    r4pos+r4points(5,:)+dBloat*[0 0]; 
    r4pos+r4points(6,:)+dBloat*[0 0]; 
    r4pos+r4points(7,:)+dBloat*[0 0]; 
    r4pos+r4points(8,:)+dBloat*[-1 0]; 
    r4pos+r4points(9,:)+dBloat*[-1 -1]; 
    r4pos+r4points(10,:)+dBloat*[0 -1]; 
    r4pos+r4points(11,:)+dBloat*[0 0];
    r4pos+r4points(12,:)+dBloat*[1 0]; 
    r4pos+r4points(13,:)+dBloat*[1 1]; 
    r4pos+r4points(14,:)+dBloat*[-1 1];
    r4pos+r4points(15,:)+dBloat*[-1 0]];

vRegB{5} = [
    r5pos+r5points(1,:)+dBloat*[0 0]; 
    r5pos+r5points(2,:)+dBloat*[0 0]; 
    r5pos+r5points(3,:)+dBloat*[0 0]];
vRegB{6} = [
    r6pos+r6points(1,:)+dBloat*[0 0]; 
    r6pos+r6points(2,:)+dBloat*[0 0]; 
    r6pos+r6points(3,:)+dBloat*[0 0]; 
    r6pos+r6points(4,:)+dBloat*[0 0]];
vRegB{7} = [
    r7pos+r7points(1,:)+dBloat*[0 0]; 
    r7pos+r7points(2,:)+dBloat*[0 0]; 
    r7pos+r7points(3,:)+dBloat*[0 0]];
vRegB{8} = [
    r8pos+r8points(1,:)+dBloat*[0 0]; 
    r8pos+r8points(2,:)+dBloat*[0 0]; 
    r8pos+r8points(3,:)+dBloat*[0 0]; 
    r8pos+r8points(4,:)+dBloat*[0 0]];
vRegB{9} = [
    r9pos+r9points(1,:)+dBloat*[0 0]; 
    r9pos+r9points(2,:)+dBloat*[0 0]; 
    r9pos+r9points(3,:)+dBloat*[0 0]; 
    r9pos+r9points(4,:)+dBloat*[0 0]];
vRegB{10} = [
    r10pos+r10points(1,:)+dBloat*[0 0]; 
    r10pos+r10points(2,:)+dBloat*[0 0]; 
    r10pos+r10points(3,:)+dBloat*[0 0]; 
    r10pos+r10points(4,:)+dBloat*[0 0]];
% negative bloat: larger interior regions
vRegBN{1} = [
    r1pos+r1points(1,:)-dBloat*[1 0]; 
    r1pos+r1points(2,:)-dBloat*[-1 0]; 
    r1pos+r1points(3,:)-dBloat*[-1 -1]; 
    r1pos+r1points(4,:)-dBloat*[1 -1]];
vRegBN{2} = [
    r2pos+r2points(1,:)-dBloat*[0 1]; 
    r2pos+r2points(2,:)-dBloat*[-1 1]; 
    r2pos+r2points(3,:)-dBloat*[-1 0]; 
    r2pos+r2points(4,:)-dBloat*[0 0]];
vRegBN{3} = [
    r3pos+r3points(1,:)-dBloat*[1 1]; 
    r3pos+r3points(2,:)-dBloat*[0 1]; 
    r3pos+r3points(3,:)-dBloat*[0 0]; 
    r3pos+r3points(4,:)-dBloat*[1 0]];
vRegBN{4} = [
    r4pos+r4points(1,:)-dBloat*[0 0]; 
    r4pos+r4points(2,:)-dBloat*[0 -1]; 
    r4pos+r4points(3,:)-dBloat*[1 -1]; 
    r4pos+r4points(4,:)-dBloat*[1 0];
    r4pos+r4points(5,:)-dBloat*[0 0]; 
    r4pos+r4points(6,:)-dBloat*[0 0]; 
    r4pos+r4points(7,:)-dBloat*[0 0]; 
    r4pos+r4points(8,:)-dBloat*[-1 0]; 
    r4pos+r4points(9,:)-dBloat*[-1 -1]; 
    r4pos+r4points(10,:)-dBloat*[0 -1]; 
    r4pos+r4points(11,:)-dBloat*[0 0];
    r4pos+r4points(12,:)-dBloat*[1 0]; 
    r4pos+r4points(13,:)-dBloat*[1 1]; 
    r4pos+r4points(14,:)-dBloat*[-1 1];
    r4pos+r4points(15,:)-dBloat*[-1 0]];

vRegBN{5} = [
    r5pos+r5points(1,:)-dBloat*[0 0]; 
    r5pos+r5points(2,:)-dBloat*[0 0]; 
    r5pos+r5points(3,:)-dBloat*[0 0]];
vRegBN{6} = [
    r6pos+r6points(1,:)-dBloat*[0 0]; 
    r6pos+r6points(2,:)-dBloat*[0 0]; 
    r6pos+r6points(3,:)-dBloat*[0 0]; 
    r6pos+r6points(4,:)-dBloat*[0 0]];
vRegBN{7} = [
    r7pos+r7points(1,:)-dBloat*[0 0]; 
    r7pos+r7points(2,:)-dBloat*[0 0]; 
    r7pos+r7points(3,:)-dBloat*[0 0]];
vRegBN{8} = [
    r8pos+r8points(1,:)-dBloat*[0 0]; 
    r8pos+r8points(2,:)-dBloat*[0 0]; 
    r8pos+r8points(3,:)-dBloat*[0 0]; 
    r8pos+r8points(4,:)-dBloat*[0 0]];
vRegBN{9} = [
    r9pos+r9points(1,:)-dBloat*[0 0]; 
    r9pos+r9points(2,:)-dBloat*[0 0]; 
    r9pos+r9points(3,:)-dBloat*[0 0]; 
    r9pos+r9points(4,:)-dBloat*[0 0]];
vRegBN{10} = [
    r10pos+r10points(1,:)-dBloat*[0 0]; 
    r10pos+r10points(2,:)-dBloat*[0 0]; 
    r10pos+r10points(3,:)-dBloat*[0 0]; 
    r10pos+r10points(4,:)-dBloat*[0 0]];

% These regions are defined for checking if funnels are misbehaving... need
% some conservatism
vBndOuterB{1} = [
    vBndOuter{1}(1,:)+0.1*[-1 -1]; 
    vBndOuter{1}(2,:)+0.1*[1 -1]; 
    vBndOuter{1}(3,:)+0.1*[1 1]; 
    vBndOuter{1}(4,:)+0.1*[-1 1]];
vRegB2{1} = [
    r1pos+r1points(1,:)+(dBloat+0.1)*[1 0]; 
    r1pos+r1points(2,:)+(dBloat+0.1)*[-1 0]; 
    r1pos+r1points(3,:)+(dBloat+0.1)*[-1 -1]; 
    r1pos+r1points(4,:)+(dBloat+0.1)*[1 -1]];
vRegB2{2} = [
    r2pos+r2points(1,:)+(dBloat+0.1)*[0 1]; 
    r2pos+r2points(2,:)+(dBloat+0.1)*[-1 1]; 
    r2pos+r2points(3,:)+(dBloat+0.1)*[-1 0]; 
    r2pos+r2points(4,:)+(dBloat+0.1)*[0 0]];
vRegB2{3} = [
    r3pos+r3points(1,:)+(dBloat+0.1)*[1 1]; 
    r3pos+r3points(2,:)+(dBloat+0.1)*[0 1]; 
    r3pos+r3points(3,:)+(dBloat+0.1)*[0 0]; 
    r3pos+r3points(4,:)+(dBloat+0.1)*[1 0]];
vRegB2{4} = [
    r4pos+r4points(1,:)+(dBloat+0.1)*[0 0]; 
    r4pos+r4points(2,:)+(dBloat+0.1)*[0 -1]; 
    r4pos+r4points(3,:)+(dBloat+0.1)*[1 -1]; 
    r4pos+r4points(4,:)+(dBloat+0.1)*[1 0];
    r4pos+r4points(5,:)+(dBloat+0.1)*[0 0]; 
    r4pos+r4points(6,:)+(dBloat+0.1)*[0 1]; 
    r4pos+r4points(7,:)+(dBloat+0.1)*[1 1]; 
    r4pos+r4points(8,:)+(dBloat+0.1)*[-1 1]; 
    r4pos+r4points(9,:)+(dBloat+0.1)*[-1 -1]; 
    r4pos+r4points(10,:)+(dBloat+0.1)*[0 -1]; 
    r4pos+r4points(11,:)+(dBloat+0.1)*[0 0];
    r4pos+r4points(12,:)+(dBloat+0.1)*[1 0]; 
    r4pos+r4points(13,:)+(dBloat+0.1)*[1 1]; 
    r4pos+r4points(14,:)+(dBloat+0.1)*[-1 1];
    r4pos+r4points(15,:)+(dBloat+0.1)*[-1 0]];

vRegB2{5} = [
    r5pos+r5points(1,:)+0.1*[1 1]; 
    r5pos+r5points(2,:)+0.1*[0 1]; 
    r5pos+r5points(3,:)+0.1*[-1 1]];
vRegB2{6} = [
    r6pos+r6points(1,:)+0.1*[1 1]; 
    r6pos+r6points(2,:)+0.1*[-1 1]; 
    r6pos+r6points(3,:)+0.1*[-1 -1]; 
    r6pos+r6points(4,:)+0.1*[1 -1]];
vRegB2{7} = [
    r7pos+r7points(1,:)+0.1*[1 1]; 
    r7pos+r7points(2,:)+0.1*[0 -1]; 
    r7pos+r7points(3,:)+0.1*[-1 1]];
vRegB2{8} = [
    r8pos+r8points(1,:)+0.1*[1 1]; 
    r8pos+r8points(2,:)+0.1*[-1 1]; 
    r8pos+r8points(3,:)+0.1*[-1 -1]; 
    r8pos+r8points(4,:)+0.1*[1 -1]];
vRegB2{9} = [
    r9pos+r9points(1,:)+0.1*[1 1]; 
    r9pos+r9points(2,:)+0.1*[-1 1]; 
    r9pos+r9points(3,:)+0.1*[-1 -1]; 
    r9pos+r9points(4,:)+0.1*[1 -1]];
vRegB2{10} = [
    r10pos+r10points(1,:)+0.1*[1 1]; 
    r10pos+r10points(2,:)+0.1*[-1 1]; 
    r10pos+r10points(3,:)+0.1*[-1 -1]; 
    r10pos+r10points(4,:)+0.1*[1 -1]];

vRegBN2{1} = [
    r1pos+r1points(1,:)-(dBloat+0.1)*[1 0]; 
    r1pos+r1points(2,:)-(dBloat+0.1)*[-1 0]; 
    r1pos+r1points(3,:)-(dBloat+0.1)*[-1 -1]; 
    r1pos+r1points(4,:)-(dBloat+0.1)*[1 -1]];
vRegBN2{2} = [
    r2pos+r2points(1,:)-(dBloat+0.1)*[0 1]; 
    r2pos+r2points(2,:)-(dBloat+0.1)*[-1 1]; 
    r2pos+r2points(3,:)-(dBloat+0.1)*[-1 0]; 
    r2pos+r2points(4,:)-(dBloat+0.1)*[0 0]];
vRegBN2{3} = [
    r3pos+r3points(1,:)-(dBloat+0.1)*[1 1]; 
    r3pos+r3points(2,:)-(dBloat+0.1)*[0 1]; 
    r3pos+r3points(3,:)-(dBloat+0.1)*[0 0]; 
    r3pos+r3points(4,:)-(dBloat+0.1)*[1 0]];
vRegBN2{4} = [
    r4pos+r4points(1,:)-(dBloat+0.1)*[0 0]; 
    r4pos+r4points(2,:)-(dBloat+0.1)*[0 -1]; 
    r4pos+r4points(3,:)-(dBloat+0.1)*[1 -1]; 
    r4pos+r4points(4,:)-(dBloat+0.1)*[1 0];
    r4pos+r4points(5,:)-(dBloat+0.1)*[0 0]; 
    r4pos+r4points(6,:)-(dBloat+0.1)*[0 1]; 
    r4pos+r4points(7,:)-(dBloat+0.1)*[1 1]; 
    r4pos+r4points(8,:)-(dBloat+0.1)*[-1 0]; 
    r4pos+r4points(9,:)-(dBloat+0.1)*[-1 -1]; 
    r4pos+r4points(10,:)-(dBloat+0.1)*[0 -1]; 
    r4pos+r4points(11,:)-(dBloat+0.1)*[0 0];
    r4pos+r4points(12,:)-(dBloat+0.1)*[1 0]; 
    r4pos+r4points(13,:)-(dBloat+0.1)*[1 1]; 
    r4pos+r4points(14,:)-(dBloat+0.1)*[-1 1];
    r4pos+r4points(15,:)-(dBloat+0.1)*[-1 0]];

vRegBN2{5} = [
    r5pos+r5points(1,:)-0.1*[1 1]; 
    r5pos+r5points(2,:)-0.1*[0 1]; 
    r5pos+r5points(3,:)-0.1*[-1 1]];
vRegBN2{6} = [
    r6pos+r6points(1,:)-0.1*[1 1]; 
    r6pos+r6points(2,:)-0.1*[-1 1]; 
    r6pos+r6points(3,:)-0.1*[-1 -1]; 
    r6pos+r6points(4,:)-0.1*[1 -1]];
vRegBN2{7} = [
    r7pos+r7points(1,:)-0.1*[1 1]; 
    r7pos+r7points(2,:)-0.1*[0 -1]; 
    r7pos+r7points(3,:)-0.1*[-1 1]];
vRegBN2{8} = [
    r8pos+r8points(1,:)-0.1*[1 1]; 
    r8pos+r8points(2,:)-0.1*[-1 1]; 
    r8pos+r8points(3,:)-0.1*[-1 -1]; 
    r8pos+r8points(4,:)-0.1*[1 -1]];
vRegBN2{9} = [
    r9pos+r9points(1,:)-0.1*[1 1]; 
    r9pos+r9points(2,:)-0.1*[-1 1]; 
    r9pos+r9points(3,:)-0.1*[-1 -1]; 
    r9pos+r9points(4,:)-0.1*[1 -1]];
vRegBN2{10} = [
    r10pos+r10points(1,:)-0.1*[1 1]; 
    r10pos+r10points(2,:)-0.1*[-1 1]; 
    r10pos+r10points(3,:)-0.1*[-1 -1]; 
    r10pos+r10points(4,:)-0.1*[1 -1]];

% Transitions
trans{1} = [1 2];
trans{2} = [2 3];
trans{3} = [3 4];
trans{4} = [4 1];
trans{5} = [4 5];
trans{6} = [5 4];
% trans{6} = [5 4];

% Automaton definition
clear aut
aut.q{1} = 1;
aut.q{2} = 4;
aut.q{3} = 2;
aut.q{4} = 4;
aut.q{5} = 3;
aut.trans{1} = [1 2];
aut.trans{2} = [2 3];
aut.trans{3} = [3 4];
aut.trans{4} = [4 1];
aut.trans{5} = [4 5];
aut.trans{6} = [5 4];

isReactive(1) = false;
isReactive(2) = false;
isReactive(3) = false;
isReactive(4) = true;
isReactive(5) = false;
isReactive(6) = true;

% Construct polytopes
for i = 1:length(vReg)
    pReg{i} = polytope(vReg{i});
    pRegB{i} = polytope(vRegB{i});
    pRegB2{i} = polytope(vRegB2{i});
    pRegBN{i} = polytope(vRegBN{i});
    pRegBN2{i} = polytope(vRegBN2{i});
    [v,c] = double(pRegBN2{i});
    hRegBN2{i} = hyperplane(v',c');
end

pBnd{1} = polytope(vBndOuter{1});
[v,c] = double(pBnd{1});
hBnd{1} = hyperplane(v',c');
pBndB{1} = polytope(vBndOuterB{1});
[v,c] = double(pBndB{1});
hBndB{1} = hyperplane(v',c');

x = msspoly('x',2);
for i = 1:length(pReg)
    [H,K] = double(pReg{i});
    mssReg{i} = (H*x(1:2)-K)' + eps*sum(x);
    [H,K] = double(pRegB{i});
    mssRegB{i} = (H*x(1:2)-K)' + eps*sum(x);
    if ~isempty(double(pRegBN{i}))
        [H,K] = double(pRegBN{i});
        mssRegBN{i} = (H*x(1:2)-K)' + eps*sum(x);
    else
        mssRegBN{i} = mssReg{i};
    end
    
    reg{i}.p = pReg{i};
    reg{i}.pB = pRegB{i};
    reg{i}.pB2 = pRegB2{i};
    reg{i}.hBN2 = hRegBN2{i};
    reg{i}.mssExt = -mssReg{i};
    reg{i}.mssExtB = -mssRegBN{i};
    reg{i}.mssInt{1} = [];
    reg{i}.mssIntB{1} = [];    
    reg{i}.v = vReg{i};
    reg{i}.vB = vRegB{i};
end
% TODO: automate the setting of internal regions??
reg{4}.mssInt{1} = mssReg{5};
reg{4}.mssIntB{1} = mssRegB{5};

for i = 1:length(pBnd)
    [H,K] = double(pBnd{i});
    mssBnd{i} = (H*x(1:2)-K)' + eps*sum(x);
    
    regBnd{i}.p = pBnd{i};
    regBnd{i}.hB = hBndB{i};
    regBnd{i}.mss = -mssBnd{i};
    regBnd{i}.v = vBndOuter{i};
end

%%
% Construct composite region for each transition
clear regX
regX{1}.mssExt = regBnd{1}.mss;
regX{1}.mssExtB = regBnd{1}.mss;
regX{1}.pExt = regBnd{1}.p;
regX{1}.hExtB = regBnd{1}.hB;
regX{2} = regX{1};
regX{3} = regX{1};
regX{4} = regX{1};
regX{5} = regX{1};
regX{6} = regX{1};
regX{7} = regX{1};
regX{8} = regX{1};
regX{9} = regX{1};
regX{10} = regX{1};

for indx = 1:length(aut.trans)
    count = 0;
    for i = 1:length(mssReg)
        if all(i ~= [aut.q{aut.trans{indx}}])
            count = count + 1;
            regX{indx}.mssInt{count} = mssReg{i};
            regX{indx}.mssIntB{count} = mssRegB{i};
            regX{indx}.pInt(count) = pReg{i};
            regX{indx}.pIntB(count) = pRegB{i};
            regX{indx}.pIntB2(count) = pRegB2{i};
        end
    end
end

% testing...
indx = length(aut.trans)+1;
count = 0;
for i = 4
    count = count + 1;
    regX{indx}.mssInt{count} = mssReg{i};
    regX{indx}.mssIntB{count} = mssRegB{i};
    regX{indx}.pInt(count) = pReg{i};
    regX{indx}.pIntB(count) = pRegB{i};
    regX{indx}.pIntB2(count) = pRegB2{i};
end
indx = length(aut.trans)+2;
count = 0;
count = count + 1;
regX{indx}.mssInt{count} = [];
regX{indx}.mssIntB{count} = [];
regX{indx}.pInt = [];
regX{indx}.pIntB = [];
regX{indx}.pIntB2 = [];