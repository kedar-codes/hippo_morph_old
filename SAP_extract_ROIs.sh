#!/bin/bash
set -e

# Function: 1) Convert .relevant .mgz files to .nii.gz, 2) Extract the desired FreeSurfer (FS) ROIs, 3) Place FS ROI masks in appropriate folders

# NOTE: Can be done in Unix or Windows environment, but: 1) change paths to '/home/...' instead of '/c/...', 
# 		and 2) change escape characters to LF (instead of CRLF) if executing in Unix (e.g., on P920).

# NOTE: This script assumes that FSL has been added to your system $PATH

########################################################################################################################################################################################################
# User defined variables

#INPUT_DIR='/Windows/input/directory/path' # Choose directory where FreeSurfer segmentations are located
INPUT_DIR='/Unix/input/directory/path' # P920 path

OUTPUT_DIR='/Unix/output/directory/path'

OUTPUT_DIR_masks_L='/Unix/output/directory/path/masks_L'

OUTPUT_DIR_masks_R='/Unix/output/directory/path/masks_R'

########################################################################################################################################################################################################

echo -e "\n\n####################################################################################################"
echo -e "\nStarting program..."
echo -e "\n####################################################################################################"

export PATH=$PATH:/opt/abin # Add AFNI binaries/environment variables to current shell




########################################################################################################################################################################################################
# Determine which ROIs are getting segmented (1 = true, 0 = false)

HIPPO=1
HIPPO_SUB=1
LAT_VENT=1



########################################################################################################################################################################################################
# Begin Segmenting ROIs

cd -- $INPUT_DIR

