#!/bin/bash
set -e

# Function: 1) Execute FreeSurfer segmentation, 2) Convert .relevant .mgz files to .nii.gz, 3) Extract the desired ROIs, 4) Place ROI masks in appropriate folders

# NOTE: Can be done in Unix or Windows environment, but: 1) change paths to '/home/...' instead of '/c/...', 
# 		and 2) change escape characters to LF (instead of CRLF) if executing in Unix (e.g., on P920).

# NOTE: This script assumes that FreeSurfer has been added to your system $PATH

########################################################################################################################################################################################################
# User defined variables

PROJECT_DIR='/Unix/path/to/project/directory' # Choose directory in which to place the study




########################################################################################################################################################################################################

echo -e "\n\n####################################################################################################"
echo -e "\nStarting program..."
echo -e "\n####################################################################################################"




########################################################################################################################################################################################################
# Begin FreeSurfer total brain segmentation

echo -e ""
echo -e "\n####################################################################################################"
echo -e "\nBeginning FreeSurfer segmentation..."
echo -e "\n####################################################################################################"




for i in $PROJECT_DIR/T1_images/*/; do # List directories and files to be segmented for user review before continuing

    cd "$i"
    echo -e "\nGroup directory found:\n\n\t$i"
    echo -e "\nFiles to be segmented:\n"

    ls ./*.nii.gz -1 | sed 's/^/\t/'

	mkdir -p ./FreeSurfer_scratch_seg/

done




echo -e "\nNOTICE: About to begin FreeSurfer segmentation. This process may take multiple hours.\n"
read -p "Continue (y/n)? Answer: " choice # Ask to continue before beginning FS segmentation
case "$choice" in
 	y|Y ) echo -e "\nConfirmed. Continuing program and executing FreeSurfer segmentation.";;
  	n|N ) echo -e "\nConfirmed. Exiting program."; exit 1;;
  	* ) echo -e "\nInvalid. Please type 'y' or 'n'. Exiting program."; exit 1;;
esac




mkdir -p /home/[your username]/Desktop/FreeSurfer_segmentations/FreeSurfer_scratch_seg_total/

# Run FS
ls $PROJECT_DIR/T1_images/*/*.nii.gz | parallel --jobs 16 recon-all -s {.} -i {} -all -sd /home/[your username]/Desktop/FreeSurfer_segmentations/FreeSurfer_scratch_seg_total/ -mail random_email@random_email.com



echo -e "\n\n####################################################################################################"
echo -e "\nFreeSurfer total brain segmentation complete. Beginning FreeSurfer hippocampal subfield segmentation..."
echo -e "\n####################################################################################################"



########################################################################################################################################################################################################
# Begin FreeSurfer hippocampal subfield segmentation

ls /home/[your username]/Desktop/FreeSurfer_segmentations/FreeSurfer_scratch_seg_total/ | xargs -I {} -P 5 segmentHA_T1.sh {} /home/[your username]/Desktop/FreeSurfer_segmentations/FreeSurfer_scratch_seg_total/



echo -e "\n\n####################################################################################################"
echo -e "\nFreeSurfer hippocampal subfield segmentation complete."
echo -e "\n####################################################################################################"



########################################################################################################################################################################################################
# Move all directories and files to personal isilon drive

#mv /home/[your username]/Desktop/FreeSurfer_segmentations/FreeSurfer_scratch_seg_total/ $PROJECT_DIR/T1_images/
rsync -avh --no-links /home/[your username]/Desktop/FreeSurfer_segmentations/FreeSurfer_scratch_seg_total/* $PROJECT_DIR/T1_images/ # Copy over files to isilon drive

# if the previous exit code is 0.
if [ $? -eq 0 ]; then

	rm -Rfv /home/[your username]/Desktop/FreeSurfer_segmentations/FreeSurfer_scratch_seg_total/*

fi



echo -e "\n\n####################################################################################################"
echo -e "\nAll segmentations complete."
echo -e "\n####################################################################################################"




########################################################################################################################################################################################################
# Program is complete

echo -e "\n\n####################################################################################################"
echo -e "\nNOTICE: The FreeSurfer segmentation program has completed."
echo -e "\n####################################################################################################"
