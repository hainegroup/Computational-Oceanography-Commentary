% Plot of deep T, altimetry, and CGCM data over time
% twnh Jul '20

%% Housekeeping
close all
clear
fprintf(1,'\n\n Script to read and plot deep temperature, altimetry, and CGCM data over time.\n\n') ;

%% Setup
hydrog        = read_WOD_data ;
altimeter     = define_altimeter_data ;
ogcm          = import_CGCM_file('CGCM_data_history.csv') ;
supercomputer = import_supercomputer_file('supercomputer_history.csv') ;

%% Plot
figure

%% Temperature data
sp1 = subplot(4,1,1) ;
scatter(hydrog.times,hydrog.N_PFL,16,hydrog.PFL_colour,'o','filled') ;
hold on
scatter(hydrog.times,hydrog.N_OSD,16,hydrog.OSD_colour,'o','filled') ;
scatter(hydrog.times,hydrog.N_CTD,16,hydrog.CTD_colour,'o','filled') ;
scatter(hydrog.times,hydrog.N_APB,16,hydrog.APB_colour,'o','filled') ;
scatter(hydrog.times,hydrog.N_GLD,16,hydrog.GLD_colour,'o','filled') ;
set(sp1,'XLim',[datetime(1960,1,1) datetime(2020,7,1)],'YLim',[1e3 5e6]) ;
th1 = fit_and_plot_exponential(hydrog.times,hydrog.N_Tot) ;
semilogy(hydrog.times,hydrog.N_Tot,'k-','linewidth',2) ;
ylabel('Cum. observations')
shuffle_up_delta = 0.02 ;
pos = get(sp1,'Position') ;
set(sp1,'Position',[pos(1)+0.2,pos(2) - shuffle_up_delta,pos(3)-0.2,pos(4) - shuffle_up_delta]) ;   % Adjust position and size of subplot

% Compute scaling of subplot for the other subplots.
tmp  = get(gca,'Position') ;
tmpx = get(gca,'XLim') ;
tmpy = get(gca,'YLim') ;
Tplot.width_per_time = tmp(3)/years(tmpx(2) - tmpx(1)) ;
Tplot.height_per_decade = tmp(4)/(log10(tmpy(2)) - log10(tmpy(1))) ;
adjust_axes(sp1,th1,Tplot)

%% Altimetry
sp2 = subplot(4,1,2) ;
pos0 = get(sp1,'Position') ;
pos1 = get(sp2,'Position') ;
set(sp2,'position',[pos1(1) pos0(2)-pos1(4)-shuffle_up_delta pos1(3:4)]) ;
fit_inds = find(altimeter.times > datetime(1985,1,1)) ;
th2 = fit_and_plot_exponential(altimeter.times(fit_inds),altimeter.cumsum_cycles(fit_inds)) ;
hold on ;
semilogy(altimeter.times,altimeter.cumsum_cycles,'k-','linewidth',2) ;
set(gca,'XLim',[datetime(1970,1,1) datetime(2020,7,1)],'YLim',[1.5e1 0.9e5]) ;
ylabel('Cum. observing days')
adjust_axes(sp2,th2,Tplot)

for aa = 1:altimeter.N_altimeter-2
    this_width = 2.5/altimeter.total_normalized_error(aa) ;
    this_y = 20*exp( datenum(altimeter.launch_datetime(aa) - altimeter.launch_datetime(1))/datenum(years(7)) ) ;
    pid(aa) = plot([altimeter.launch_datetime(aa) altimeter.decommission_datetime(aa)],[this_y this_y],'-','linewidth',this_width) ;
    %this_col = get(pid(aa),'Color') ;
    %altimeter.display_names{aa} = sprintf('\\color[rgb]{%f,%f,%f}%s',this_col,altimeter.names{aa}) ;
    %text(altimeter.launch_datetime(aa),this_y/8,altimeter.display_names{aa},'fontsize',6,'horizontalalignment','left','verticalalignment','bottom','rotation',0) ;
end % aa

