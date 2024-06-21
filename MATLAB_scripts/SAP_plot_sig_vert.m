% Kedar Madi
% Function 1) Calculate significant vertices via one-sample Wilcoxon signed rank test
% Function 2) Plot the ROI as a point cloud of vertices, and highlight the significant
%             vertices with respect to delta_x, delta_y, delta_z, magnitude, and magnitude
%             of the normal projection

clear;
clc;

%cd('/path/to/your/working/directory/');


% Import data
template_vert = xlsread('template_vertices.csv');
file_x = xlsread('x_deltas_noCON_masks_L.csv');
file_y = xlsread('y_deltas_noCON_masks_L.csv');
file_z = xlsread('z_deltas_noCON_masks_L.csv');
file_mag = xlsread('mag_noCON_masks_L.csv');
file_magNormProj = xlsread('magNormProj_noCON_masks_L.csv');


[row, col] = size(file_mag);


% Remove first row from all the matrices
file_x(1,:) = [];
file_y(1,:) = [];
file_z(1,:) = [];
file_mag(1,:) = [];
file_magNormProj(1,:) = [];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% X-axis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Determine significance
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

p_x = [];

for i = 1:col
    
    p_x(i) = signrank(file_x(:,i));
    
end

p_x = p_x.';
p_x_fdr = mafdr(p_x);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot scatterplot with sig. vertices
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sig_points_x = []; % Initialize array of significant points

for i = 1:length(template_vert) % Loop through csv file
    
    if p_x(i,1) <= 0.05 % Determine locations/coordinates where p is less than 0.05
        
        sig_points_x(i,1) = template_vert(i,1);
        sig_points_x(i,2) = template_vert(i,2);
        sig_points_x(i,3) = template_vert(i,3);
        
    end
    
end

sig_points_x = sig_points_x(any(sig_points_x, 2), :); % Remove rows with all zeros

figure

scatter3(template_vert(:,1), template_vert(:,2), template_vert(:,3), 200, 'filled'); % 3D scatter plot

hold on

scatter3(sig_points_x(:,1), sig_points_x(:,2), sig_points_x(:,3), 300, 'filled', 'red');

hold off

title('Significance: Delta X')
xlabel('X');
ylabel('Y');
zlabel('Z');
daspect([1 1 1]); % Set aspect ratio of the axes
set(gca,'XLim',[-50 0],'YLim',[-50 0],'ZLim',[-50 10]);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Y-axis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Determine significance
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

p_y = [];

for j = 1:col
    
    p_y(j) = signrank(file_y(:,j));
    
end

p_y = p_y.';
p_y_fdr = mafdr(p_y);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot scatterplot with sig. vertices
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sig_points_y = []; % Initialize array of significant points

for i = 1:length(template_vert) % Loop through csv file
    
    if p_y(i,1) <= 0.05 % Determine locations/coordinates where p is less than 0.05
        
        sig_points_y(i,1) = template_vert(i,1);
        sig_points_y(i,2) = template_vert(i,2);
        sig_points_y(i,3) = template_vert(i,3);
        
    end
    
end

sig_points_y = sig_points_y(any(sig_points_y, 2), :); % Remove rows with all zeros

figure

scatter3(template_vert(:,1), template_vert(:,2), template_vert(:,3), 200, 'filled'); % 3D scatter plot

hold on

scatter3(sig_points_y(:,1), sig_points_y(:,2), sig_points_y(:,3), 300, 'filled', 'yellow');

hold off

title('Significance: Delta Y')
xlabel('X');
ylabel('Y');
zlabel('Z');
daspect([1 1 1]); % Set aspect ratio of the axes
set(gca,'XLim',[-50 0],'YLim',[-50 0],'ZLim',[-50 10]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Z-axis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Determine significance
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

p_z = [];

for k = 1:col
    
    p_z(k) = signrank(file_z(:,k));
    
end

p_z = p_z.';
p_z_fdr = mafdr(p_z);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot scatterplot with sig. vertices
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sig_points_z = []; % Initialize array of significant points

for i = 1:length(template_vert) % Loop through csv file
    
    if p_z(i,1) <= 0.05 % Determine locations/coordinates where p is less than 0.05
        
        sig_points_z(i,1) = template_vert(i,1);
        sig_points_z(i,2) = template_vert(i,2);
        sig_points_z(i,3) = template_vert(i,3);
        
    end
    
end

sig_points_z = sig_points_z(any(sig_points_z, 2), :); % Remove rows with all zeros

figure

scatter3(template_vert(:,1), template_vert(:,2), template_vert(:,3), 200, 'filled'); % 3D scatter plot

hold on

scatter3(sig_points_z(:,1), sig_points_z(:,2), sig_points_z(:,3), 300, 'filled', 'green');

hold off

title('Significance: Delta Z')
xlabel('X');
ylabel('Y');
zlabel('Z');
daspect([1 1 1]); % Set aspect ratio of the axes
set(gca,'XLim',[-50 0],'YLim',[-50 0],'ZLim',[-50 10]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Magnitude
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Determine significance
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

p_mag = [];

for a = 1:col
    
    p_mag(a) = signrank(file_mag(:,a));
    
end

%p_mag = p_mag.';
%p_mag_fdr = mafdr(p_mag);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Magnitude of Normal Projection
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Determine significance
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

p_magNormProj = [];

for b = 1:col
    
    p_magNormProj(b) = signrank(file_magNormProj(:,b));
    
end

p_magNormProj = p_magNormProj.';
p_magNormProj_fdr = mafdr(p_magNormProj);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot scatterplot with sig. vertices 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sig_points_magNormProj = []; % Initialize array of significant points

for i = 1:length(template_vert) % Loop through csv file
    
    if p_magNormProj(i,1) <= 0.05 % Determine locations/coordinates where p is less than 0.05
        
        sig_points_magNormProj(i,1) = template_vert(i,1);
        sig_points_magNormProj(i,2) = template_vert(i,2);
        sig_points_magNormProj(i,3) = template_vert(i,3);
        
    end
    
end

sig_points_magNormProj = sig_points_magNormProj(any(sig_points_magNormProj, 2), :); % Remove rows with all zeros

figure

scatter3(template_vert(:,1), template_vert(:,2), template_vert(:,3), 200, 'filled'); % 3D scatter plot

hold on

scatter3(sig_points_magNormProj(:,1), sig_points_magNormProj(:,2), sig_points_magNormProj(:,3), 300, 'filled', 'c');

hold off

title('Significance: Magnitude of Normal Projection')
xlabel('X');
ylabel('Y');
zlabel('Z');
daspect([1 1 1]); % Set aspect ratio of the axes
set(gca,'XLim',[-50 0],'YLim',[-50 0],'ZLim',[-50 10]);
