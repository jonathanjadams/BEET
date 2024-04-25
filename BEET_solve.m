%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%           Behavioral Expectations Equilibrium Toolkit
%             Jonathan J. Adams (jonathanjadams.com)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% BEET_solve: this program solves a model with behavioral expectations or
% sentiment shocks

% Version 0.1 (2023/10/16)

% dependencies: Uhlig Toolkit subroutines (add to path), BEET_foreterm (optional)

% inputs: 
% - FIRE model expressed in Uhlig Toolkit form, with matrices
%   (AA_fire, BB_fire, CC_fire ... LL_fire, etc.)
% - vectors fcast_vars, senti_endovars, senti_exovars, which determine which
%   endogenous variables should have forecasts included in the model, which
%   endogenous variables should have sentiment shocks, and which exogenous
%   states should have sentiment shocks
% - (optional) additional cumulative horizons fcast_hors


if ~exist('BE_phivec','var') %if no behavioral expectation is specified, set expanded L,M,N matrices to be FIRE matrices
    DD_firebig = DD_fire;
    LL_firebig = LL_fire;
    MM_firebig = MM_fire;
    NN_firebig = NN_fire;
else 
    %but if there are behavioral expectations, we will need to redefine the
    %state vector to include lags of states:
    NN_firebig = repmat(0*NN_fire,length(BE_phivec));
    NN_firebig(1:size(NN_fire,1),1:size(NN_fire,2))=NN_fire;
    NN_firebig(1+size(NN_fire,1):end,1:size(NN_fire,2)*(length(BE_phivec)-1)) = eye((length(BE_phivec)-1)*size(NN_fire,1));
    DD_firebig = [DD_fire, repmat(0*DD_fire,1,(length(BE_phivec)-1))];
    LL_firebig = [LL_fire, repmat(0*LL_fire,1,(length(BE_phivec)-1))];
    MM_firebig = [MM_fire, repmat(0*MM_fire,1,(length(BE_phivec)-1))];
    %And then define this misperceived law of motion:
    NN_misp = NN_firebig;
    NN_misp(1:size(NN_fire,1),:) = kron(BE_phivec,NN_fire);
end


n_fl = size(GG_fire,1);  %number of forward looking equations in base model
n_exo = size(NN_firebig,1); %number of exogenous states in the (modified) base model
n_exo_fire = size(NN_fire,1); %number of exogenous states in the FIRE base model (sometimes different than n_exo if expectations are behavioral)

if ~exist('CC_fire','var')
    CC_fire = [];
    AA_fire = zeros(0,n_fl);
    BB_fire = AA_fire;
    DD_fire = zeros(0,n_exo);
    JJ_fire = zeros(n_fl,0);
    KK_fire = zeros(n_fl,0);
end
n_con = size(CC_fire,1); %number of contemporaneous equations in base model

if ~exist('senti_endovars','var')
    senti_endovars = [];
end
if ~exist('senti_exovars','var')
    senti_exovars = [];
end


if ~(size(CC_fire,1)==size(CC_fire,2) && size(GG_fire,1)==size(GG_fire,2) && size(NN_fire,1)==size(NN_fire,2))
    di('C, G, and N matrices need to be square')
end
if ~exist('fcast_vars','var')
   disp('Warning: no forecast dimensions specified') 
   disp('... so I have reset forecast dimensions to match your stated endogenous sentiment dimensions') 
    fcast_vars=senti_endovars;
end
if ~isempty(setdiff(senti_endovars, fcast_vars))
   disp('Warning: endogenous sentiment dimensions are not a subset of forecast dimensions') 
   disp('... so I have reset forecast dimensions to match your stated endogenous sentiment dimensions') 
   fcast_vars=senti_endovars;
end
if size(fcast_vars,2)>1
    fcast_vars = fcast_vars'; % if fcast_vars is a row, make it a column
    if size(fcast_vars,2)>1
       disp('Warning: fcast_vars need to be a vector. Start over!')  
       stop
    end
end
if exist('fcast_hors','var')
    if isempty(fcast_hors)
    else
        if ~isempty(setdiff(fcast_hors(:,1), fcast_vars))
           disp('Warning: term structure forecast dimensions are not a subset of forecast dimensions') 
           disp('... so I have reset forecast dimensions to include your requested term structure forecast dimensions') 
           fcast_vars=[fcast_vars; setdiff(fcast_hors(:,1), fcast_vars)];
        end
    end
end

if max(senti_exovars) > n_exo
   disp('Warning: exogenous sentiment dimensions are not a subset of exogenous state dimensions')
   disp('... so I have reset exogenous sentiment dimensions to match the exogenous state dimensions')    
   senti_exovars = 1:n_exo;
end

%No sentiment autocorrelation declared?
if ~exist('senti_autocorr','var')
    senti_autocorr = 0; %.... then set it to zero
