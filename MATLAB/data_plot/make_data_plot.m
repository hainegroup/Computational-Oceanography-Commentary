% Plot of deep T, altimetry, CGCM, and HPC data over time
% twnh Jul '20, Jan '21

%% Housekeeping
close all
clear
fprintf(1,'\n\n Script to read and plot deep temperature, altimetry, and CGCM data over time.\n\n') ;

%% Setup
hydrog              = read_WOD_data ;
altimeter           = define_altimeter_data ;
cgcm                = import_CGCM_file('CGCM_data_history.csv') ;
ogcm                = import_OGCM_file('OGCM_data_history.csv') ;
supercomputer       = import_supercomputer_file('supercomputer_history.csv') ;
ECMWF_NCAR_computer = import_top500_history_file('ECMWF_NCAR_supercomputer_history.csv') ;
ECMWF_archive       = load_grabit_data('grabit/Data002') ;
ECMWF_sustained_HPC = load_grabit_data('grabit/Data001') ;
SHOW_ARCHIVE        = 0 ;

%% Plot
figure

%% Temperature data
sp1 = subplot(4,1,1) ;
scatter(hydrog.times,hydrog.N_PFL,16,hydrog.PFL_color,'o','filled') ;
hold on
scatter(hydrog.times,hydrog.N_OSD,16,hydrog.OSD_color,'o','filled') ;
scatter(hydrog.times,hydrog.N_CTD,16,hydrog.CTD_color,'o','filled') ;
scatter(hydrog.times,hydrog.N_APB,16,hydrog.APB_color,'o','filled') ;
scatter(hydrog.times,hydrog.N_GLD,16,hydrog.GLD_color,'o','filled') ;
set(sp1,'XLim',[datetime(1960,1,1) datetime(2020,7,1)],'YLim',[1e3 5e6],'YAxisLocation','right') ;
fprintf(1,' Deep T cumulative number of obs.:\n') ;
[th1,~] = fit_and_plot_exponential(hydrog.times,hydrog.N_Tot) ;
%fit_and_plot_linear(hydrog.times,hydrog.N_Tot) ;
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
adjust_axes(sp1,th1,Tplot,1)

%% Altimetry
sp2 = subplot(4,1,2) ;
pos0 = get(sp1,'Position') ;
pos1 = get(sp2,'Position') ;
set(sp2,'position',[pos1(1) pos0(2)-pos1(4)-shuffle_up_delta pos1(3:4)]) ;
fit_inds = find(altimeter.times > datetime(1985,1,1)) ;
fprintf(1,' Altimetry cumulative number of cycles:\n') ;
[th2,~] = fit_and_plot_exponential(altimeter.times(fit_inds),altimeter.cumsum_cycles(fit_inds)) ;
hold on ;
%fit_and_plot_linear(altimeter.times(fit_inds),altimeter.cumsum_cycles(fit_inds)) ;
semilogy(altimeter.times,altimeter.cumsum_cycles,'k-','linewidth',2) ;
set(gca,'XLim',[datetime(1970,1,1) datetime(2020,7,1)],'YLim',[1.5e1 0.9e5],'YAxisLocation','right') ;
ylabel('Cum. observing days')
adjust_axes(sp2,th2,Tplot,1)

for aa = 1:altimeter.N_altimeter-2
    this_width = 2.5/altimeter.total_normalized_error(aa) ;
    this_y = 20*exp( datenum(altimeter.launch_datetime(aa) - altimeter.launch_datetime(1))/datenum(years(7)) ) ;
    pid(aa) = plot([altimeter.launch_datetime(aa) altimeter.decommission_datetime(aa)],[this_y this_y],'-','linewidth',this_width) ;
    this_col = get(pid(aa),'Color') ;
    altimeter.display_names{aa} = sprintf('\\color[rgb]{%f,%f,%f}%s',this_col,altimeter.names{aa}) ;
    alt_text(aa) = text(altimeter.launch_datetime(aa),this_y/8,altimeter.display_names{aa},'fontsize',6,'horizontalalignment','left','verticalalignment','bottom','rotation',0) ;
end % aa

