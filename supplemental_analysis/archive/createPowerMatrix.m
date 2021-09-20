% created by Trent Dillon on May 30th 2018
% code creates power matrices for WEC, returing the matrix and showing a
% figure of the matrix

function [powermatrix] = createPowerMatrix(x0,y0,xmin,xmax,ymin,ymax,width,rated)

% other inputs
%shape (e.g. triangular)
%distribution type (rayleigh, etc.)
%xwidth versus ywidth
%peak period versus energy period
%boundary conditions

% set parameters
y = ymin:ymax; %wave height
x = xmin:xmax; %peak period

% create power matrix using Gaussian Distribution
powermatrix = zeros(ymin+length(y),xmin+length(x));

for i = 1:length(x)
    for j = 1:length(y)
        powermatrix(j+ymin,i+xmin) = rated*exp(-1*((x(i)-x0)^2+(y(j)-y0)^2)/width);
    end
end

% visualize

figure
pc = pcolor([1:xmin x],[1:ymin y],powermatrix);
colormap jet
%set(pc, 'EdgeColor', 'none'); %remove edges to better visualize
c = colorbar;
ylabel(c,'Power Produced [W]','Fontsize',20)
axis equal
axis tight
title('Artificial Power Matrix','Fontsize',20)
ylabel('Significant Wave Height [m]','Fontsize',20)
xlabel('Peak Period [s]','Fontsize',20)
set(gca,'Fontsize',20)
% hold on
% for ii=1:length(x)
%   for jj = 1:length(y)
%       text(x(ii),y(jj),num2str(powermatrix(ii,jj)))
%   end
% end
end

