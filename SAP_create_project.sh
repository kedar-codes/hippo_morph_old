#!/bin/bash
set -e

# Function: Create a directory hierarchy for a shape analysis project and place the subject T1 image files in the appropriate directory.

# NOTE: Can be done in Unix or Windows environment, but: 1) change paths to '/home/...' instead of '/c/...', 
# 		and 2) change escape characters to LF (instead of CRLF) if executing in Unix (e.g., on P920).

########################################################################################################################################################################################################
# User defined variables

#PROJECT_DIR='/Windows/path/to/project/directory' # Choose directory in which to place the study
PROJECT_DIR='/Unix/path/to/project/directory' # P920 path

PROJECT="test" # Name the study/project

GROUP1='group1' # Name group 1
#GROUP2='cohort1_ses2' # Name group 2
#GROUP3='cohort1_ses3' # Name group 3
#GROUP4='cohort3_ses1' # Name group 4
#GROUP5='cohort5_ses1' # Name group 5

GROUP1_T1_RAW_DIR='/path/to/group1/T1/images' # Choose directory where raw T1 files for Group1 are located
#GROUP2_T1_RAW_DIR='/path/to/group2/T1/images' # Choose directory where raw T1 files for Group2 are located
#GROUP3_T1_RAW_DIR='/path/to/group3/T1/images' # Choose directory where raw T1 files for Group3 are located
#GROUP4_T1_RAW_DIR='/path/to/group4/T1/images' # Choose directory where raw T1 files for Group4 are located
#GROUP5_T1_RAW_DIR='/path/to/group5/T1/images' # Choose directory where raw T1 files for Group5 are located




########################################################################################################################################################################################################

echo -e "\n\n####################################################################################################"
echo -e "\nStarting program..."
echo -e "\n####################################################################################################"




########################################################################################################################################################################################################
# Create arrays for user-inputted variables

declare -a group_array # array for group names
declare -a t1_array # array for directories where raw T1 .nii files can be found

##################################################
# Group 1

if [[ -v GROUP1 ]] && [[ -v GROUP1_T1_RAW_DIR ]] && [[ -d $GROUP1_T1_RAW_DIR ]]; then
	group_array=($GROUP1)
	t1_array=($GROUP1_T1_RAW_DIR)
else
	echo -e "\nNotice: Either the variable GROUP1 or the directory in which the original T1 files for GROUP1 are found hasn't been correctly specified. Please provide a group name and a T1 file directory, and run this program again."
	exit 1
fi

##################################################
# Group 2

if [[ -v GROUP2 ]] && [[ -v GROUP2_T1_RAW_DIR ]] && [[ -d $GROUP2_T1_RAW_DIR ]]; then
	group_array+=($GROUP2)
	t1_array+=($GROUP2_T1_RAW_DIR)
else
	echo -e "\nNotice: Either the variable GROUP2 or the directory in which the original T1 files for GROUP2 are found hasn't been correctly specified.\n"
	read -p "Continue (y/n)? Answer: " choice
	case "$choice" in
  	y|Y ) echo -e "\nConfirmed. Continuing program.";;
  	n|N ) echo -e "\nConfirmed. Exiting program."; exit 1;;
  	* ) echo -e "\nInvalid. Please type 'y' or 'n'. Exiting program."; exit 1;;
	esac
fi

##################################################
# Group 3

if [[ -v GROUP3 ]] && [[ -v GROUP3_T1_RAW_DIR ]] && [[ -d $GROUP3_T1_RAW_DIR ]]; then
	group_array+=($GROUP3)
	t1_array+=($GROUP3_T1_RAW_DIR)
else
	echo -e "\nNotice: Either the variable GROUP3 or the directory in which the original T1 files for GROUP3 are found hasn't been correctly specified.\n"
	read -p "Continue (y/n)? Answer: " choice
	case "$choice" in
  	y|Y ) echo -e "\nConfirmed. Continuing program.";;
  	n|N ) echo -e "\nConfirmed. Exiting program."; exit 1;;
  	* ) echo -e "\nInvalid. Please type 'y' or 'n'. Exiting program."; exit 1;;
	esac
