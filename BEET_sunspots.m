%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%           Behavioral Expectations Equilibrium Toolkit
%             Jonathan J. Adams (jonathanjadams.com)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% BEET_sunspots: caluclates sunspot equilibria

% Version 0.21 (2024/6/3)

% inputs: 
%       BE_phivec: vector of phi's determining the behavioral expectation
%       BE_g0, BE_g1: model matrices in GENSYS form

% dependency:
%       BEET_eigenseries: this *function* solves for the eigenseries of a
%       subrational BE operator



%find QZ decomposition:
[a b q z v]=qz(BE_g0,BE_g1);
[aa bb qq zz] = ordqz(a,b,q,z,'udo'); %written this way, 'udo' will sort stable gen. eigenvalues to first block row
% decomp satisfies: qq*BE_g0*zz = aa, and qq*BE_g1*zz = bb
% thus aa is Lambda in the text, and bb is Omega
phieigs = diag(bb)./diag(aa);
nstab = sum(abs(phieigs)<1); % number of stable eigenvalues
stab11 = aa(1:nstab,1:nstab)^-1*bb(1:nstab,1:nstab); %stab11 = Lambda_11^-1 * Omega_11
[Qs,Ds] = eigs(stab11); %Qs*Ds*Qs^-1 = stab11 

%select the largest stable eigenvalue:
[eigstabmax eigstabmaxdex] = max(phieigs);

eigenseries_coeff = zz*[Qs(:,eigstabmaxdex); zeros(size(zz,2)-nstab)];

%FUTURE WORK HERE:
%provide an option to provide the eigenseries manually


%find eigenseries associated with the largest stable eigenvalue:
[rhobar,eigenseries_ma]=BEET_eigenseries(eigstabmax,BE_phivec);

%Matrix \mathbf{B}_\mathbf{w}:
BB_ww = zeros(length(BE_phivec)+1);
BB_ww(1,:) = [rhobar, eigenseries_ma'];
BB_ww(2:end-1,3:end) = eye(length(BE_phivec)-1);
Theta_odot = eigenseries_coeff *[1 0*BE_phivec];
