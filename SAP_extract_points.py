# Function: A simple .py script to take "procalign.vtk" output files from SlicerSALT's SPHARM-PDM computation and extract the 3D Cartesian coordinates of the VTK model's vertices into CSV files. Originally written to be executed in Windows.

from msilib.schema import Directory
import numpy as np
import vtk
from vtk.util.numpy_support import vtk_to_numpy
import pandas
import os
import slicer
import pandas as pd
import reader
from os import listdir
from os.path import isfile, join
import re
import glob

####################################################################################################

# User-defined variables

input_dir = r"K:\\path\to\directory\containing\VTK\files"

output_dir = r"K:\\path\to\output\directory"

####################################################################################################

print("\nBeginning program...\n")

os.chdir(input_dir) # Change directory to input_dir

for filename in glob.glob("*procalign.vtk"):
    
    # Get subject ID, ses
    filename_parts = filename.split('_')
    subj_id = filename_parts[0]
    ses = filename_parts[1]
    ses = ses.split('-')
    ses = ses[1]

    print("\nSubject ID: " + subj_id)
    print("\nSession date:" + ses)

    reader = vtk.vtkPolyDataReader()
    reader.SetFileName(filename)
    reader.Update()

    polydata = reader.GetOutput()

    points = polydata.GetPoints()
    points_array = points.GetData()
    numpy_nodes = vtk_to_numpy(points_array)

    print("\n")
    print(numpy_nodes)

    data_frame = pd.DataFrame(numpy_nodes)
    os.chdir(output_dir)
    data_frame.to_csv(subj_id + "_" + ses + "_vertices.csv", index=False)
    os.chdir(input_dir)