fi

##################################################
# Group 4

if [[ -v GROUP4 ]] && [[ -v GROUP4_T1_RAW_DIR ]] && [[ -d $GROUP4_T1_RAW_DIR ]]; then
	group_array+=($GROUP4)
	t1_array+=($GROUP4_T1_RAW_DIR)
else
	echo -e "\nNotice: Either the variable GROUP4 or the directory in which the original T1 files for GROUP4 are found hasn't been correctly specified.\n"
	read -p "Continue (y/n)? Answer: " choice
	case "$choice" in
  	y|Y ) echo -e "\nConfirmed. Continuing program.";;
  	n|N ) echo -e "\nConfirmed. Exiting program."; exit 1;;
  	* ) echo -e "\nInvalid. Please type 'y' or 'n'. Exiting program."; exit 1;;
	esac
fi

##################################################
# Group 5

if [[ -v GROUP5 ]] && [[ -v GROUP5_T1_RAW_DIR ]] && [[ -d $GROUP5_T1_RAW_DIR ]]; then
	group_array+=($GROUP5)
	t1_array+=($GROUP5_T1_RAW_DIR)
else
	echo -e "\nNotice: Either the variable GROUP5 or the directory in which the original T1 files for GROUP5 are found hasn't been correctly specified.\n"
	read -p "Continue (y/n)? Answer: " choice
	case "$choice" in
  	y|Y ) echo -e "\nConfirmed. Continuing program.";;
  	n|N ) echo -e "\nConfirmed. Exiting program."; exit 1;;
  	* ) echo -e "\nInvalid. Please type 'y' or 'n'. Exiting program."; exit 1;;
	esac
fi





########################################################################################################################################################################################################
# Check if group_array and t1_array are the same length (i.e. Every group has an associated T1 file directory). If not, exit the program.

echo ""

if [[ "${#group_array[@]}" -eq  "${#t1_array[@]}" ]]; then
	echo -e "\n##################################################"
	echo -e "\nConfirmed: Every group has an associated raw T1 file directory from which to copy over the files. Continuing the program."
	echo -e "\n##################################################"
	#echo ${#group_array[@]}
else
	echo -e "\n##################################################"
	echo -e "\nERROR: There is a mismatch in the number of groups specified and the number of T1 file directories provided."
	echo -e "\nEnsure that a T1 file directory is provided for every group, then run the program again. Exiting program."
	exit 1
fi





########################################################################################################################################################################################################
# Create the project directory

if [[ ! -e $PROJECT_DIR ]]; then
	echo -e "\n$PROJECT_DIR doesn't already exist. Creating the directory '$PROJECT_DIR' now."
	mkdir -p $PROJECT_DIR/{T1_images,SPHARM_computation,population_analysis,covariate_significance,model2model_distance} # Create the project folder with all the required subfolders # Make PROJECT_DIR directory if it doesn't exist.
elif [[ ! -d $PROJECT_DIR ]]; then
	echo -e "\n$PROJECT_DIR already exists but it is not a directory." 1>&2
	exit 1
fi





########################################################################################################################################################################################################
# Create subdirectories for each group

echo -e "\n\n####################################################################################################"
echo -e "\nCreating project folder for $PROJECT_DIR..."
echo -e "\n####################################################################################################"

