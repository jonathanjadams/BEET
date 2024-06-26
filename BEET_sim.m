%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%           Behavioral Expectations Equilibrium Toolkit
%             Jonathan J. Adams (jonathanjadams.com)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% BEET_sim: this program simulates a model solved with BEET_solve.m

% Version 0.22 (2024/6/27)

% inputs: 
% - Solution output from BEET_solve.m
% - vector of shock standard deviations sigma_vec
% - simulation length simul_T
% - burn-in length simul_burnin


% Set defaults:
if ~exist('sigma_vec','var') 
    sigma_vec = ones(n_exo+n_senti,1); %if no standard deviations are specified, default is to assume std. normal
end
if ~exist('simul_burnin','var') 
    simul_burnin = 100; %burn in periods from zero initial condition
end
if ~exist('simul_T','var') 
    simul_T = 10000;
end
if ~exist('WWWW','var')
    WWWW = eye(n_exo+n_senti); %WWWW is the matrix mapping str. shocks to each element in z
end

%turn sigma_vec into a column if it's a row:
if length(sigma_vec)>1 && size(sigma_vec,1)==1
    sigma_vec_col = sigma_vec';
else
    sigma_vec_col = sigma_vec;
end

eps_sim = randn(n_exo+n_senti,simul_T+simul_burnin).*repmat(sigma_vec_col,1,simul_T+simul_burnin);


z_sim=zeros(n_exo+n_senti,simul_T+simul_burnin);
x_sim=zeros(n_fl+n_f,simul_T+simul_burnin);
y_sim=zeros(n_con,simul_T+simul_burnin);
%if you are also constructing cumulative forecasts:
if ~exist('QQaf','var')
    PPaf = zeros(0,n_fl+n_f); %otherwise, include and let be zero
    QQaf = zeros(0,n_exo+n_senti);
    fcast_hors = [];
end
fa_sim=zeros(size(fcast_hors,1),simul_T+simul_burnin); %cumulative forecasts

for tt = 2:(simul_T+simul_burnin)
    %z_sim(:,tt) = NN_alm*z_sim(:,tt-1) + WWWW*eps_sim(:,tt);
    z_sim(:,tt) = NN_fire*z_sim(:,tt-1) + WWWW*eps_sim(:,tt); %NN_fire: crucial! simulated data generated by TRUE law of motion
    x_sim(:,tt) = PP*x_sim(:,tt-1) + QQ*z_sim(:,tt); %past x, current z
    y_sim(:,tt) = RR*x_sim(:,tt-1) + SS*z_sim(:,tt); %past x, current z
    fa_sim(:,tt) = PPaf*x_sim(:,tt) + QQaf*z_sim(:,tt); %current x, current z
end
z_sim = z_sim(:,simul_burnin+1:end);
x_sim = x_sim(:,simul_burnin+1:end);
y_sim = y_sim(:,simul_burnin+1:end);
fa_sim = fa_sim(:,simul_burnin+1:end);
eps_sim = eps_sim(:,simul_burnin+1:end);

%combine x and y and fa (in same order as IRFs):
xy_sim = [y_sim; x_sim; fa_sim];

