% Adapted from Atousa's code for Saberi et al. Figure 4.

clear
close all

load('From Atousa/fig4data.mat');
% save fig4data.mat lons_bathy lats_bathy depth...
%     model_p_favorite_idx f_lons f_lats f_insitu_TT...
%     X Y Rafos_release_Tidx sim_length ismember_flt_idx_2ndbatch...
%     P T flts beginindex endidx timee
%

Rafos_color = [ 0.8500 0.3250 0.0980 ] ;
start_color = [ 0.4660 0.6740 0.1880 ] ;
Model_color = [ 0.9290 0.6940 0.1250 ] ;
%Model_color=Rafos_color ;
line_wid = 1 ;

N_Rafos = sum(ismember_flt_idx_2ndbatch) ;
N_model = size(f_lons,1) ;
model_inds = round(rand(N_Rafos,1)*N_model) ;

% Plot bathymetry
figure
contourf(lons_bathy,lats_bathy,log10(depth)','edgecolor','none');
colormap('gray');
hold on ;
p1 = gca ;

% Plot trajectories
for ff = 1:numel(model_inds)
    h1=plot(f_lons(model_inds(ff),:),f_lats(model_inds(ff),:),'-','linewidth',line_wid,'Color',Model_color);
%    plot(f_lons(model_inds(ff),1),f_lats(model_inds(ff),1),'.','Color',start_color);
end % ff
h2=plot(X(Rafos_release_Tidx:Rafos_release_Tidx+sim_length*4-1,ismember_flt_idx_2ndbatch),Y(Rafos_release_Tidx:Rafos_release_Tidx+sim_length*4-1,ismember_flt_idx_2ndbatch),'-','linewidth',line_wid,'Color',Rafos_color);
%plot(X(Rafos_release_Tidx,ismember_flt_idx_2ndbatch),Y(Rafos_release_Tidx,ismember_flt_idx_2ndbatch),'.','Color',start_color);

% Futz
xlabel('Longitude [$^{\rm o}$E]','interpreter','latex');
ylabel('Latitude [$^{\rm o}$N]','interpreter','latex');
set(p1,'FontSize',12);
xlims = [-27 -12];
ylims = [65 72.5];
xlim(p1,xlims)
ylim(p1,ylims)
asrat = (ylims(2) - ylims(1))/((xlims(2) - xlims(1))*cosd(mean(ylims))) ;
pbaspect(p1,[1 asrat 1]);

cb1 = colorbar('location','southoutside');
set(cb1,'YTick',log10([10 20 30 50 100 200 300 500 1000 2000 3000]),'Fontsize',8);
cb1.TickLabelInterpreter = 'tex';
ticks1_value = get(cb1,'YTick');
ticks1_label=10.^(ticks1_value);
set(cb1,'YTickLabel',ticks1_label);
ylabel(cb1,'Depth [m]');

% Wrap up
set(gcf,'Renderer','painters') ;
print -dpdf Turing_test_float_trajectories.pdf
