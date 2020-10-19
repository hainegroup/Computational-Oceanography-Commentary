function altimeter = define_altimeter_data
% See SSH_data_history.numbers
% twnh Jul '20


fprintf(1,' Defining altimeter data...') ;
% Data
altimeter.names = {
    "Skylab"
    "GEOS-3"
    "Seasat"
    "Geosat"
    "ERS-1"
    "TOPEX/Poseidon"
    "ERS-2"
    "GFO"
    "Jason-1"
    "Envisat"
    "OSTM/Jason-2"
    "Cryosat-2"
    "Hai Yang 2A"
    "SARAL"
    "Sentinel 3"
    "Jason-3"
    "Jason-CS/Sentinel 6"
    "SWOT"} ;

altimeter.launch_date = {
    "01 May 1973"
    "09 Apr 1975"
    "27 Jun 1978"
    "12 Mar 1985"
    "17 Jul 1991"
    "10 Aug 1992"
    "21 Apr 1995"
    "10 Feb 1998"
    "07 Dec 2001"
    "01 Mar 2002"
    "20 Jun 2008"
    "08 Apr 2010"
    "16 Aug 2011"
    "25 Feb 2013"
    "16 Feb 2015"
    "27 Jan 2016"
    "01 Nov 2020"
    "01 Apr 2022"
    } ;

altimeter.decommission_date = {
    "1 Feb 1974"
    "1 Jul 1979"
    "10 Oct 1978"
    "1 Jan 1990"
    "10 Mar 2000"
    "18 Jan 2006"
    "5 Sep 2011"
    "25 Nov 2008"
    "21 Jun 2013"
    "8 Apr 2012"
    "1 Oct 2019"
    "tomorrow"
    "tomorrow"
    "tomorrow"
    "14 Feb 2023"
    "15 Feb 2021"
    "1 Nov 2023"
    "1 Apr 2025"} ;

altimeter.range_error = [
    1 ;
    0.25 ;
    0.05 ;
    0.04 ;
    0.03 ;
    0.02 ;
    0.03 ;
    0.035 ;
    0.02 ;
    0.02 ;
    0.02 ;
    0.03 ;
    0.04 ;
    0.008 ;
    0.03 ;
    0.02 ;
    0.02 ;
    0.0135
    ] ;

% Some of these are guesstimates!
altimeter.orbit_error = [
    5 ;
    5 ;
    1 ;
    0.4 ;
    0.012 ;
    0.025 ;
    0.075 ;
    0.025 ;
    0.025 ;
    0.025 ;
    0.025 ;
    0.025 ;
    0.025 ;
    0.025 ;
    0.025 ;
    0.025 ;
    0.025 ;
    0.025
    ] ;

% Period and range error normalization from T/P:
altimeter.period_normalisation = days(10) ;
altimeter.range_error_normalisation = 0.02 ;
altimeter.orbit_error_normalisation = 0.025 ;

% More than one choice of the total error:
%altimeter.total_normalized_error = sqrt(altimeter.range_error.^2 + altimeter.orbit_error.^2)./sqrt(altimeter.range_error_normalisation^2 + altimeter.orbit_error_normalisation^2) ;
%altimeter.total_normalized_error = max([altimeter.range_error./altimeter.range_error_normalisation, altimeter.orbit_error./altimeter.orbit_error_normalisation],[],2) ;
altimeter.total_normalized_error = ones(size(altimeter.range_error)) ;

altimeter.N_altimeter = numel(altimeter.launch_date) ;
for aa = 1:altimeter.N_altimeter
    altimeter.launch_datetime(aa)       = datetime(altimeter.launch_date{aa},'inputformat','dd MMM yyyy') ;
    altimeter.decommission_datetime(aa) = datetime(altimeter.decommission_date{aa},'inputformat','dd MMM yyyy') ;
end % aa
altimeter.mission_duration = altimeter.decommission_datetime - altimeter.launch_datetime ;

altimeter.times = [min(altimeter.launch_datetime):altimeter.period_normalisation:max(altimeter.decommission_datetime)] ;
TP_cycles = (altimeter.times(2) - altimeter.times(1))/altimeter.period_normalisation ;
altimeter.cycles = zeros(size(altimeter.times)) ;

% Accumulate observing/range_error period:
for tt = 1:numel(altimeter.times)
    for aa = 1:altimeter.N_altimeter
        if(altimeter.times(tt) > altimeter.launch_datetime(aa) && altimeter.times(tt) < altimeter.decommission_datetime(aa))
            altimeter.cycles(tt) =  altimeter.cycles(tt) + TP_cycles/altimeter.total_normalized_error(aa) ;
        end % if
    end % aa
end % tt

% Convert TP cycles to days
altimeter.cycles = altimeter.cycles.*10 ;

% Accumulate the number of TP equivalent cycles.
altimeter.cumsum_cycles = cumsum(altimeter.cycles) ;

fprintf(1,'done.\n') ;
end