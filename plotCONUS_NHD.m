function [ax2] = plotCONUS( in_grid,ax,latlim,lonlim,low_lim,up_lim,my_title)
% in_grid is gridded data you want to plot
%   NOTE: the grid must be "upside-down" to plot correctly i.e. flipped
% low_lim and up_lim are the lower and upper limits for the colorbar
% latbound and lonbound are latitude and longitude boundaries for plotting
%   (e.g. [25 53],[-125 -67] gets you the NLDAS grid domain)
% my_title is a string label for the colorbar
% in_grid = x_grid;
% latlim = [31 50];
% lonlim = [-125 -103];
% low_lim = -500;
% up_lim = 500;
% my_title = '';

just_plot=1;
% flip input from my format
[r,c]=size(in_grid);
flip_grid(1:r,:)=in_grid(r:-1:1,:);

latFull = 25.0625:0.125:52.9375;
lonFull = -124.9375:0.125:-67.0625;
%ax2 = worldmap(latlim,lonlim);

states = shaperead('usastatehi',...
        'UseGeoCoords', true, 'BoundingBox', [lonlim', latlim']);
t=surfm(latlim,lonlim,flip_grid);
g=geoshow(ax2, states,'FaceColor','none');

colormap(ax,flipud(parula(20)))
caxis([low_lim up_lim])


set(gca,'fontsize',14);
h = colorbar;
set(h,'fontsize',14)
label(h,my_title);
