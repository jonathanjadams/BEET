%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%           Behavioral Expectations Equilibrium Toolkit
%             Jonathan J. Adams (jonathanjadams.com)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% BEET_eigenseries: this program finds the eigenseries of a subrational
% behavioral expectation operator associated with an eigenvalue

% Version 0.21 (2024/6/3)

% inputs: BE_phivec, vector of phi's determining the behavioral expectation


function [rhobar,eigenseries_ma]=BEET_eigenseries(lambda,BE_phivec)

rhobar = lambda/sum(BE_phivec);
JJ = length(BE_phivec)-1;

if abs(rhobar)>=1
    disp('No stable eigenseries for designated eigenvalue')
end

Brho_lowertri = zeros(JJ+1);
for jj = 0:JJ
    Brho_lowertri = Brho_lowertri + rhobar^(jj+1)*diag(BE_phivec(1+jj:end),-jj);
end
Brho_upperdiag = cumsum(BE_phivec(1:end-1));
Brho = Brho_lowertri + diag(Brho_upperdiag,1);
[Brho_V Brho_D] = eigs(Brho);

%find the correct eigenvalue:
 [eig_error_min eig_error_dex] = min( abs(diag(Brho_D)-lambda));
 if eig_error_min>.01
    di('There might not be an eigenseries associated with your eigenvalue.')
 end
 eigenseries_ma = Brho_V(:,eig_error_dex);
%check: Brho*eigenseries_ma-lambda*eigenseries_ma
end