for d in $INPUT_DIR/*/mri; do
  
    SUBJ_orig=$(basename $(dirname "$d")) # Get subject name from last part of directory path
    SUBJ=${SUBJ_orig::-4} # Remove the '.nii' from the subject name
    
    echo -e "\nFound subject: $SUBJ"

    echo -e "\nFound subject directory: $d/\n\n"

    mri_convert $d/T1.mgz $d/$SUBJ\b_T1.nii.gz # Convert T1.mgz to T1.nii.gz
    
    mri_convert $d/aseg.auto.mgz $d/$SUBJ\b_aseg.nii.gz # Convert aseg.mgz to aseg.nii.gz

    mri_convert $d/lh.hippoAmygLabels-T1.v21.FS60.FSvoxelSpace.mgz $d/$SUBJ\b_lh.hippoAmygLabels.nii.gz # Convert left hippocampal/amygdala subfield .mgz to .nii.gz

    mri_convert $d/rh.hippoAmygLabels-T1.v21.FS60.FSvoxelSpace.mgz $d/$SUBJ\b_rh.hippoAmygLabels.nii.gz # Convert left hippocampal/amygdala subfield .mgz to .nii.gz

    echo -e "\n####################################################################################################"
    
    echo -e "\nFiles converted to .nii.gz. Now extracting ROIs."

    echo -e "\n####################################################################################################"

    ####################################################################################################################################################################################################

    if [[ "$LAT_VENT" -eq 1 ]]; then # LATERAL VENTRICLES

        echo -e "\n####################################################################################################"
    
        echo -e "\nLATERAL VENTRICLES"

        echo -e "\n####################################################################################################"

        echo -e "\nExtracting lateral ventricles."

        echo -e "\nLeft lateral ventricle...\n"

        fslmaths $d/$SUBJ\b_aseg.nii.gz -thr 3.9 -uthr 4.1 -bin $d/$SUBJ\b_L_lat_vent.nii.gz # Extract left lateral ventricle ROI(s)
        fslmaths $d/$SUBJ\b_aseg.nii.gz -thr 4.9 -uthr 5.1 -bin $d/$SUBJ\b_L_inf_lat_vent.nii.gz

        echo -e "\n...Complete."

        echo -e "\nRight lateral ventricle...\n"

        fslmaths $d/$SUBJ\b_aseg.nii.gz -thr 42.9 -uthr 43.1 -bin $d/$SUBJ\b_R_lat_vent.nii.gz # Extract right lateral ventricle ROI(s)
        fslmaths $d/$SUBJ\b_aseg.nii.gz -thr 43.9 -uthr 44.1 -bin $d/$SUBJ\b_R_inf_lat_vent.nii.gz

        echo -e "\n...Complete."

        echo -e "\nConcatentating ventricles...\n"
    
        fslmaths $d/$SUBJ\b_L_lat_vent.nii.gz -add $d/$SUBJ\b_L_inf_lat_vent.nii.gz $d/$SUBJ\b_L_lat_vent_comb.nii.gz # Combine/concatenate L and R ventricle ROIs
        fslmaths $d/$SUBJ\b_R_lat_vent.nii.gz -add $d/$SUBJ\b_R_inf_lat_vent.nii.gz $d/$SUBJ\b_R_lat_vent_comb.nii.gz

        echo -e "\n...Complete."

        echo -e "\nDilating/eroding ventricles and placing the (new) files in the appropriate directories...\n"

        3dmask_tool -input $d/$SUBJ\b_L_lat_vent_comb.nii.gz -prefix $OUTPUT_DIR_masks_L/$SUBJ\b_FSlatventcomb_dil_mask_L.nii.gz -dilate_input 3 -2 # Dilate left ventricle by 3, erode by 2
        3dmask_tool -input $d/$SUBJ\b_R_lat_vent_comb.nii.gz -prefix $OUTPUT_DIR_masks_R/$SUBJ\b_FSlatventcomb_dil_mask_R.nii.gz -dilate_input 3 -2 # Dilate left ventricle by 3, erode by 2

        echo -e "\n...Complete."

    fi

    if [[ "$HIPPO" -eq 1 ]]; then # HIPPOCAMPUS

        echo -e "\n####################################################################################################"
    
        echo -e "\nHIPPOCAMPUS"

        echo -e "\n####################################################################################################"

        echo -e "\nExtracting hippocampi."

        echo -e "\nLeft hippocampus..."

        fslmaths $d/$SUBJ\b_aseg.nii.gz -thr 16.9 -uthr 17.1 -bin $OUTPUT_DIR_masks_L/$SUBJ\b_FShippo_mask_L.nii.gz # Extract hippocampus ROI(s)

        echo -e "\n...Complete."

        echo -e "\nRight hippocampus..."

        fslmaths $d/$SUBJ\b_aseg.nii.gz -thr 52.9 -uthr 53.1 -bin $OUTPUT_DIR_masks_R/$SUBJ\b_FShippo_mask_R.nii.gz # Extract right hippocampus ROI(s)

        echo -e "\n...Complete."

    fi

    if [[ "$HIPPO_SUB" -eq 1 ]]; then # HIPPOCAMPAL SUBFIELDS

    echo -e "\n####################################################################################################"
    
        echo -e "\nHIPPOCAMPAL SUBFIELDS"

        echo -e "\n####################################################################################################"

        echo -e "\nExtracting hippocampal subfields."

        echo -e "\nLeft hippocampus..."

        fslmaths $d/$SUBJ\b_lh.hippoAmygLabels.nii.gz -thr 202.9 -uthr 203.1 -bin $OUTPUT_DIR_masks_L/$SUBJ\b_parasubiculum_mask_L.nii.gz # Extract left parasubiculum
        fslmaths $d/$SUBJ\b_lh.hippoAmygLabels.nii.gz -thr 203.9 -uthr 204.1 -bin $OUTPUT_DIR_masks_L/$SUBJ\b_presubiculum_mask_L.nii.gz # Extract left presubiculum
        fslmaths $d/$SUBJ\b_lh.hippoAmygLabels.nii.gz -thr 204.9 -uthr 205.1 -bin $OUTPUT_DIR_masks_L/$SUBJ\b_subiculum_mask_L.nii.gz # Extract left subiculum
        fslmaths $d/$SUBJ\b_lh.hippoAmygLabels.nii.gz -thr 205.9 -uthr 206.1 -bin $OUTPUT_DIR_masks_L/$SUBJ\b_CA1_mask_L.nii.gz # Extract left CA1
        fslmaths $d/$SUBJ\b_lh.hippoAmygLabels.nii.gz -thr 207.9 -uthr 208.1 -bin $OUTPUT_DIR_masks_L/$SUBJ\b_CA3_mask_L.nii.gz # Extract left CA3
        fslmaths $d/$SUBJ\b_lh.hippoAmygLabels.nii.gz -thr 208.9 -uthr 209.1 -bin $OUTPUT_DIR_masks_L/$SUBJ\b_CA4_mask_L.nii.gz # Extract left CA4
        fslmaths $d/$SUBJ\b_lh.hippoAmygLabels.nii.gz -thr 209.9 -uthr 210.1 -bin $OUTPUT_DIR_masks_L/$SUBJ\b_GC-DG_mask_L.nii.gz # Extract left GC-DG
        fslmaths $d/$SUBJ\b_lh.hippoAmygLabels.nii.gz -thr 210.9 -uthr 211.1 -bin $OUTPUT_DIR_masks_L/$SUBJ\b_HATA_mask_L.nii.gz # Extract left HATA
        fslmaths $d/$SUBJ\b_lh.hippoAmygLabels.nii.gz -thr 211.9 -uthr 212.1 -bin $OUTPUT_DIR_masks_L/$SUBJ\b_fimbria_mask_L.nii.gz # Extract left fimbria
        fslmaths $d/$SUBJ\b_lh.hippoAmygLabels.nii.gz -thr 213.9 -uthr 214.1 -bin $OUTPUT_DIR_masks_L/$SUBJ\b_molec_layer_HP_mask_L.nii.gz # Extract left molecular layer HP
        fslmaths $d/$SUBJ\b_lh.hippoAmygLabels.nii.gz -thr 214.9 -uthr 215.1 -bin $OUTPUT_DIR_masks_L/$SUBJ\b_hipp_fissure_mask_L.nii.gz # Extract left hippocampal fissure
        fslmaths $d/$SUBJ\b_lh.hippoAmygLabels.nii.gz -thr 225.9 -uthr 226.1 -bin $OUTPUT_DIR_masks_L/$SUBJ\b_HP_tail_mask_L.nii.gz # Extract left HP tail
        fslmaths $d/$SUBJ\b_lh.hippoAmygLabels.nii.gz -thr 7000.9 -uthr 7001.1 -bin $OUTPUT_DIR_masks_L/$SUBJ\b_lat_nucleus_mask_L.nii.gz # Extract left lateral nucleus
        fslmaths $d/$SUBJ\b_lh.hippoAmygLabels.nii.gz -thr 7002.9 -uthr 7003.1 -bin $OUTPUT_DIR_masks_L/$SUBJ\b_bas_nucleus_mask_L.nii.gz # Extract left basal nucleus
        fslmaths $d/$SUBJ\b_lh.hippoAmygLabels.nii.gz -thr 7004.9 -uthr 7005.1 -bin $OUTPUT_DIR_masks_L/$SUBJ\b_cen_nucleus_mask_L.nii.gz # Extract left central nucleus
        fslmaths $d/$SUBJ\b_lh.hippoAmygLabels.nii.gz -thr 7005.9 -uthr 7006.1 -bin $OUTPUT_DIR_masks_L/$SUBJ\b_med_nucleus_mask_L.nii.gz # Extract left medial nucleus
        fslmaths $d/$SUBJ\b_lh.hippoAmygLabels.nii.gz -thr 7006.9 -uthr 7007.1 -bin $OUTPUT_DIR_masks_L/$SUBJ\b_cor_nucleus_mask_L.nii.gz # Extract left cortical nucleus
        fslmaths $d/$SUBJ\b_lh.hippoAmygLabels.nii.gz -thr 7007.9 -uthr 7008.1 -bin $OUTPUT_DIR_masks_L/$SUBJ\b_acc-bas_nucleus_mask_L.nii.gz # Extract left accessory basal nucleus
        fslmaths $d/$SUBJ\b_lh.hippoAmygLabels.nii.gz -thr 7008.9 -uthr 7009.1 -bin $OUTPUT_DIR_masks_L/$SUBJ\b_corticoamygdaloid_trans_mask_L.nii.gz # Extract left corticoamygdaloid transition
        fslmaths $d/$SUBJ\b_lh.hippoAmygLabels.nii.gz -thr 7009.9 -uthr 7010.1 -bin $OUTPUT_DIR_masks_L/$SUBJ\b_ant_amygdaloid_mask_L.nii.gz # Extract left anterior amygdaloid area
        fslmaths $d/$SUBJ\b_lh.hippoAmygLabels.nii.gz -thr 7014.9 -uthr 7015.1 -bin $OUTPUT_DIR_masks_L/$SUBJ\b_para_nucleus_mask_L.nii.gz # Extract left paralaminar nucleus

        echo -e "\n...Complete."

        echo -e "\nRight hippocampus..."

        fslmaths $d/$SUBJ\b_rh.hippoAmygLabels.nii.gz -thr 202.9 -uthr 203.1 -bin $OUTPUT_DIR_masks_R/$SUBJ\b_parasubiculum_mask_R.nii.gz # Extract left parasubiculum
        fslmaths $d/$SUBJ\b_rh.hippoAmygLabels.nii.gz -thr 203.9 -uthr 204.1 -bin $OUTPUT_DIR_masks_R/$SUBJ\b_presubiculum_mask_R.nii.gz # Extract left presubiculum
        fslmaths $d/$SUBJ\b_rh.hippoAmygLabels.nii.gz -thr 204.9 -uthr 205.1 -bin $OUTPUT_DIR_masks_R/$SUBJ\b_subiculum_mask_R.nii.gz # Extract left subiculum
        fslmaths $d/$SUBJ\b_rh.hippoAmygLabels.nii.gz -thr 205.9 -uthr 206.1 -bin $OUTPUT_DIR_masks_R/$SUBJ\b_CA1_mask_R.nii.gz # Extract left CA1
        fslmaths $d/$SUBJ\b_rh.hippoAmygLabels.nii.gz -thr 207.9 -uthr 208.1 -bin $OUTPUT_DIR_masks_R/$SUBJ\b_CA3_mask_R.nii.gz # Extract left CA3
        fslmaths $d/$SUBJ\b_rh.hippoAmygLabels.nii.gz -thr 208.9 -uthr 209.1 -bin $OUTPUT_DIR_masks_R/$SUBJ\b_CA4_mask_R.nii.gz # Extract left CA4
        fslmaths $d/$SUBJ\b_rh.hippoAmygLabels.nii.gz -thr 209.9 -uthr 210.1 -bin $OUTPUT_DIR_masks_R/$SUBJ\b_GC-DG_mask_R.nii.gz # Extract left GC-DG
        fslmaths $d/$SUBJ\b_rh.hippoAmygLabels.nii.gz -thr 210.9 -uthr 211.1 -bin $OUTPUT_DIR_masks_R/$SUBJ\b_HATA_mask_R.nii.gz # Extract left HATA
        fslmaths $d/$SUBJ\b_rh.hippoAmygLabels.nii.gz -thr 211.9 -uthr 212.1 -bin $OUTPUT_DIR_masks_R/$SUBJ\b_fimbria_mask_R.nii.gz # Extract left fimbria
        fslmaths $d/$SUBJ\b_rh.hippoAmygLabels.nii.gz -thr 213.9 -uthr 214.1 -bin $OUTPUT_DIR_masks_R/$SUBJ\b_molec_layer_HP_mask_R.nii.gz # Extract left molecular layer HP
        fslmaths $d/$SUBJ\b_rh.hippoAmygLabels.nii.gz -thr 214.9 -uthr 215.1 -bin $OUTPUT_DIR_masks_R/$SUBJ\b_hipp_fissure_mask_R.nii.gz # Extract left hippocampal fissure
        fslmaths $d/$SUBJ\b_rh.hippoAmygLabels.nii.gz -thr 225.9 -uthr 226.1 -bin $OUTPUT_DIR_masks_R/$SUBJ\b_HP_tail_mask_R.nii.gz # Extract left HP tail
        fslmaths $d/$SUBJ\b_rh.hippoAmygLabels.nii.gz -thr 7000.9 -uthr 7001.1 -bin $OUTPUT_DIR_masks_R/$SUBJ\b_lat_nucleus_mask_R.nii.gz # Extract left lateral nucleus
        fslmaths $d/$SUBJ\b_rh.hippoAmygLabels.nii.gz -thr 7002.9 -uthr 7003.1 -bin $OUTPUT_DIR_masks_R/$SUBJ\b_bas_nucleus_mask_R.nii.gz # Extract left basal nucleus
        fslmaths $d/$SUBJ\b_rh.hippoAmygLabels.nii.gz -thr 7004.9 -uthr 7005.1 -bin $OUTPUT_DIR_masks_R/$SUBJ\b_cen_nucleus_mask_R.nii.gz # Extract left central nucleus
        fslmaths $d/$SUBJ\b_rh.hippoAmygLabels.nii.gz -thr 7005.9 -uthr 7006.1 -bin $OUTPUT_DIR_masks_R/$SUBJ\b_med_nucleus_mask_R.nii.gz # Extract left medial nucleus
        fslmaths $d/$SUBJ\b_rh.hippoAmygLabels.nii.gz -thr 7006.9 -uthr 7007.1 -bin $OUTPUT_DIR_masks_R/$SUBJ\b_cor_nucleus_mask_R.nii.gz # Extract left cortical nucleus
        fslmaths $d/$SUBJ\b_rh.hippoAmygLabels.nii.gz -thr 7007.9 -uthr 7008.1 -bin $OUTPUT_DIR_masks_R/$SUBJ\b_acc-bas_nucleus_mask_R.nii.gz # Extract left accessory basal nucleus
        fslmaths $d/$SUBJ\b_rh.hippoAmygLabels.nii.gz -thr 7008.9 -uthr 7009.1 -bin $OUTPUT_DIR_masks_R/$SUBJ\b_corticoamygdaloid_trans_mask_R.nii.gz # Extract left corticoamygdaloid transition
        fslmaths $d/$SUBJ\b_rh.hippoAmygLabels.nii.gz -thr 7009.9 -uthr 7010.1 -bin $OUTPUT_DIR_masks_R/$SUBJ\b_ant_amygdaloid_mask_R.nii.gz # Extract left anterior amygdaloid area
        fslmaths $d/$SUBJ\b_rh.hippoAmygLabels.nii.gz -thr 7014.9 -uthr 7015.1 -bin $OUTPUT_DIR_masks_R/$SUBJ\b_para_nucleus_mask_R.nii.gz # Extract left paralaminar nucleus

        echo -e "\n...Complete."  

    fi

    cp $d/$SUBJ\b_T1.nii.gz $OUTPUT_DIR
    #cp $d/$SUBJ\b_aseg.nii.gz $OUTPUT_DIR

done



# ########################################################################################################################################################################################################
# # Program is complete

# echo -e "\n\n####################################################################################################"
# echo -e "\nNOTICE: The script has completed."
# echo -e "\n####################################################################################################"