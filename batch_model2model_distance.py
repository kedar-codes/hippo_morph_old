# Function: Execute SlicerSALT's "ModelToModelDistance" module in a command line interface for batch processing.
# Note: This .py script MUST be executed in SlicerSALT's built-in Python console/interpreter in the GUI (or PythonSlicer.exe)

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

# exec(open(r"K:\ShapeAnalysisPipeline\slicer_salt_loop.py").read())

# declare timepoint 1/2 season paths 
timepoint1_path = r'K:\path\to\timepoint1\VTK\models'
timepoint2_path = r'K:\path\to\timepoint2\VTK\models'

# get lists of all timepoint 1 and timepoint 2 filenames 
timepoint1_files = [f for f in listdir(timepoint1_path) if isfile(join(timepoint1_path, f))]
timepoint2_files = [f for f in listdir(timepoint2_path) if isfile(join(timepoint2_path, f))]

subject_pairs = []

# get all subject IDs from timepoint 1 folder
###subject_ids = [f.split("-")[1].split("_")[0] for f in timepoint1_files]
subject_ids = [f.split("_")[0] for f in timepoint1_files]

subject_ids = [f[7:] for f in subject_ids]

# loop through every combination of timepoint 1 and timepoint 2 files to match subjects between sessions
for tp1_path in timepoint1_files:
    for tp2_path in timepoint2_files:
        for subject_id in subject_ids:
        
            # extract subject ID from pre and post seasons
            ###tp1_path_id = tp1_path.split("-")[1].split("_")[0]
            ###tp2_path_id = tp2_path.split("-")[1].split("_")[0]
            tp1_path_id = tp1_path.split("_")[0]
            tp1_path_id = tp1_path_id[7:]
            tp2_path_id = tp2_path.split("_")[0]
            tp2_path_id = tp2_path_id[7:]
            
            # if there's a match, append pre and post season filenames to a 2d array
            if subject_id == tp1_path_id  and subject_id == tp2_path_id:
               subject_pairs.append([tp1_path, tp2_path])
       
# loop through timepoint 1 / timepoint 2 files and subject_ids at the same time 
for path, subject_id in zip(subject_pairs, subject_ids):

    tp1_path = path[0]
    tp2_path = path[1]

    # join the timepoint 1 and timepoint 2 base paths with their respective filenames
    m1 = slicer.util.loadModel(join(timepoint1_path, tp1_path))
    m2 = slicer.util.loadModel(join(timepoint2_path, tp2_path))
    
    # extract dates from filenames
    tp1_date = re.search(r'\d{8}', tp1_path).group()[:8] 
    tp2_date = re.search(r'\d{8}', tp2_path).group()[:8] 
    
    # create subject ID with ID and before and after dates 
    subject_id_to_save = subject_id + "-" + tp1_date + "-" + tp2_date
    
    print(tp1_date, tp2_date)
    
    # create new output node to assign difference to
    outputNode = slicer.mrmlScene.AddNewNodeByClass("vtkMRMLModelNode", "outputDistance")
    
    # assign model IDs and corresponding_point_to_point distanceType
    params = {'vtkFile1': m1.GetID(), 'vtkFile2': m2.GetID()  , 'vtkOutput' : outputNode.GetID(), 'distanceType' : 'corresponding_point_to_point', 'targetInFields' : False}
    
    slicer.cli.runSync(slicer.modules.modeltomodeldistance, None, parameters=params)
    
    # get node in proper format for array extraction 
    modelNode = slicer.util.getNode(outputNode.GetID())
    
    # convert node to array XYZ coordinates 
    #distances = slicer.util.arrayFromModelPoints(modelNode)
    distances = slicer.util.arrayFromModelPointData(modelNode,'PointToPointVector')
    
    final_distances = []
    
    # loop through all 1d arrays inside distances
    for item in distances:
    
      # compute magnitudes with numpy 
      magnitude = np.linalg.norm(item)
      
      # add magnitude to the end of each 1-dimensional array that make up the larger 2d distance array
      item = np.append(item, magnitude)
      final_distances.append(item)
    
    # save outputs with before and after dates (filenames can be easily mass modified after the fact if you want a different naming convention) 
    np.savetxt(r"K:\path\to\output\directory" + subject_id_to_save + ".csv", final_distances, delimiter=",", header = 'X, Y, Z, Magnitude', comments='')
    
    slicer.util.saveNode(outputNode, r"K:\path\to\output\directory" + subject_id_to_save + ".vtk")

