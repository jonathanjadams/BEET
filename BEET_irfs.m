%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%           Behavioral Expectations Equilibrium Toolkit
%             Jonathan J. Adams (jonathanjadams.com)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% BEET_irfs: this program calculates the Impulse Response Functions for a model solved with BEET_solve.m

% Version 0.1 (2023/10/16)

% inputs: 
% - Solution output from BEET_solve.m
% - IRF length irf_T
% - option to plot BEET_irf_plot
% - arrays of variable names z_titles, x_titles, y_titles

% Set defaults:
if ~exist('irf_T','var') 
    irf_T = 12;
end
if ~exist('BEET_irf_plot','var') 
    BEET_irf_plot = 1;
end
if ~exist('BEET_irf_vars','var')  %which shocks to plot?
    BEET_irf_vars = [1:n_exo_fire, n_exo+1:n_exo+n_senti]; %sentiment shocks are ordered after redundant non-fire states (hence the gap between n_exo_fire and n_exo+1)
end
if ~exist('plot_z_irfs','var') 
    plot_z_irfs = 1; %by default, include z vector in irf plots
end

%if xtitles exist, construct ftitles:
ftitles={};
if exist('xtitles','var')
    for ff = 1:length(fcast_vars)
      ftitles(ff) = strcat({'F['},xtitles(fcast_vars(ff)),{']'});
    end
end
%if xtitles exist, and additional forecasts are included, construct fchtitles:
fchtitles={};
if exist('xtitles','var') && exist('fcast_hors','var')
    for HH = 1:size(fcast_hors,1)
        if fcast_hors(HH,3)==0
          fchtitles(end+1) = strcat({'F^{'},num2str(fcast_hors(HH,2)),{'}['},xtitles(fcast_hors(HH,1)),{']'});
        else
          fchtitles(end+1) = strcat({'F^{1:'},num2str(fcast_hors(HH,2)),{'}['},xtitles(fcast_hors(HH,1)),{'] '});
        end
    end
end


%labels for plots? only if var labels are defined:
label_vars = exist('xtitles','var');
if exist('xtitles','var') && ~exist('ytitles','var')
    xytitles = xtitles;
end
if exist('xtitles','var') && exist('ytitles','var')
    xytitles = ytitles;
    xytitles((length(ytitles)+1):(length(xtitles)+length(ytitles))) = xtitles;
end
%append forecasts to end:
if exist('xtitles','var') && ~isempty(fcast_vars)
    xytitles(end+1:end+length(fcast_vars)) = ftitles;
end
%append cumulative forecasts to end:
if exist('xtitles','var') && exist('fcast_hors','var')
    xytitles(end+1:end+size(fcast_hors,1)) = fchtitles;
end

label_shocks = exist('ztitles','var');
%if ztitles exist, construct stitles:
stitles={};
if exist('ztitles','var')
    zstitles = ztitles;
    for ss = 1:length(senti_exovars)
      stitles(ss) = strcat(ztitles(senti_exovars(ss)),{' sentiment'});
    end
    for ss = 1:length(senti_endovars)
      stitles(length(senti_exovars)+ss) = strcat(xtitles(senti_endovars(ss)),{' sentiment'});
    end
end
%append sentiments to end:
if exist('ztitles','var') && ~isempty(stitles)
    zstitles(end+1:end+length(stitles)) = stitles;
end


%Calculate IRFs

if ~exist('WWWW','var')
    WWWW = eye(n_exo+n_senti); %WW is the matrix mapping str. shocks to each element in z
end

%first dimension: outcome variables
%second dimension: response horizon
%third dimension: shock
z_irf=zeros(n_exo+n_senti,irf_T+1,n_exo+n_senti);
x_irf=zeros(n_fl+n_f,irf_T+1,n_exo+n_senti);
y_irf=zeros(n_con,irf_T+1,n_exo+n_senti);

if ~exist('QQaf','var')
    PPaf = zeros(0,n_fl+n_f); %otherwise, include and let be zero
    QQaf = zeros(0,n_exo+n_senti);
    fcast_hors = [];
end
    fa_irf=zeros(size(fcast_hors,1),irf_T+1,n_exo+n_senti); %cumulative forecasts


for ss = 1:n_exo_fire+n_senti
    %initialize:
    impulse = zeros(n_exo+n_senti,1); impulse(ss)=1;
    z_irf(:,1,ss)=WWWW*impulse;
    x_irf(:,1,ss)=QQ*WWWW*impulse;
    y_irf(:,1,ss)=SS*WWWW*impulse;
    fa_irf(:,1,ss)=PPaf*x_irf(:,1,ss) + QQaf*WWWW*impulse;
    for tt = 1:irf_T
        z_irf(:,tt+1,ss) = NN_alm*z_irf(:,tt,ss); %NN_fire: crucial! simulated data generated by TRUE law of motion
        x_irf(:,tt+1,ss) = PP*x_irf(:,tt,ss) + QQ*z_irf(:,tt+1,ss); %past x, current z
        y_irf(:,tt+1,ss) = RR*x_irf(:,tt,ss) + SS*z_irf(:,tt+1,ss); %past x, current z
        fa_irf(:,tt+1,ss) = PPaf*x_irf(:,tt+1,ss) + QQaf*z_irf(:,tt+1,ss); %current x, current z
    end
end

%combine x and y and fa:
xy_irf = [y_irf; x_irf; fa_irf];
irf_titles = xytitles;
if plot_z_irfs == 1
    %We are only going to plot IRFs for the original states
    %i.e. if we had to add lags of states to implement behavioral expectations
    %we will not plot the IRFs to those lags - they are redundant:
    plotzs = 1:n_exo_fire;
    %add to original irf array:
    xy_irf = [xy_irf; z_irf(plotzs,:,:)];
    %if also plotting z irfs, need to add those to titles
    irf_titles(end+1:end+length(zstitles)) = zstitles; %should be zstitles; if something breaks consider cases where this was only ztitles;
end



%zero irfs should *look* like zero. Round tiny non-zero irfs to zero:
irf_zero_threshold = 1e-8;
for jj = 1:size(xy_irf,3)
    xy_irf(max(abs(xy_irf(:,:,jj)),[],2)<irf_zero_threshold,:,jj)=0;
end




%%%%%%%%%%%%%
% plot IRFs %
%%%%%%%%%%%%%

if BEET_irf_plot == 1
    subplot_cols =  ceil(sqrt(size(xy_irf,1)));
    subplot_rows =  ceil(size(xy_irf,1)/subplot_cols);
    
    for ss = 1:length(BEET_irf_vars)
        shock_index = BEET_irf_vars(ss);
        fig=figure(ss);
        title('Layout Title');
        for pp = 1:size(xy_irf,1)
           subplot(subplot_rows,subplot_cols,pp)
           plot(-1:irf_T,[0 xy_irf(pp,:,shock_index)],'b','LineWidth',2)
           if label_vars ==1
            xlabel(num2str(cell2mat(irf_titles(pp)))); %,'FontSize',12,'FontName', 'AvantGarde');
           end
           if label_shocks ==1 && pp==1
            title(num2str(cell2mat(strcat({'IRFs to '},zstitles(shock_index)))));
           end
        end
    end    
end


