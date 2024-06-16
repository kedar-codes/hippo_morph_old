#!/bin/bash
set -e

# Function: Execute a batch process for SlicerSALT's SPHARM-PDM computation. Must be performed using the directory structure created by SAP_create_project.sh (i.e., run this script after SAP_create_project.sh).

# NOTE: Can be done in Unix or Windows environment, but: 1) change paths to '/home/...' instead of '/c/...', 
# 		and 2) change escape characters to LF (instead of CRLF) if executing in Unix (e.g., on P920).

# NOTE: Make sure to modify the various SlicerSALT file paths located throughout the script.

########################################################################################################################################################################################################
# User defined variables

#PROJECT_DIR='/Windows/path/to/project/directory' # Choose directory in which to place the study
PROJECT_DIR='/Unix/path/to/project/directory' # P920 path

if [[ -d $PROJECT_DIR ]]; then # Check if user-inputted project is a valid directory
  echo -e "\nConfirmed. The $PROJECT directory exists. Continuing the program."
else
  echo -e "\nERROR: Not a valid project name (i.e. not an existing directory). Please try again."
  exit 1
fi

# Choose ROI to process through the SPHARM computation
ROI='insula'





########################################################################################################################################################################################################
# Copy SPHARM-PDM-parameters_blank.ini file into each 'masks_L' and 'masks_R' folder in the 'SPHARM_computation' subfolder

echo -e "\n\n####################################################################################################"
echo -e "\nPreparing for SPHARM-PDM computation..."
echo -e "\n####################################################################################################"

for group in $PROJECT_DIR/SPHARM_computation/*/; do
	group_name=`basename $group`
	#echo $group_name
	cp -r /path/to/SPHARM-PDM-parameters_blank.ini $PROJECT_DIR/SPHARM_computation/$group_name/masks_L/$ROI # Move blank .ini file from ShapeAnalysisPipeline folder
    cp -r /path/to/SPHARM-PDM-parameters_blank.ini $PROJECT_DIR/SPHARM_computation/$group_name/masks_R/$ROI # Move blank .ini file from ShapeAnalysisPipeline folder
	mv $PROJECT_DIR/SPHARM_computation/$group_name/masks_L/$ROI/SPHARM-PDM-parameters_blank.ini $PROJECT_DIR/SPHARM_computation/$group_name/masks_L/$ROI/"$group_name"_"$ROI"_masks_L_parameters.ini # Rename .ini file
	mv $PROJECT_DIR/SPHARM_computation/$group_name/masks_R/$ROI/SPHARM-PDM-parameters_blank.ini $PROJECT_DIR/SPHARM_computation/$group_name/masks_R/$ROI/"$group_name"_"$ROI"_masks_R_parameters.ini # Rename .ini file
done

echo -e "\nThe 'SPHARM-PDM-parameters_blank.ini' file was copied into the 'masks_L' and 'masks_R' folders for each group in the 'SPHARM_computation' folder."
echo -e "\nThis program will now edit the .ini config file for the left and right masks for each group before beginning the SPHARM computation."





########################################################################################################################################################################################################
# Edit each .ini config file before SPHARM-PDM computation can begin

echo -e "\n\n####################################################################################################"
echo -e "\nSearching $PROJECT_DIR directory for .ini config files..."
echo -e "\n####################################################################################################"

for config_file in $(find $PROJECT_DIR/SPHARM_computation/ -name '*.ini'); do

  # Get file and directory location information
  file_name=`basename $config_file`
  echo -e "\nFile found: $file_name"
  dir_name=`dirname $config_file`
  echo -e "\nDirectory in which it was found: $dir_name"
  cd $dir_name
  cd ..
  what_mask=`basename $PWD` # Is it masks_L or masks_R? The .ini file's "inputDirectoryPath" and "outputDirectoryPath" needs to be edited to reflect this.
  echo -e "\nMask (L or R): $what_mask"
  cd ..
  what_group=`basename $PWD` # What group is it? The .ini file's "inputDirectoryPath" and "outputDirectoryPath" needs to be edited to reflect this.
  echo -e "\nGroup: $what_group"

  # Edit the appropriate lines in the .ini config files
  echo -e "\nEditing the appropriate lines in the .ini config file..."
  sed -i -r "s|inputDirectoryPath =|inputDirectoryPath = $PROJECT_DIR/T1_images/$what_group/$what_mask/$ROI|" $config_file
  sed -i -r "s|outputDirectoryPath =|outputDirectoryPath = $PROJECT_DIR/SPHARM_computation/$what_group/$what_mask/$ROI|" $config_file

  if [[ $what_mask == "masks_L" ]]; then
    sed -i -r "s|regParaTemplate =|regParaTemplate = $PROJECT_DIR/template_files/"$ROI"_mask_L_regtemplate.vtk|" $config_file
    sed -i -r "s|flipTemplate =|flipTemplate = $PROJECT_DIR/template_files/"$ROI"_mask_L_fliptemplate.coef|" $config_file
  else
    sed -i -r "s|regParaTemplate =|regParaTemplate = $PROJECT_DIR/template_files/"$ROI"_mask_R_regtemplate.vtk|" $config_file
    sed -i -r "s|flipTemplate =|flipTemplate = $PROJECT_DIR/template_files/"$ROI"_mask_R_fliptemplate.coef|" $config_file
  fi

  sed -i -r "s|flip = 0|flip = 0|" $config_file
  echo -e "\nThe appropriate lines in the .ini config files have been edited."
  echo -e "\n##################################################"

done

echo -e "\n\n\nNOTICE: All .ini config files have been edited. Please verify that all parameters in every .ini config file are correct before continuing with the SPHARM-PDM computation. When ready, continue the program."





########################################################################################################################################################################################################
# Ask to continue before SPHARM-PDM computation can begin

echo -e "\n"
read -p "Continue (y/n)? Answer: " choice
case "$choice" in
  y|Y ) echo -e "\nConfirmed. Continuing Beginning SPHARM-PDM.";;
  n|N ) echo -e "\nConfirmed. Please make the required edits manually or run this program again to do so automatically. Now exiting the program."; exit 1;;
  * ) echo -e "\nInvalid. Please type 'y' or 'n'. Exiting program."; exit 1;;
esac





########################################################################################################################################################################################################
# Ask to continue before SPHARM-PDM computation can begin

for config_file_edit in $(find $PROJECT_DIR/SPHARM_computation/ -name '*.ini'); do
  #/c/Program\ Files/SlicerSALT\ 3.0.0-2020-07-22/SlicerSALT.exe --no-main-window --python-script /c/Program\ Files/SlicerSALT\ 3.0.0-2020-07-22/share/SlicerSALT-4.11/CommandLineTool/SPHARM-PDM.py $config_file_edit &
  /Unix/path/to/SlicerSALT... --no-main-window --python-script /Unix/path/to/SlicerSALT.../share/SlicerSALT-4.11/CommandLineTool/SPHARM-PDM.py $config_file_edit &
done
