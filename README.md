# hippo_morph_old
The old, clunky, and outdated code for my hippocampal morphometry pipeline. The scripts located here are for documentation/preservation purposes only and have largely been replaced by my Python-based workflow.

Primarily BASH script-based. Requires [hippodeep_pytorch](https://github.com/bthyreau/hippodeep_pytorch) and [SlicerSALT](https://salt.slicer.org/).

The intended order of running these scripts goes something like this:

1. `SAP_create_project.sh` to create a basic directory hierarchy for the project and the various files produced by segmentation, SPHARM-PDM, SlicerSALT modules, etc.
   
2. `SAP_hippodeep_seg.sh` for **fast, machine learning-based hippocampal (only) segmentation** via _hippodeep_pytorch_ or `SAP_FS_seg.sh` for **[FreeSurfer-based](https://surfer.nmr.mgh.harvard.edu/) multi-ROI segmentation**. `batch_hippodeep_seg.sh` is an older version of the former.
   
3. If using FreeSurfer to segment your T1-weighted images, `SAP_extract_ROIs.sh` will use [FSL](https://fsl.fmrib.ox.ac.uk/fsl/docs/#/)'s `fslmaths` tool to extract your segmented volumes (masks) using FreeSurfer's `aseg.nii.gz` label map.
   
4. `SAP_SPHARM_P920.sh` for running SlicerSALT's [SPHARM-PDM](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3062073/) computation on the newly produced segmentation volumes.
   
5. `batch_model2model_distance.py` and `SAP_meshmath.py` are both ways to interact with SlicerSALT's ["Model to Model Distance"](https://www.slicer.org/wiki/Documentation/Nightly/Extensions/ModelToModelDistance) module/functionality via command line for batch processing of multiple VTK files. Requires VTK models produced via SPHARM-PDM.

`SAP_extract_points.py` is not required for the pipeline, but is a script that goes through a directory of VTK models, extracts the Cartesian coordinates of each model's vertices, and saves them to a per-model CSV file. Useful for calculating vectors, visualizing a model as a 3D scatterplot/point cloud in MATLAB, etc.

The MATLAB_scripts folder contains `vtk_insula_test.m` and `SAP_plot_sig_vert.m`, as well as a handful of CSV and VTK files. `vtk_insula_test.m` is a simple demo to visualize the vertices/points of the included `L_insula.vtk` model as a point cloud/3D scatter plot. `SAP_plot_sig_vert.m` is meant to identify vertices/points that experienced significant change (via vector data contained in the included CSV files) and highlight them in a point cloud/3D scatter plot using the vertices of a template hippocampus contained in `template_vertices.csv`. Significance is calculated via a one-sample Wilcoxon signed rank test. `SAP_plot_sig_vert.m` requires some additional MATLAB toolboxes (Bioinformatics, etc.) to be installed.

Refer to comments in code for detailed directions on running these scripts.