%% IPCC CGCM and OGCM data
sp3 = subplot(4,1,3) ;
yyaxis right
pos0 = get(sp2,'Position') ;
pos1 = get(sp3,'Position') ;
set(sp3,'position',[pos1(1) pos0(2)-pos1(4)-shuffle_up_delta pos1(3:4)]) ;
fprintf(1,' IPCC CGCM number of grid points:\n') ;
[th3,~] = fit_and_plot_exponential(cgcm(:).times,cgcm(:).Ngridpts) ;
hold on ;
fprintf(1,' Bleeding-edge OGCM number of grid points:\n') ;
[th3b,pl3b] = fit_and_plot_exponential(ogcm(:).times,ogcm(:).Ngridpts) ;
scatter(cgcm(:).times,cgcm(:).Ngridpts,16,cgcm.color,'o','filled') ;
scatter(ogcm(:).times,ogcm(:).Ngridpts,24,ogcm.color,'o','filled') ;
set(gca,'XLim',[datetime(1978,1,1) datetime(2020,7,1)],'YLim',[4e3 4e10],'YColor','k') ;
ylabel('Number of grid points')
adjust_axes(sp3,th3,Tplot,2)
adjust_axes(sp3,th3b,Tplot,1)

% Add yaxis with horizontal grid scale
grid_pt_lims = get(gca,'YLim') ;
length_scale_lims = convert_grid_lims_to_length_lims(grid_pt_lims) ;
yyaxis left
set(gca,'YColor','k','YScale','log','YDir','reverse') ;
set(gca,'YLim',fliplr(length_scale_lims)) ;
ylabel('OGCM grid scale [m]') ;

%% Supercomputer data
sp4 = subplot(4,1,4) ;
if(SHOW_ARCHIVE)
    yyaxis right
end % if
pos0 = get(sp3,'Position') ;
pos1 = get(sp4,'Position') ;
set(sp4,'position',[pos1(1) pos0(2)-pos1(4)-shuffle_up_delta pos1(3:4)]) ;
fprintf(1,' Fastest HPC Rmax:\n') ;
[th4,pl4] = fit_and_plot_exponential(supercomputer.recent_times,supercomputer.recent_Speed_flops) ;
set(th4,'Color',supercomputer.color) ;
set(pl4,'Color',supercomputer.color) ;
hold on ;
scatter(supercomputer.times,supercomputer.Speed_flops,16,supercomputer.color,'o') ;
fprintf(1,' ECMWF and NCAR HPC Rmax:\n') ;
[th5,pl5] = fit_and_plot_exponential(ECMWF_NCAR_computer.recent_times,ECMWF_NCAR_computer.recent_Speed_flops) ;
scatter(ECMWF_NCAR_computer.times,ECMWF_NCAR_computer.Rmax,16,supercomputer.color,'o','filled') ;
set(gca,'XLim',[datetime(1990,1,1) datetime(2021,7,1)],'YLim',[6e10 6e17],'Ycolor',supercomputer.color) ;
set(th5,'Color',supercomputer.color) ;
set(pl5,'Color',supercomputer.color) ;
ylabel('Speed [FLOPS]')
xlabel('Year') ;
adjust_axes(sp4,th4,Tplot,1)
adjust_axes(sp4,th5,Tplot,2)
if(SHOW_ARCHIVE)
    % Plot ECMWF Archive size
    yyaxis left
    scatter(ECMWF_archive.times,ECMWF_archive.archive,16,ECMWF_archive.color,'o','filled') ;
    fprintf(1,' ECMWF Archive:\n') ;
    [th6,pl6] = fit_and_plot_exponential(ECMWF_archive.recent_times,ECMWF_archive.recent_archive) ;
    ylabel('Archive size [bytes]')
    set(gca,'XLim',[datetime(1990,1,1) datetime(2021,7,1)],'YLim',[6e10 6e17],'YColor',ECMWF_archive.color) ;
    adjust_axes(sp4,th6,Tplot,3)
    set(pl6,'Color',ECMWF_archive.color) ;
    set(th6,'Color',ECMWF_archive.color) ;
    
else
    set(gca,'YAxisLocation','right') ;
end % if

% ECMWF Sustained HPC performance. This just computes the growth times and
% then deletes the plots.
fprintf(1,' ECMWF Sustained HPC performance:\n') ;
[th7,pl7] = fit_and_plot_exponential(ECMWF_sustained_HPC.times,ECMWF_sustained_HPC.archive) ;

%% Print
orient tall
wysiwyg
print -dpdf data_history_with_annotations.pdf

