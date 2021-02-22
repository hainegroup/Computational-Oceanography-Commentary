% Pedagogical frequency wavenumber diagram
% twnh Sep 08, Aug '11
% Oct '19 Add the Poseidon run. And LES patch.
% Jul '20 Adapt for Computational Oceanography commentary paper

%% Setup
close all
clear
clear global
more off

secs_in_a_day = 86400 ;
secs_in_a_hr  = 3600 ;
secs_in_a_yr  = secs_in_a_day * 365.25 ;
secs_in_age_of_Earth = secs_in_a_yr*4.5e9 ;
gravity = 9.81 ;
depths = [4800, 0.26, 0.082] ;
rho = 1025 ;
fcori = 1e-4 ; % s^-1
Nth=sqrt((10/1020)*(5/250));
Nabyss=sqrt((10/1020)*(.5/2500));

L = 10.^(-3:0.05:7.5) ; % m
T = 10.^(0:0.05:10) ; % s
k = 2*pi./L ;
f = 2*pi./T ;

large_font = 12 ;
transp = 0.7 ;

% Colours from : https://colorbrewer2.org/?type=diverging&scheme=BrBG&n=4
LES_col      = [166, 97, 26]./256 ;
turb_col     = [223,194,125]./256 ;
TAR_col      = [0.0000 0.4470 0.7410] ;     % Matches TAR color in import_CGCM_file.m
AR6_col      = [128,205,193]./256 ;         % Matches AR6 color in import_CGCM_file.m
Poseidon_col = [  1,133,113]./256 ;

%% Plot
figure
set(gca,'XScale','log') ;
set(gca,'YScale','log') ;
set(gca,'FontSize',large_font) ;
set(gca,'XLim',[min(L) max(L)]) ;
set(gca,'YLim',[min(T) max(T)]) ;
set(gca,'XMinortick','off')
set(gca,'YMinortick','off')
original = gca ;
hold on

% Futz grid and labels.
grid on
set(gca,'XMinorgrid','off')
set(gca,'YMinorgrid','off')

% Dissipation scale. Thorpe, p26
Kolmogorov_scale = [6e-5 1e-2] ;
x_dat = [Kolmogorov_scale(1); Kolmogorov_scale(1); Kolmogorov_scale(2); Kolmogorov_scale(2)] ;
y_dat = [min(T); max(T); max(T); min(T)] ;
f1 = fill(x_dat, y_dat, [0.4 0.4 0.4]) ;

% Basin modes.  From Willebrand et al. 1980 and Zhang et al 2005.
x_dat = [Kolmogorov_scale(2); max(L); max(L); Kolmogorov_scale(2)] ;
y_dat = [50; 50;  8;  8].*secs_in_a_day ;
f2 = fill(x_dat, y_dat, [0.9 0.9 0.9]) ;

% Thermocline depth.
Th_scale = [900 2500] ;
x_dat = [Th_scale(1); Th_scale(1); Th_scale(2); Th_scale(2)] ;
y_dat = [min(T); max(T); max(T); min(T)] ;
f4 = fill(x_dat, y_dat, [0.9 0.9 0.9]) ;

% Mixed layer.
ML_scale = [10 200] ;
x_dat = [ML_scale(1); ML_scale(1); ML_scale(2); ML_scale(2)] ;
y_dat = [min(T); max(T); max(T); min(T)] ;
f5 = fill(x_dat, y_dat, [0.9 0.9 0.9]) ;

% Volume accessible with computer.
% LES volume.
x_dat = [1.1 1000 1000 1.1]; y_dat = [1.1 1.1 3600 3600] ;
f6a = fill(x_dat, y_dat,LES_col,'FaceAlpha',transp) ;