for i in ${group_array[@]}; do
	echo -e "\n##################################################"
	echo -e "Group: $i"

	mkdir -p $PROJECT_DIR/T1_images/$i/masks_L/{hippo,lat_vent,insula} # Create GROUP_ folder + 'masks_L' folder in the T1_images subfolder (if previously specified and created)
	mkdir -p $PROJECT_DIR/T1_images/$i/masks_R/{hippo,lat_vent,insula} # Create GROUP_ folder + 'masks_R' folder in the T1_images subfolder (if previously specified and created)
	echo -e "\n$PROJECT_DIR/T1_images/$i/masks_L/ folder created."
	echo -e "\n$PROJECT_DIR/T1_images/$i/masks_R/ folder created."

	mkdir -p $PROJECT_DIR/SPHARM_computation/$i/masks_L/{SPHARM_vtk_models,ellalign_vtk_models,procalign_vtk_models,hippo,lat_vent,insula} # Create GROUP_ folder + 'masks_L' folder in the SPHARM_computation subfolder (if previously specified and created)
	mkdir -p $PROJECT_DIR/SPHARM_computation/$i/masks_R/{SPHARM_vtk_models,ellalign_vtk_models,procalign_vtk_models,hippo,lat_vent,insula} # Create GROUP_ folder + 'masks_R' folder in the SPHARM_computation subfolder (if previously specified and created)
	echo -e "\n$PROJECT_DIR/SPHARM_computation/$i/masks_L/ folder"
	echo -e "\n$PROJECT_DIR/SPHARM_computation/$i/masks_R/ folder"

	mkdir -p $PROJECT_DIR/covariate_significance/masks_L/{hippo,lat_vent,insula} # Create 'masks_L' folder + GROUP_ folder in the covariate_significance subfolder (if previously specified and created)
	mkdir -p $PROJECT_DIR/covariate_significance/masks_R/{hippo,lat_vent,insula} # Create 'masks_R' folder + GROUP_ folder in the covariate_significance (if previously specified and created)
	echo -e "\n$PROJECT_DIR/covariate_significance/masks_L/ folder created."
	echo -e "\n$PROJECT_DIR/covariate_significance/masks_R/ folder created."

	mkdir -p $PROJECT_DIR/population_analysis/masks_L/{hippo,lat_vent,insula} # Create 'masks_L' folder + GROUP_ folder in the population_analysis subfolder (if previously specified and created)
	mkdir -p $PROJECT_DIR/population_analysis/masks_R/{hippo,lat_vent,insula} # Create 'masks_R' folder + GROUP_ folder in the population_analysis (if previously specified and created)
	echo -e "\n$PROJECT_DIR/population_analysis/masks_L/ folder created."
	echo -e "\n$PROJECT_DIR/population_analysis/masks_R/ folder created."

	mkdir -p $PROJECT_DIR/model2model_distance/masks_L/{hippo,lat_vent,insula} # Create 'masks_L' folder + GROUP_ folder in the model2model_distance subfolder (if previously specified and created)
	mkdir -p $PROJECT_DIR/model2model_distance/masks_R/{hippo,lat_vent,insula} # Create 'masks_R' folder + GROUP_ folder in the model2model_distance (if previously specified and created)
	echo -e "\n$PROJECT_DIR/model2model_distance/masks_L/ folder created."
	echo -e "\n$PROJECT_DIR/model2model_distance/masks_R/ folder created."
done





########################################################################################################################################################################################################
# Copy over T1 .nii scans for each group

echo -e "\n\n####################################################################################################"
echo -e "\nCopying all T1 .nii files to their respective directories..."
echo -e "\n####################################################################################################"

for i in ${!group_array[@]}; do
	echo -e "\n##################################################"
	echo -e "Group: ${group_array[$i]}"
	cp -r ${t1_array[$i]}/* $PROJECT_DIR/T1_images/${group_array[$i]}
	echo -e "\nAll T1 .nii files for ${group_array[$i]} were copied to directory $PROJECT_DIR/T1_images/${group_array[$i]}."
done





########################################################################################################################################################################################################
# Copy over template files

cp -r /k/UCLA_CBF_Project/template_files $PROJECT_DIR





########################################################################################################################################################################################################

# Program is complete

echo -e ""
echo -e "\n\####################################################################################################"
echo -e "\nNOTICE: The project directory hierarchy has been created."
echo -e "\n####################################################################################################"