% Remove text labels (easier to insert in keynote)
delete(th1) ;
delete(th2) ;
delete(th3) ;
delete(th3b) ;
delete(th4) ;
delete(th5) ;
delete(th7) ;
delete(pl7) ;
delete(alt_text(:)) ;
if(SHOW_ARCHIVE)
    delete(th6) ;
end % if

print -dpdf data_history.pdf


%% Local functions

function [th,pfit] = fit_and_plot_exponential(times,data)

% Fit exponential
inds = find(data > 0) ;
[P,~] = polyfit(datenum(times(inds)),log(data(inds)),1) ;
fit_data = exp(polyval(P,datenum(times))) ;
pfit = plot(times,fit_data,'r-','linewidth',2) ;
Tobs.growth_timescale = 1/(365.25*P(1)) ;
Tobs.doubling_timescale = Tobs.growth_timescale*log(2) ;

% Report
fprintf(1,' Exponential fit between [%s]--[%s]:\n Timescale of [%6.3f]yrs and doubling time of [%6.3f]yrs.\n\n',...
    min(times),max(times),Tobs.growth_timescale,Tobs.doubling_timescale) ;
text_str = sprintf('$\\tau_{2 \\times}$ = %3.1f yr',Tobs.doubling_timescale) ;
th = text(datetime(2008,1,1),1e3,text_str,'Color',get(pfit,'Color'),'BackgroundColor','w','interpreter','latex') ;

end

function pfit = fit_and_plot_linear(times,data)
% For response to reviewer 2. Remove comments in main code to make linear fits.

% Fit linear
inds = find(data > 0) ;
[P,~] = polyfit(datenum(times(inds)),data(inds),1) ;
fit_data = polyval(P,datenum(times)) ;
pfit = plot(times,fit_data,'m-','linewidth',2) ;

end

function adjust_axes(handle,thandle,Tplot,flag)

tmpx = get(handle,'XLim') ;
tmpy = get(handle,'YLim') ;
pos = get(handle,'position') ;
width = years(tmpx(2)-tmpx(1))*Tplot.width_per_time ;
height = (log10(tmpy(2)) - log10(tmpy(1)))*Tplot.height_per_decade ;
set(handle,'position',[pos(1)+pos(3) - width, pos(2)+pos(4) - height, width, height]) ;

% Adjust annotation position. Remember the Xaxis is a ruler (datetime) axis!
switch(flag)
    case 1      % Upper middle
        tmp = [ruler2num(datetime(1993,1,1),handle.XAxis), 10^(log10(tmpy(1))+(log10(tmpy(2)) - log10(tmpy(1)))*0.83), 0] ;
    case 2      % Lower right
        tmp = [ruler2num(datetime(2010,1,1),handle.XAxis), 10^(log10(tmpy(1))+(log10(tmpy(2)) - log10(tmpy(1)))*0.10), 0] ;
    case 3          % Top
        tmp = [ruler2num(datetime(1993,1,1),handle.XAxis), 10^(log10(tmpy(1))+(log10(tmpy(2)) - log10(tmpy(1)))*0.90), 0] ;
end % switch
set(thandle,'position',tmp,'fontsize',10,'margin',2) ;
set(handle,'YTick',10.^(0:1:20),'YScale','log') ;
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

function data = load_grabit_data(filename)
% Get data from ECMWF Archive slide via grabit

grabit_data = load(filename) ;
flds = fieldnames(grabit_data) ;
fld = flds{1} ;
data.times   = datetime(grabit_data.(fld)(:,1)*365.25,'ConvertFrom','datenum') ;
data.archive = 10.^(12 + grabit_data.(fld)(:,2)) ;           % Units of archive on slide are TB. This converts to bytes

% For exponential fit
inds               = year(data.times) > 1990 ;
data.recent_times  = data.times(      inds) ;
data.recent_archive = data.archive(inds) ;

data.color  = [ 0.8500 0.3250 0.0980 ] ;

end

function out = convert_grid_lims_to_length_lims(in)

R_E      = 6400e3 ;      % Earth radius
alpha    = 0.7 ;         % Fraction of globe covered in ocean
N_Nz_exp = 1/5 ;         % Scaling exponent for dependence of vertical levels on total number of grid points.

out = 2*R_E*sqrt(pi*alpha).*in.^((N_Nz_exp-1)/2) ;

end