% Charles M. says forced turbulent simulations are at ~4000^3 with similar order of
% timesteps. The JHU turbulence database is at 1024^4 (2017; http://turbulence.pha.jhu.edu/). See also Li et al. (Phys Fluid-Dyn. 2008).
x_dat = [min(L)*1.1 min(L)*1000 min(L)*1000 min(L)*1.1]; y_dat = [min(T)*1.1 min(T)*1.1 min(T)*1000 min(T)*1000] ;
f6 = fill(x_dat, y_dat,turb_col,'FaceAlpha',transp) ;

% Deformation radii - taken from Barry's scales.m  July 2012.
RDextmin=sqrt(10*4000)/(fcori*sin(pi*67.5/180));
RDextmax=sqrt(10*6000)/(fcori*sin(pi*23.5/180));
fx1=RDextmin; fx2=RDextmax; fy1=1; fy2=1e10;
fill([fx1 fx2 fx2 fx1 fx1],[fy1 fy1 fy2 fy2 fy1],[.4 .4 .4])
RDintmin=sqrt(10*500*(1/1000))/fcori;
RDintmax=sqrt(10*500*(8/1000))/(fcori*sin(pi*23.5/180));
fx1=RDintmin; fx2=RDintmax; fy1=1; fy2=1e10;
fill([fx1 fx2 fx2 fx1 fx1],[fy1 fy1 fy2 fy2 fy1],[.4 .4 .4])

% TAR DOE PCM run. See CGCM_data_history.numbers
x_dat = [73.7e3 max(L)*0.9 max(L)*0.9 73.7e3]; y_dat = [4*3600 4*3600 150*secs_in_a_yr 150*secs_in_a_yr] ;
f8 = fill(x_dat, y_dat,TAR_col,'FaceAlpha',transp) ;

% HighResMIP AR6 HadGEM3-GC31-HH run. See Roberts et al. (2019)
x_dat = [7e3 max(L)*0.9 max(L)*0.9 7e3]; y_dat = [4*3600 4*3600 100*secs_in_a_yr 100*secs_in_a_yr] ;
f7 = fill(x_dat, y_dat,AR6_col,'FaceAlpha',transp) ;

% Poseidon run
x_dat = [1e3 max(L)*0.9 max(L)*0.9 1e3]; y_dat = [3*3600 3*3600 86400*365 86400*365] ;
f5 = fill(x_dat, y_dat,Poseidon_col,'FaceAlpha',transp) ;

% Internal inertia-gravity waves. This dispersion relation ASSUMES N is uniform!!!!  Thorpe p.53.
m = pi/depths(1) ;
omega = sqrt((Nth^2.*k.^2 + fcori^2*m^2)./(k.^2 + m^2)) ;
p1 = plot(2*pi./k,2*pi./omega,'-','linewidth',1.5) ;
omega = sqrt((Nabyss^2.*k.^2 + fcori^2*m^2)./(k.^2 + m^2)) ;
p2 = plot(2*pi./k,2*pi./omega,'-','linewidth',1.5) ;

% Surface capillary-gravity waves. Lighthill p215, 223.
sfc_T = 0.074 ; % N/m.
omega = sqrt(fcori^2 + (gravity + (sfc_T.*k.^2)./rho).*k.*tanh(k.*depths(1))) ;   % MY GUESS FOR DISPERSION RELATION!!!!!  Lighthill has no Coriolis force!!!
p3 = plot(2*pi./k,2*pi./omega,'-','linewidth',1.5) ;

% Rossby waves
beta = 2*7.27e-5/6371e3 ;    % Equatorial value
for ii = 1:3
    omega = k.*(beta./(k.^2 + fcori^2/(gravity*depths(ii)))) ;
    p4(ii) = plot(2*pi./k,2*pi./omega,'-','linewidth',1.5) ;
end % ii

% Diffusion times. From Carl's suggestion in email 11Jul17
diff_coeffs = [1e-6; 1.4e-7; 1.5e-9] ;      % From Table B.4 (originally from Gill)
for dd = 1:length(diff_coeffs)
    diff_times = L.^2 ./ diff_coeffs(dd) ;
    p5(dd) = plot(L,diff_times,'-','linewidth',1.5) ;
end % dd

% Size of ocean basins
Pac_basin_width = 20000*1e3 ;
p6 = plot([Pac_basin_width Pac_basin_width],[min(T) max(T)],'--','linewidth',1.5) ;
p7 = plot([depths(1) depths(1)],[min(T) max(T)],'--','linewidth',1.5) ;

% Tidal frequencies. OU book, p 71.
off1 = 2 ;
M2_period = 12.42 * secs_in_a_hr ;
p8 = plot([Kolmogorov_scale(2) max(L)],[M2_period M2_period],'--','linewidth',1.5) ;

% Buoyancy frequency
p9 = plot([.001 2e7],(2*pi)/Nth*[1 1],'--','linewidth',1.5) ;
p10 = plot([.001 2e7],(2*pi)/Nabyss*[1 1],'--','linewidth',1.5) ;

% Coriolis frequency
p11 = plot([Kolmogorov_scale(2) max(L)],[2*pi/fcori 2*pi/fcori],'--','linewidth',1.5) ;

%% Futz and finish
set(original,'Box','on');
uistack([p1 p2 p3 p4 p6 p7 p8 p11],'top') ;
uistack([p9 p10],'top') ;

print -dpdf scales_diagram.pdf