%% IPCC CGCM data
sp3 = subplot(4,1,3) ;
pos0 = get(sp2,'Position') ;
pos1 = get(sp3,'Position') ;
set(sp3,'position',[pos1(1) pos0(2)-pos1(4)-shuffle_up_delta pos1(3:4)]) ;
th3 = fit_and_plot_exponential(ogcm(:).times,ogcm(:).Ngridpts) ;
%th3b = fit_and_plot_exponential(ogcm(:).assessment_best_times,ogcm(:).assessment_best_Ngridpts) ;
hold on ;
scatter(ogcm(:).times,ogcm(:).Ngridpts,16,ogcm.colour,'o','filled') ;
set(gca,'XLim',[datetime(1985,1,1) datetime(2020,7,1)],'YLim',[4e3 2e9]) ;
for rr = 1:numel(ogcm.assessment_names)
    %text(ogcm.assessment_times(rr),3e3,ogcm.assessment_names(rr),'color',ogcm.assessment_colours(rr,:),'BackgroundColor','w','HorizontalAlignment','center') ;
end % rr
ylabel('Number of grid points')
adjust_axes(sp3,th3,Tplot)

%% Supercomputer data
sp4 = subplot(4,1,4) ;
pos0 = get(sp3,'Position') ;
pos1 = get(sp4,'Position') ;
set(sp4,'position',[pos1(1) pos0(2)-pos1(4)-shuffle_up_delta pos1(3:4)]) ;
th4 = fit_and_plot_exponential(supercomputer.recent_times,supercomputer.recent_Speed_flops) ;
hold on ;
scatter(supercomputer.times,supercomputer.Speed_flops,16,supercomputer.colour,'o','filled') ;
set(gca,'XLim',[datetime(1990,1,1) datetime(2021,7,1)],'YLim',[6e10 6e17]) ;
ylabel('Speed [FLOPS]')
xlabel('Year') ;
adjust_axes(sp4,th4,Tplot)


%% Print
orient tall
wysiwyg
print -dpdf data_history.pdf

%% Local functions

function th = fit_and_plot_exponential(times,data)

% Fit exponential
inds = find(data > 0) ;
[P,~] = polyfit(datenum(times(inds)),log(data(inds)),1) ;
fit_data = exp(polyval(P,datenum(times))) ;
pfit = plot(times,fit_data,'r-','linewidth',2) ;
Tobs.growth_timescale = 1/(365*P(1)) ;
Tobs.doubling_timescale = Tobs.growth_timescale*log(2) ;

% Report
fprintf(1,' Exponential fit between [%s]--[%s]:\n Timescale of [%6.3f]yrs and doubling time of [%6.3f]yrs.\n\n',...
    min(times),max(times),Tobs.growth_timescale,Tobs.doubling_timescale) ;
text_str = sprintf('Doubling time = %3.1f yr',Tobs.doubling_timescale) ;
th = text(datetime(2008,1,1),1e3,text_str,'Color',get(pfit,'Color'),'BackgroundColor','w') ;

end

function adjust_axes(handle,thandle,Tplot)

tmpx = get(handle,'XLim') ;
tmpy = get(handle,'YLim') ;
pos = get(handle,'position') ;
width = years(tmpx(2)-tmpx(1))*Tplot.width_per_time ;
height = (log10(tmpy(2)) - log10(tmpy(1)))*Tplot.height_per_decade ;
set(handle,'position',[pos(1)+pos(3) - width, pos(2)+pos(4) - height, width, height]) ;
tmp = [ruler2num(tmpx(1)+years(2.5),handle.XAxis), 10^(log10(tmpy(1))+(log10(tmpy(2)) - log10(tmpy(1)))*0.9), 0] ;      % Position of annotation
set(thandle,'position',tmp,'fontsize',9) ;
set(handle,'YTick',10.^(0:1:20),'YScale','log','YAxisLocation','right') ;
grid on
set(handle,'box','on') ;
set(handle,'Fontsize',9) 
h = get(handle,'xlabel') ;
set(h,'fontsize',11) ;
h = get(handle,'ylabel') ;
set(h,'fontsize',11) ;
xtix = (1900:10:2030)' ;
Ntix = numel(xtix) ;
xtix = [xtix, ones(Ntix,1), ones(Ntix,1)] ;
set(handle,'XTick',datetime(xtix)) ;

end