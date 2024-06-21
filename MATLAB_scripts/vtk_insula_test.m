% test

clc
clear

%addpath('C:\Users\kmadi\AppData\Roaming\MathWorks\MATLAB Add-Ons\Collections\vtkToolbox');

my_vtk = 'L_insula.vtk';

%vtkReader = vtkRead(filename);

vtkReader = readVTK(my_vtk);

x = vtkReader.points(:,1);
y = vtkReader.points(:,2);
z = vtkReader.points(:,3);

%nodes = vtkReader.points;
%elements = vtkReader.fieldData;

scatter3(x,y,z);
daspect([1 1 1])

disp('Done.');