end


%matrix chooses which forward looking variables (the "x"s) will be forecasted (fcast_vars picks vector entries)
nonfcast_vars = setdiff(1:n_fl,fcast_vars); 
choose_forecasts = zeros(length(fcast_vars),n_fl);
for jj = 1:length(fcast_vars)
    choose_forecasts(jj,fcast_vars(jj))=1;
end
n_f = length(fcast_vars); %number of forecasts to include

%we are going to introduce sentiments, which either affect forecasts of
%endogenous variables or forecasts of exog states
%exog state entries are [exog s_exo s_endo]

%n_s_exo = 3; %number of sentiments of exogenous states to include
%s_exo_mat = zeros(n_exo,n_s_exo);  %identifies which exogenous state is associated with the sentiment
%s_exo_mat(1,1)=1; s_exo_mat(2,2)=1; s_exo_mat(3,3)=1;
n_s_exo = length(senti_exovars); %number of sentiments of endogenous states to include
s_exo_mat = zeros(n_exo,n_s_exo);
choose_senti_exo = zeros(length(senti_exovars),n_exo);
for jj = 1:length(senti_exovars)
    choose_senti_exo(jj,senti_exovars(jj))=1;
end



n_s_endo = length(senti_endovars); %number of sentiments of endogenous states to include
%s_endo_mat = zeros(n_exo,n_s_endo);
choose_senti_vars = zeros(length(senti_endovars),n_fl);
for jj = 1:length(senti_endovars)
    choose_senti_vars(jj,senti_endovars(jj))=1;
end
choose_fcasts_senti=choose_forecasts*choose_senti_vars'; %identifies which forecasts (row) have a sentiment (column)

n_senti = n_s_exo + n_s_endo;
NN_state_senti = [choose_senti_exo', zeros(n_exo,n_s_endo)];

%%%%
%  construct modified matrices
%%%%

%first set of matrices for non-expectational eqn (taylor rule)
AA = [AA_fire zeros(n_con,n_f)];
BB = [BB_fire zeros(n_con,n_f)];
CC = CC_fire;
DD = [DD_firebig zeros(n_con,n_senti)];

%second set for expectational eqn (ordered Euler, NKPC):
FF_forecasts = [choose_forecasts, zeros(n_f)]; %forecast variables forecast endogenous variables selected by choose_forecasts
FF_eulers = zeros(n_fl,n_fl+n_f); 
FF_eulers(:,nonfcast_vars)=FF_fire(:,nonfcast_vars); %non-forecasted variables are one-period-ahead as normal
FF = [FF_eulers; FF_forecasts];
GG_forecasts = [zeros(n_f,n_fl) -eye(n_f)]; %forecast variables match up to expectations of vars in FF_forecasts
GG_eulers = [GG_fire zeros(n_fl,n_f)]; 
GG_eulers(:,n_fl+1:end)=FF_fire(:,fcast_vars); %replacing forecasted variables with their included forecasts
GG = [GG_eulers; GG_forecasts];
HH = [HH_fire zeros(n_fl,n_f); zeros(n_f,n_f+n_fl)];
JJ = [JJ_fire; zeros(n_f,n_con)];
KK = [KK_fire; zeros(n_f,n_con)];
LL = [LL_firebig, zeros(n_fl,n_senti); zeros(n_f,n_exo+n_senti)];
MM = [MM_firebig, zeros(n_fl,n_senti); zeros(n_f,n_exo+n_s_exo) choose_fcasts_senti];

%Sentiments block law of motion
%NN_senti = zeros(n_senti);
NN_senti = senti_autocorr*eye(n_senti);

%Actual law of motion
NN_alm = zeros(n_exo+n_senti); NN_alm(1:n_exo,1:n_exo) = NN_firebig;
NN_alm(1+n_exo:end,1+n_exo:end) = NN_senti; %sentiments evolve too

%Perceived law of motion (model-specific)
if ~exist('NN_misp','var')
    NN_misp = NN_firebig; %NN_misp is agents' misperception of the NN matrix.  If not specified, set to FIRE.
end
NN_plm = zeros(n_exo+n_senti); NN_plm(1:n_exo,1:n_exo) = NN_misp;
NN_plm(1+n_exo:end,1+n_exo:end) = NN_senti;
NN_plm(1:n_exo,1+n_exo:end)= NN_state_senti;

%solve!
NN = NN_plm;

warnings = [];
options;
solve;

%I return NN to match the *actual* law of motion 
%(for other post-processing functions)
NN = NN_alm;

%If you asked by choosing fcast_hors:
%After solving, construct term structure of additional cumulative forecasts
if exist('fcast_hors','var')
    if ~isempty(fcast_hors)
    BEET_foreterm;
    end
end
