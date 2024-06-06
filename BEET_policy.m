%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%           Behavioral Expectations Equilibrium Toolkit
%             Jonathan J. Adams (jonathanjadams.com)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% BEET_policy: this program finds the optimal policy rule for responding to
% belief distortions, as documented in Adams 2024 "Optimal Policy Without
% Rational Expectations: A Sufficient Statistic Solution"

% Version 0.21 (2024/6/3)

% inputs: 
% Policy matrix BG
% Cell array of matrices, one of:
%   1. Uhlig-form matrices {FF_fire, GG_fire, HH_fire}
%   2. Adams (2024) notation: {B0, B1, indC, flag} where indC is a vector of indices of control
%   variables, and flag = 1 (a scalar to indicate this notation)
% Welfare matrix Welf (optional)

%matcell = {FF_fire, GG_fire, HH_fire}
%matcell = {-FF_fire, GG_fire, 1, 1}

function [policyrule,ssyes]=BEET_policy(BG, matcell, Welf)

%translate Uhlig form matrices into the form used in "Optimal Policy
%Without Rational Expectations":
if length(matcell) == 3
    if norm(matcell{3})>0
        disp('Models with non-zero HH not yet supported by BEET_policy.')
    end
%currently, this function assumes for Uhlig-form models that all variables are controls
%if you have a model with state variables, rewrite with Adams (2024) notation (for now)
    B1 = -matcell{1};
    B0 = matcell{2};
    indC = size(B1,2);
end

%If using the Adams (2024) notation, extract matrices from cells:
if length(matcell) == 4
    B0 = matcell{1};
    B1 = matcell{2};
    indC = matcell{3};
end

%Cosntruct additional matrices:
BC1 = B1(:,indC);
BGpseudo = (BG'*BG)^(-1)*BG';
PG = BG*BGpseudo;

%Check sentiment spanning
if norm((eye(size(PG,1))-PG)*BC1)==0
    disp('Sentiment Spanning satisfied')
    ssyes = 1;
    policyrule = (BG'*BG)^(-1)*BG'*BC1;
else
    disp('Sentiment Spanning not satisfied')
    ssyes = 0;
    if ~exist('Welf','var')
        disp('You must input a welfare matrix.')
    end
    Wtilde = (B0^-1)'*Welf*B0^-1;
    PW = BG*(BG'*Wtilde*BG)^-1*BG'*Wtilde;
    policyrule = BGpseudo*PW*BC1;
end

end
