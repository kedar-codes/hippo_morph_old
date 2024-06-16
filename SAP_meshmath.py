# Function: a .py script that executes 3D Slicer's/SlicerSALT's hidden "MeshMath" tool to calculate the normal projections of the distance vectors between two VTK models (each representing the same subject's hippocampus at two points in time).
# Note: "meshmath.exe" has largely been replaced by 3D Slicer's/SlicerSALT's "ModelToModelDistance" module. This script allows most of the same functionality to be run in a command line interface. Additionally, the "magNormDir" (normal projection of distance vectors) option is only available through MeshMath.
# Note: This script was originally meant to be executed in a Windows environment.

import numpy as np
import vtk
import pandas
import os
import slicer
import pandas as pd
from os import listdir
from os.path import isfile, join
import re
import glob
import subprocess

output_dir = r"K:\\output\directory\path"

# Declare timepoint 1/2 season paths 
timepoint1_path = r"K:\\path\to\directory\containing\timepoint1\VTK\models"
timepoint2_path = r"K:\\path\to\directory\containing\timepoint2\VTK\models"

# Initialize subject pairs array
subject_pairs = np.array([])

# Get subject ID, session from timepoint 1 files
os.chdir(timepoint1_path)

# Loop through timepoint 1 directory to obtain .vtk files
for tp1_file in glob.glob("*procalign.vtk"):
    
    # Get file, subject ID, ses
    tp1_fullpath = (timepoint1_path + "\\" + tp1_file)
    filename_tp1_parts = tp1_file.split('_')
    subj_id_tp1 = filename_tp1_parts[0]
    ses_tp1 = filename_tp1_parts[1]
    ses_tp1 = ses_tp1.split('-')
    ses_tp1 = ses_tp1[1]

    # Store above variables in a dictionary "array"
    d1 = {'tp1_fullpath': tp1_fullpath, 'subj_id_tp1': subj_id_tp1, 'ses_tp1': ses_tp1}

    # Use VTK2Meta tool to convert .vtk to .meta file
    tp1_metapath = os.path.splitext(tp1_fullpath)[0] + '.meta' # Change file extension to .meta
    #subprocess.run(['C:\\Program Files\\SlicerSALT 3.0.0\\bin\VTK2Meta.exe', tp1_fullpath, tp1_metapath])

    os.chdir(timepoint2_path)

    # Loop through timepoint 2 directory and repeat the above steps
    for tp2_file in glob.glob("*procalign.vtk"):

        tp2_fullpath = (timepoint2_path + "\\" + tp2_file)
        filename_tp2_parts = tp2_file.split('_')
        subj_id_tp2 = filename_tp2_parts[0]
        ses_tp2 = filename_tp2_parts[1]
        ses_tp2 = ses_tp2.split('-')
        ses_tp2 = ses_tp2[1]


        d2 = {'tp2_fullpath': tp2_fullpath, 'subj_id_tp2': subj_id_tp2, 'ses_tp2': ses_tp2}

        # Use VTK2Meta tool to convert .vtk to .meta file
        tp2_metapath = os.path.splitext(tp2_fullpath)[0] + '.meta' # Change file extension to .meta
        #subprocess.run(['C:\\Program Files\\SlicerSALT 3.0.0\\bin\VTK2Meta.exe', tp2_fullpath, tp2_metapath])

        if d1.get('subj_id_tp1') == d2.get('subj_id_tp2'):

            print("\nMATCH")
            print("File 1: " + tp1_fullpath)
            print("File 2: " + tp2_fullpath)
            print("Subject ID: " + subj_id_tp1)
            print("Session 1 date: " + ses_tp1)
            print("Session 2 date: " + ses_tp2)

            # Construct output argument for MeshMath subtract tool
            dist_output_fullpath = (output_dir + "\\" + subj_id_tp1 + "_" + ses_tp1 + "-" + ses_tp2 + "_dist_vectors_mask_L.txt")
            print("Output file for distance files: " + dist_output_fullpath)

            print("\nRunning MeshMath tool to calculate distance vectors...\n")
            
            subprocess.run(['C:\\Program Files\\SlicerSALT 3.0.0\\bin\MeshMath.exe', tp2_metapath, dist_output_fullpath, '-subtract', tp1_metapath])

            print("\n...Complete.")

            # Construct output argument for MeshMath magNormDir tool
            magNorm_fullpath = (output_dir + "\\" + subj_id_tp1 + "_" + ses_tp1 + "-" + ses_tp2 + "_magNormProj_mask_L.txt")
            print("Output file for normal projection files: " + magNorm_fullpath)

            print("\nRunning MeshMath tool to calculate normal projections of distance vectors...\n")

            subprocess.run(['C:\\Program Files\\SlicerSALT 3.0.0\\bin\MeshMath.exe', tp1_metapath, magNorm_fullpath, '-magNormDir', dist_output_fullpath])

            print("\n...Complete")