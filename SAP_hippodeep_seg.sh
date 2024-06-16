#!/bin/bash
set -e

# Function: 1) Run hippodeep segmentation to segment hippocampal masks, 2) Place hippocampal masks in appropriate folders

# NOTE: Can be done in Unix or Windows environment, but: 1) change paths to '/home/...' instead of '/c/...', 
# 		and 2) change escape characters to LF (instead of CRLF) if executing in Unix (e.g., on P920).

########################################################################################################################################################################################################
# User defined variables

#PROJECT_DIR='/Windows/path/to/project/directory' # Choose directory in which to place the study
PROJECT_DIR='/Unix/path/to/project/directory' # P920 path




########################################################################################################################################################################################################

echo -e "\n\n####################################################################################################"
echo -e "\nStarting program..."
echo -e "\n####################################################################################################"




########################################################################################################################################################################################################
# Begin hippodeep_pytorch segmentation

echo -e "\n\n####################################################################################################"
echo -e "\nBeginning hippodeep_pytorch segmentation..."
echo -e "\n####################################################################################################"

for i in $PROJECT_DIR/T1_images/*; do

	if [[ "$(ls -A $i/)" ]]; then

		echo -e "\n\nBeginning hippodeep_pytorch segmentation on all T1 subject files for $i.\n\n"

		#sh /c/Users/kmadi/hippodeep_pytorch/deepseg1.sh $i/*.nii.gz # Initiate hippodeep_pytorch segmentation on subject T1 scans
		sh /path/to/hippodeep_pytorch/deepseg1.sh $i/*.nii # Initiate hippodeep_pytorch segmentation on subject T1 scans

		mkdir -p $i/masks_L/hippo; mv $i/*mask_L.nii.gz $i/masks_L/hippo # Move mask_L .nii files to respective folder

		mkdir -p $i/masks_R/hippo; mv $i/*mask_R.nii.gz $i/masks_R/hippo # Move mask_R .nii files to respective folder

		mkdir -p $i/hippodeep_scratch_seg/ # Make folder to dump all extraneous hippodeep files into

		mv $i/*brain_mask* $i/hippodeep_scratch_seg/ # Dump all extraneous hippodeep files into folder

		mv $i/*cerebrum_mask* $i/hippodeep_scratch_seg/ # Dump all extraneous hippodeep files into folder

		mv $i/*volumes* $i/hippodeep_scratch_seg/ # Dump all extraneous hippodeep files into folder

		mv $i/*report* $i/hippodeep_scratch_seg/ # Dump all extraneous hippodeep files into folder

		echo -e "\n\nSegmentation of subject T1 scans are completed. Left and right hippocampal masks can be found in the respective 'masks_L' or 'masks_R' folder."

	else

		echo "\nERROR: No .nii files located in $i directory. Segmentation cannot begin."

		exit 1

	fi

done

echo -e "\n\n####################################################################################################"
echo -e "\nAll segmentations complete."
echo -e "\n####################################################################################################"


########################################################################################################################################################################################################
# Program is complete

echo -e "\n\n####################################################################################################"
echo -e "\nNOTICE: The hippodeep_pytorch segmentation program has completed."
echo -e "\n####################################################################################################"
