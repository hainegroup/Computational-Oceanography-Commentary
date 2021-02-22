% Script to make the Turing test figure for the 2020 Computational
% Oceanography essay twnh Feb 06, Sep 20.

close all
clear
clear global
more off
run_id = 'run5c' ;    % Production expt.
fprintf(1,' Using expt.: [%s].\n\n',run_id) ;

% Indices into sections: Fine tune these indices to get the optimal
% correlation resulting from this code. Then hard code the values in
% map_correlate_eta_transport.m
transport_start_ind = 1 ;
transport_end_ind   = 43 ;  % 43 is used in Haine et al. QJRMS GFDEx paper.

% Load data series
fprintf(1,' Loading data series (produced by: make_transport_timeseries.m and digitize_Bruce95_Fig7.m)...') ;
load Digitize_Bruce95_Fig7
ross_times = scaled_x ;
ross_days  = max(ross_times) - min(ross_times) ;
ross_flux  = scaled_y ;

% Consider a subset of the iterations available.
load('DSS_transport_timeseries','cum_mass_flux_series','mass_flux_series','iters') ;
iters_subset   = (44640:144:144*length(mass_flux_series))' ;  % Avoid spinup. This gives better correlations.  44640 is 3Nov03.
start_date     = datenum(2003,6,1,0,0,0) ;
deltat         = 300 ;
times          = (iters_subset*deltat)/86400 + start_date ;
inds           = interp1(iters,1:length(iters),iters_subset) ;
DSS_transports = cum_mass_flux_series(inds,transport_end_ind) - cum_mass_flux_series(inds,transport_start_ind) ;
%random_start_date = times(round(length(times)*rand(1,1))) ;
random_start_date = times(429) ;
model_inds     =  find(times >= random_start_date & times <= random_start_date+ross_days) ;
DSS_transports = DSS_transports(model_inds) ;
times          = times(model_inds) ;

fprintf(1,'done.\n\n') ;

%% Process timeseries so they're sampled the same way
std_times  = (0:1/24:ross_days)' ;
std_Deltat = mean(diff(times))*2 ;
ross_flux  = process_timeseries(ross_times,ross_flux,std_times,std_Deltat) ;
OGCM_flux  = process_timeseries(     times,DSS_transports,std_times,std_Deltat) ;

%% Turing test figure

figure
% Plot OGCM DSS fluxes
h1 = axes('Position',[0.10 0.7137 0.35 0.2113]) ;
plot(std_times,OGCM_flux,'k-','linewidth',2) ; 
hold on
axis([min(std_times) max(std_times) -12 2]) ;

datetick('x','dd','keeplimits')
xlabel('Day')
ylabel('DSO flux [Sv]')
model_mean = mean(OGCM_flux) ;
model_std  =  std(OGCM_flux) ;
txt_str = sprintf('Avg. flux = %4.2f $\\pm$ %4.2f Sv',model_mean,model_std) ;
text(std_times(1)+7,-10,txt_str,'interpreter','latex','backgroundcolor','w')
grid on
title('Model')

% Plot Ross DSS fluxes
pos_h1 = get(h1,'Position') ;
this_gca = axes('position',[pos_h1(1)+0.37 pos_h1(2) pos_h1(3) pos_h1(4)]) ;
plot(std_times,ross_flux,'k-','linewidth',2) ;
hold on
set(this_gca,'XLim',get(h1,'XLim'),'YLim',get(h1,'YLim')) ;
datetick('x','dd','keeplimits')
xlabel('Day')
ylabel('DSO flux [Sv]')
set(gca,'YAxisLocation','right')
ross_mean = mean(ross_flux) ;
ross_std  =  std(ross_flux) ;
txt_str = sprintf('Avg. flux = %4.2f $\\pm$ %4.2f Sv',ross_mean,ross_std) ;
text(std_times(1)+7,-10,txt_str,'interpreter','latex','backgroundcolor','w')
grid on
title('Data')

% All done
%orient tall
%wysiwyg
print('Turing_test_DSO_overflow.pdf','-dpdf') ;

%% Local functions

function flux = process_timeseries(time_in,flux_in,std_times,std_Deltat) 
% Sample the input timeseries at std_Deltat intervals then interpolate onto
% std_times

time_in = time_in - time_in(1) ;
[time_in,inds,~] = unique(time_in) ;
flux_in        = flux_in(inds) ;
resample_times = (std_times(1):std_Deltat:std_times(end))' ;

resample_flux = interp1(time_in,flux_in,resample_times) ;
flux = interp1(resample_times,resample_flux,std_times,'pchip') ;

end