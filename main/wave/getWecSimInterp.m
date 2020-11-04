function [F] = getWecSimInterp()

rho = 1020;
g = 9.81;

%load wec sim results into structure
wsr_1 = load('struct1m_opt');
wsr_1 = wsr_1.('struct1m_opt');
wsr_2 = load('struct2m_opt');
wsr_2 = wsr_2.('struct2m_opt');
wsr_3 = load('struct3m_opt');
wsr_3 = wsr_3.('struct3m_opt');
wsr_4 = load('struct4m_opt');
wsr_4 = wsr_4.('struct4m_opt');
wsr_5 = load('struct5m_opt');
wsr_5 = wsr_5.('struct5m_opt');
wsr_6 = load('struct6m_opt');
wsr_6 = wsr_6.('struct6m_opt');
s(6) = struct();
s(1).wsr = wsr_1;
s(2).wsr = wsr_2;
s(3).wsr = wsr_3;
s(4).wsr = wsr_4;
s(5).wsr = wsr_5;
s(6).wsr = wsr_6;
%preallocate scatter arrays
H_scat = [];
T_scat = [];
B_scat = [];
CWR_scat = [];
for b = 1:length(s)
    n = length(s(b).wsr.H);
    if ~isequal(n,length(s(b).wsr.T))
        error('Tp and Hs vectors are not equal in length.')
    end
    H = s(b).wsr.H;
    T = s(b).wsr.T;
    B = b*ones(n,1);
    J = (1/(64*pi))*rho*g^2.*H.^2.*T; %find wave power
    P = reshape(s(b).wsr.mat',n,1); %find wec power (use mat not P)
    CWR = P./(J.*B); %find cwr
    %populate scatter arrays
    T_scat = [T_scat ; T];
    H_scat = [H_scat ; H];
    B_scat = [B_scat ; B];
    CWR_scat = [CWR_scat ; CWR];
end
%create scattered interpolant
F =  scatteredInterpolant(T_scat,H_scat,B_scat,CWR_scat);
end

