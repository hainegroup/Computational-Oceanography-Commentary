% Script to make the Turing test figure for the 2020 Computational
% Oceanography essay twnh Feb 06, Sep 20, Feb 21

%% Setup
close all
clear
clear global
more off
%data_src = 'ERAI' ;
data_src = 'ASR' ;
%data_src = 'IGP' ;

%% Read data
S_lims = [32 36] ;
filename = ['From Mattia Kogur/data_for_Tom/',data_src,'_mooring_like.nc'] ;
fprintf(1,' Loading OGCM data from OceanSpy file [%s]...',filename) ;
data1 = read_OGCM_survey_data(filename) ;
h1 = make_subplot(1,data1,S_lims) ;
fprintf(1,'done.\n') ;

filename = 'From Mattia Kogur/data_for_Tom/mooring.nc' ;
fprintf(1,' Loading OGCM data from OceanSpy file [%s]...',filename) ;
data2 = read_OGCM_survey_data(filename) ;
data2.Depth = data1.Depth ;
h2 = make_subplot(2,data2,S_lims) ;
fprintf(1,'done.\n') ;

% All done
orient tall
wysiwyg
print('Turing_test_hydrography.pdf','-dpdf') ;

%% Local functions
function data = read_OGCM_survey_data(filename)
% Read and process Mattia's OceanSpy survey netcdf file
%ncdisp(filename)
data.S         =  ncread(filename,'S') ;               % psu salinity
data.T         =  ncread(filename,'Temp') ;            % degC temperature
data.Sigma0    =  ncread(filename,'Sigma0') ;          % kg/m^3 density anomaly
data.ort_Vel   =  ncread(filename,'ort_Vel') ;         % m/s orthogonal current speed
data.dist_vec  =  ncread(filename,'X') ;               % km
data.Z_vec     = -ncread(filename,'Z') ;               % m
vars  = ncinfo(filename) ;
if(any(strcmp({vars.Variables.Name},'Depth')))         % Depth isn't available from data.
    data.Depth     =  ncread(filename,'Depth') ;       % m water depth
else
    data.Depth = NaN ;
end % if

% Process
[data.dist,data.Z] = ndgrid(data.dist_vec,data.Z_vec) ;

end

function h1 = make_subplot(no,data,lims)

% Extrapoloate to fill NaNs
data = fill_NaNs(data,'S') ;
data = fill_NaNs(data,'Sigma0') ;

% Interploate to high resolution grid
ND = 512 ;
NZ = 512 ;
[dist2,Z2] = ndgrid(linspace(min(data.dist(:)),max(data.dist(:)),ND),linspace(min(data.Z(:)),max(data.Z(:)),NZ)) ;
S2         = interp2(data.dist',data.Z',data.S',dist2',Z2','spline')' ;
Sigma0_2   = interp2(data.dist',data.Z',data.Sigma0',dist2',Z2','spline')' ;
Depth2     = interp1(data.dist_vec,-data.Depth,dist2(:,1),'spline') ;


h1 = subplot(2,2,no) ;
contourf(dist2,Z2,S2);
hold on
contour(dist2,Z2,Sigma0_2,[27.8 27.8],'k-','linewidth',2) ;
shading flat;
cb = colorbar('location','southoutside') ;
xlabel(cb,'Salinity [psu]')
caxis(lims)
xlabel('Distance [km]')
ylabel('Height [m]')
if(no == 2)
    set(gca,'YAxisLocation','right') ;
end % if

% Patch for bathymetry
min_Z = -1600 ;
bathy_col = 0.7.*[1 1 1] ;
patx = [dist2(:,1); flipud(dist2(:,1))] ;
paty = [Depth2; min_Z.*ones(ND,1)] ;
patch(patx,paty,bathy_col)

c_map = diverging_map(linspace(0,1,64),[0.230, 0.299, 0.754],[0.706, 0.016, 0.150]) ;
colormap(flipud(c_map)) ;

    function data = fill_NaNs(data,fld)
        
        inds1 = find( isnan(data.(fld))) ;
        inds2 = find(~isnan(data.(fld))) ;
        tmp = nanmean(data.(fld),1) ;
        tmp(isnan(tmp)) = [] ;
        deep_value = tmp(end) ;
        data.(fld)(  1,end) = deep_value ;
        data.(fld)(end,end) = deep_value ;
        F = scatteredInterpolant(data.dist(inds2),data.Z(inds2),data.(fld)(inds2)) ;
        data.(fld)(inds1) = F(data.dist(inds1),data.Z(inds1)) ;
        
    end

end