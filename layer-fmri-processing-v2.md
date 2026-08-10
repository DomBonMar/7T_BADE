# Layer fMRI Processing

## 1. Install Relevant Software

### matlab & spm

MATLAB is [available through McGill](https://mcgill.service-now.com/itportal?id=kb_article_view&sysparm_article=KB0011460) and [SPM](https://www.fil.ion.ucl.ac.uk/spm/docs/) is a free package for MATLAB.

### dcm2niix

dcm2niix is a standalone package for converting dicom (or Siemens image, .IMA) to nifti formats. Follow the [installation instructions](https://github.com/rordenlab/dcm2niix) for your operating system.

### fsl (fsleyes)

fsl is a comprehensive neuroimaging analysis toolbox with a nice image viewer (fsleyes). Follow the [installation instructions](https://fsl.fmrib.ox.ac.uk/fsl/docs/#/) for your operating system.

### afni

afni is a software suite for analysis of functional images. Follow the [installation instructions](https://afni.nimh.nih.gov/pub/dist/doc/htmldoc/background_install/main_toc.html) for your operating system.

### laynii

laynii is a standalone software for layer fMRI analysis. Follow the [installation instructions](https://github.com/layerfMRI/LAYNII) for your operating system.

## 2. Separate nulled (VASO) & non-nulled (BOLD) data

### matlab

**Note: Only necessary if using an older VASO sequence**

Use script under "layer-7t-predictive-coding\code\contrast-separation_Atena" (OneDrive).

**For newer sequences**

This step gets performed automatically when converting to nifti format (step 3).

## 3. Convert nulled and non-nulled to nifti format

### dcm2niix

If on DNP, you'll need to load the module to be able to use it.

```bash
module load dcm2niix
```

Then, use the command line or drag and drop the folder.

```bash
cd /data/lavlab/layer-7t-predictive-coding/data/ # directory with all data
cd pilot02 # goes into file of specific subject to process
mkdir nifti

# directory tree should look like
# data
# |
# --> pilot01
# |     |
# |     --> dicom
# |     --> nifti
# --> pilot02
#       |
#       --> dicom
#       --> nifti

#dcm2niix -b y -f vaso_task_pilot01_%d_%s -o onedrive/research/layer-7t-predictive-coding/pilot/pilot01/nifti/ onedrive/research/layer-7t-predictive-coding/pilot/pilot01/dicom/task/vaso

dcm2niix -b y -f pilot02_%d_%s -o ./nifti/ ./dicom/
```

dcm2niix will then separate all the dicom images into the separate nifti scans (ie, anatomical + functional images).

BOLD vs VASO functional scans can be identified via their sequence code.

Ex: "pilot02_rslh_ep3d_vaso_Trials1_E00_S00_M_11.nii"

Here, the relevant info is the 'S00' code, which indicates a BOLD sequence. VASO sequences have the 'S01' code. You should have one of each sequence for every functional run (or Trial).

## 4. Raw quality control (QC)

### fsleyes

Open the 4D VASO or BOLD series in fsleyes and click on the Movie icon (looks like a film strip). Watch the software cycle through the different volumes to ensure the intensity of the images is uniform across different volumes to ensure the separation worked properly. Do this for VASO and BOLD separately.

Essentially, we check whether the VASO / BOLD images were successfully separated. Each image type can have noticeably different image intensities.

## 5. Motion correction

### matlab & spm

For more details, refer to the [spm documentation](https://www.fil.ion.ucl.ac.uk/spm/docs/tutorials/fmri/block/preprocessing/realignment/).

**5.1. Launch spm**

In the matlab terminal, type ```spm fmri```

**5.2. Realignment**

On the main spm window, click the top left option **Realign >> Realign (Est + Reslice)**

**5.3. Creating session**

A new window should pop up (this is the batch editor). Navigate to **Data**, and double-click the option to add a session. Then, navigate to **Selection** and click on the **Specify** button at the bottom of the window.

**5.4. Selecting data**

In the navigator, find the correct 4D image (a nifti .nii file) to realign. Make sure to replace the **1** in the box near the filter option with **nan** in order to get a proper list of files, then select the target .nii file from the list. When correctly selected, click **Done** to exit the window.

**5.5. Reslice options**

Back in the previous window, navigate to the **Resliced Images** options. Ensure that **All Images + Mean Image** is selected (this should be the default).

**5.6. Adding runs**

If a participant underwent multiple runs, each run must be added as a separate module. In the window, the left column showcases all the modules to be run. Right-click on the module created for the first run, and select **Replicate Module**. Then, navigate to the **Data >> Session** and add the next run via the **Specify** button. Continue replicating modules for each individual run of data to be added.

IMPORTANT: Run this computation on VASO / BOLD runs separately (ie. realign all the bold runs in separate modules at once, then repeat the process from scratch for the vaso runs). BOLD files end with the 'S00' tag, whereas VASO files end with the 'S01' tag.

**5.7. Run the batch**

First, save the batch to have a record of run operations. Then, click the green arrow at the top to run the realignment process.

**5.8. Outputs**

If run correctly, each run should produce three ouputs:

1 - A mean image (preceded by 'mean')
2 - A realigned 4D image (preceded by 'r')
3 - A text file with motion correction details

## 6. Compute T1-like image from VASO (if no anatomical image)

### afni

(Note: you need to load the module first to use its commands on the DNP.)

```bash
module load AFNI
```

If no anatomical image is available, it is possible to generate a T1-like image from the VASO. Open a terminal and use the following command (modify as appropriate):

Command structure:

```bash
3dcalc -a <meanbold.nii> -b <meanvaso.nii> -expr '(a+b)/(a-b)' -prefix t1-like.nii -overwrite
```

Katie's example:

```bash
3dcalc -a meanabold_rest_pilot01_rslh_ep3d_vaso_fullbrain_0.8x0.8x0.9_E00_M_7.nii -b meanavaso_rest_pilot01_rslh_ep3d_vaso_fullbrain_0.8x0.8x0.9_E00_M_7.nii -expr '(a+b)/(a-b)' -prefix t1-like.nii -overwrite
```

What I ran:

```bash
3dcalc -a meanpilot02_rslh_ep3d_vaso_Trials1_E00_S00_M_11.nii -b meanpilot02_rslh_ep3d_vaso_Trials1_E00_S01_M_12.nii -expr '(a+b)/(a-b)' -prefix t1-like_Trials1.nii -overwrite

3dcalc -a meanpilot02_rslh_ep3d_vaso_Trials2_E00_S00_M_13.nii -b meanpilot02_rslh_ep3d_vaso_Trials2_E00_S01_M_14.nii -expr '(a+b)/(a-b)' -prefix t1-like_Trials2.nii -overwrite

3dcalc -a meanpilot02_rslh_ep3d_vaso_Trials3_E00_S00_M_15.nii -b meanpilot02_rslh_ep3d_vaso_Trials3_E00_S01_M_16.nii -expr '(a+b)/(a-b)' -prefix t1-like_Trials3.nii -overwrite
```

## 7. Co-registration (if anatomical image available)

### matlab & spm

For more details, refer to the [spm documentation](https://www.fil.ion.ucl.ac.uk/spm/docs/tutorials/fmri/block/preprocessing/coregistration/).

**7.1. Launch spm**

In the matlab terminal, type ```spm fmri```

**7.2. Realignment**

On the main spm window, click the option **Coregister >> Coregister: Estimate**

**7.3. Reference image**

Navigate to **Fixed Image** and then specify the anatomical file to use. The target scan is the T1w image (or the UNI scan resulting from the nifti conversion process)

**7.4. Source image**

Navigate to **Moved Image** and then specify the mean image to use. The target image is the mean image generated from the realignment step.

**7.5. Other images**

Navigate to **Other Images** and then specify the resliced images for the run. The target image is the raw r*.nii trial run obtained from realignment.

**7.6. Adding runs**

Similarly to the realignment step, if a participant has multiple runs, each module must be replicated with the run data separately.

**7.7. Run the batch**

First, save the batch to have a record of run operations. Then, click the green arrow at the top to run the coregistration process.

**7.8. Outputs**

No direct output is observed from this step, but the mean image gets coregistered to the anatomical scan.

## 8. Correct for T2* dependency

### laynii

This step is required to clean the vaso signal which might contain bold contamination. Use ln_boco command, and clean each pair of mean images separately.

Command structure:
```bash
LN_BOCO -Nulled <vaso_run.nii> -BOLD <bold_run.nii>
```

Katie's Example:

```bash
LN_BOCO -Nulled ../../../research/layer-7t-predictive-coding/pilot/pilot01/nifti/meanavaso_rest_pilot01_rslh_ep3d_vaso_fullbrain_0.8x0.8x0.9_E00_M_7.nii -BOLD ../../../research/layer-7t-predictive-coding/pilot/pilot01/nifti/meanabold_rest_pilot01_rslh_ep3d_vaso_fullbrain_0.8x0.8x0.9_E00_M_7.nii
```

Actually what I ran:

```bash
cd nifti
~/Documents/APPS/LayNii/LN_BOCO -Nulled meanpilot02_rslh_ep3d_vaso_Trials1_E00_S01_M_12.nii -BOLD meanpilot02_rslh_ep3d_vaso_Trials1_E00_S00_M_11.nii
mv VASO_LN.nii meanpilot02_clean_vaso_Trials1.nii

~/Documents/APPS/LayNii/LN_BOCO -Nulled meanpilot02_rslh_ep3d_vaso_Trials2_E00_S01_M_14.nii -BOLD meanpilot02_rslh_ep3d_vaso_Trials2_E00_S00_M_13.nii
mv VASO_LN.nii meanpilot02_clean_vaso_Trials2.nii

~/Documents/APPS/LayNii/LN_BOCO -Nulled meanpilot02_rslh_ep3d_vaso_Trials3_E00_S01_M_16.nii -BOLD meanpilot02_rslh_ep3d_vaso_Trials3_E00_S00_M_15.nii
mv VASO_LN.nii meanpilot02_clean_vaso_Trials3.nii
```

## 8. Segmentation

**8.1. Launch spm**

In the matlab terminal, type ```spm fmri```

**8.2. Segmentation**

On the main spm window, click the option **Segment**

**8.3. Reference image**

Navigate to **Data >> Volumes** and then specify the anatomical file to use. The target scan is the T1w image (or the UNI scan resulting from the nifti conversion process)

**8.4. INU Correction**

Navigate to **Save INU Corrected** and then specify **Save INU Corrected**.

**8.5. Other images**

Navigate to **Deformation Fields** and then specify **Forward** as a direction.

**8.6. Outputs**

1. Tissue-specific images (ie, CSF, GM, WM) indexed by the prefix **c**

2. An intensity nonuniformity corrected structural image prefixed by **m**

3. A deformation field prefixed by **y** which will be used to normalise functional scans


## 9. Normalisation

**9.1. Launch spm**

In the matlab terminal, type ```spm fmri```

**9.2. Normalisation**

On the main spm window, click the option **Normalise >> Write**

**9.3. Creating Session**

Navigate to **Data >> New Subject** to create a new session.

**9.4. Deformation Field**

Navigate to **Deformation Field** and then specify the file prefixed by **y** created during the segmentation process.

**9.5. Functional Images**

Navigate to **Images to Write** and then specify the realigned + slice time corrected functional scans prefixed by **r**.

**9.6. Voxel Size**

Navigate to **Writing Options >> Voxel Sizes** and then specify the size of voxels to use. For 7T, can go down to [1 1 1] or keep [2 2 2].

**9.7. Outputs**

Normalised version of the functional images prefixed by **w**

## 10. Smothing

**10.1. Launch spm**

In the matlab terminal, type ```spm fmri```

**10.2. Smoothing**

On the main spm window, click the option **Smooth**

**10.3. Adding Images**

Navigate to **Images to Smooth** and add all the functional images generated by the Normalisation step prefixed by "wr".

**10.4. Outputs**

Smoothed version of the functional images prefixed by **swr**.

## 10. Draw ROI

### fsleyes

- Open fsleyes and the T1-like or processed T1-weighted image.
- Open drawing tools.
- Create a new image on top of the loaded image to draw on.
    1) Grey-CSF border
    2) Grey-White matter
    3) Closes boundaries
- Fill it out with the bucket.
- Save as rim.
- Only need to do 1-3 slices (as many as you can to see nice contrast).

## 11. Generate layers

### laynii

Use ln2_grow_layers to generate the layers from the mask file. Outputs a layered version of the mask.

Command structure:

```bash
./LN_GROW_LAYERS -rim <mask_file.rim.nii.gz> -N <num layers>
```

Katie's Example:

```bash
./LN_GROW_LAYERS -rim ../../../research/layer-7t-predictive-coding/pilot/pilot01/nifti/T1_rest/T1_rest_thresh_mask.nii.gz -N 10
```

Tests I ran:

```bash
~/Documents/APPS/LayNii/LN_GROW_LAYERS -rim pilot02_anat-T1w_acq-mp2rage_05mm_UP_UNI_Images_10_mask_VC2.nii.gz -N 10
```

## 12. Extract layer profiles

### laynii

Use ln_profile2 command:

```bash
./LN2_PROFILE -input ../../../research/layer-7t-predictive-coding/pilot/pilot01/nifti/meanabold_rest_pilot01_rslh_ep3d_vaso_fullbrain_0.8x0.8x0.9_E00_M_7.nii -layers ../../../research/layer-7t-predictive-coding/pilot/pilot01/nifti/T1_rest/T1_rest_thresh_mask_layers.nii.gz -plot -output ../../../research/layer-7t-predictive-coding/pilot/pilot01/nifti/T1_rest/layer-profile-bold.txt
```

## 13. First-level analysis

### Prepare Timing Vectors

Use the script at ``layer-7t-predictive-coding/code/timing_vectors_mat.py``

This will generate the timing details of the BADE task and convert them into MATLAB arrays that can be used in SPM.

Then, load the timing vectors in MATLAB by running ``layer-7t-predictive-coding/code/load_timing_vectors.m``

This will create a structure **data** that contains all the timing vectors.

To index a specific subject/run/condition array, use ``data.{subject}_run{run_ID}_{condition_label}``

### SPM analysis

**13.1. Launch spm**

In the matlab terminal, type ```spm fmri```

**13.2. First-Level**

On the main spm window, click the option **Specify 1st Level**

**13.3. Creating Directory**

First, create a directory to store outputs: ``mkdir first_level_analysis``

Then, navigate to **Directory** and select the created directory above.

**13.4. Timing Parameters**

Navigate to **Timing Parameters** and then specify the following:

For **Units**, select **Seconds**

For **Interscan interval**, select your correspnding TR value.

Leave the remaining fields at their default values.

**13.5. Functional Images**

Navigate to **Data and Design**. For each individual run, select **New Subject/Session**.

For each run, input the following:

For **Scans**, select one of the **wr** prefixed functional runs.

In the **Conditions** tab, select **New Condition** for each individual task condition.

For each condition:

>> Select its **Name**.

>> For **Onsets**, point it toward the timing vectors imported into MATLAB.

>> Set the appropriate **Duration** of the trial.

Then, in **Multiple regressors**, add the text file with motion correction parameters (rp**.txt file) corresponding to the run in question.

**13.6. Analysis Parameters**

Navigate to **Basis Functions >> Canonical HRF** and select **Model derivatives >> Time derivatives**.

Leave the rest of the parameters at their defaults.

**13.7. Outputs**

An **SPM.mat** file will be produced in the specified folder.

## 14. Model Estimation

**14.1. Launch spm**

In the matlab terminal, type ```spm fmri```

**14.2. Estimate Mode**

On the main spm window, click the option **Estimate**

**14.3. Analysis File**

Navigate to **Select SPM.mat** and select the **SPM.mat** file created in the first-level analysis.

**14.4 Options**

Leave **Write Residuals** as **No** and leave **Method** as **Classical**. Then, save the batch and run the analysis.

**14.5 Outputs**

All outputs get saved in the same folder containing the SPM.mat file.

>> **mask.nii** is a binary file indicating the brain mask used for analysis

>> **beta_xxx.nii** are the regression coefficient maps

>> **ResMS.nii** are the residual sums of squares (voxel-level)

>> **RPV.nii** are the resels of the voxels (smoothness of estimate)

## 15 Inference

**15.1. Launch spm**

In the matlab terminal, type ```spm fmri```

**15.2. Results Mode**

On the main spm window, click the option **Results**. This will launch the contrast manager window.

**15.3. Defining Contrasts**

To define a new contrast, select the **t contrast** option, then click **Define New Contrast** at the bottom.

Give the contrast a name.

Input the contrast vector (weights of the betas), and hit **Ok**.

Pilot 01 vectprs:

Disconfirm - Confirm = [-1 0 1 0 0 0   0 0 0 0 0 0 0]

Disconfirm - Baseline = [0 0 1 0 -1 0   0 0 0 0 0 0 0]

Confirm - Baseline = [1 0 0 0 -1 0   0 0 0 0 0 0 0]

Pilot 02 vectors:

Disconfirm - Confirm = [-1 0 1 0 0 0   0 0 0 0 0 0   -1 0 1 0 0 0   0 0 0 0 0 0   -1 0 1 0 0 0  0 0 0 0 0 0  0 0 0]

Disconfirm - Baseline = [0 0 1 0 -1 0   0 0 0 0 0 0   0 0 1 0 -1 0   0 0 0 0 0 0   0 0 1 0 -1 0  0 0 0 0 0 0  0 0 0]

Confirm - Baseline = [1 0 0 0 -1 0   0 0 0 0 0 0   1 0 0 0 -1 0   0 0 0 0 0 0   1 0 0 0 -1 0  0 0 0 0 0 0  0 0 0]

**15.4. Running Analysis**

When you hit **Done** after finalizing the contrast, you need to answer questions.

(fill question details)