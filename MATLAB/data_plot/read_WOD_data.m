function data = read_WOD_data
% Function to read WOD data based on OC3D Fig. 1.5
% twnh Jul '20

fprintf(1,' Reading WOD datafiles for deep hydrographic stations...') ;
edges = datetime(1800:1:2021,1,1)' ;
data.times = edges(1:end-1) + years/2 ;
yearAPB    = datetime(datevec(ncread('WOD_data_16Jul20/ocldb1594819461.8958.APB.nc','time')  + datenum(1770,1,1))) ;
yearCTD    = datetime(datevec(ncread('WOD_data_16Jul20/ocldb1594819461.8958.CTD.nc','time')  + datenum(1770,1,1))) ;
yearGLD    = datetime(datevec(ncread('WOD_data_16Jul20/ocldb1594819461.8958.GLD.nc','time')  + datenum(1770,1,1))) ;
yearOSD    = datetime(datevec(ncread('WOD_data_16Jul20/ocldb1594819461.8958.OSD.nc','time')  + datenum(1770,1,1))) ;
yearPFL1   = datetime(datevec(ncread('WOD_data_16Jul20/ocldb1594819461.8958.PFL.nc','time')  + datenum(1770,1,1))) ;
yearPFL2   = datetime(datevec(ncread('WOD_data_16Jul20/ocldb1594819461.8958.PFL2.nc','time') + datenum(1770,1,1))) ;
yearPFL    = [yearPFL1;yearPFL2] ;
data.N_APB = cumsum(histcounts(yearAPB(:,1),edges)') ;
data.N_CTD = cumsum(histcounts(yearCTD(:,1),edges)') ;
data.N_GLD = cumsum(histcounts(yearGLD(:,1),edges)') ;
data.N_OSD = cumsum(histcounts(yearOSD(:,1),edges)') ;
data.N_PFL = cumsum(histcounts(yearPFL(:,1),edges)') ;
data.N_Tot = data.N_APB+data.N_CTD+data.N_GLD+data.N_OSD+data.N_PFL ;

data.APB_colour = [0.0000 0.4470 0.7410] ;
data.CTD_colour = [0.8500 0.3250 0.0980] ;
data.GLD_colour = [0.9290 0.6940 0.1250] ;
data.OSD_colour = [0.4940 0.1840 0.5560] ;
data.PFL_colour = [0.4660 0.6740 0.1880] ;
%data.Tot_colour = [0.6350 0.0780 0.1840] ;
data.Tot_colour = [128,205,193]./256 ;         % To match the scales diagram colour ;

fprintf(1,'done.\n') ;

end