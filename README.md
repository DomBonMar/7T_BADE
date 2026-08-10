# Layer fMRI Processing

README file written by Domenico + Katie

# 0 - SETUP

## 0.1: Install Relevant Software

### matlab & spm

MATLAB is [available through McGill](https://mcgill.service-now.com/itportal?id=kb_article_view&sysparm_article=KB0011460) and [SPM](https://www.fil.ion.ucl.ac.uk/spm/docs/) is a free package for MATLAB.

### dcm2niix & dcm2bids

dcm2niix is a standalone package for converting dicom (or Siemens image, .IMA) to nifti formats. Follow the [installation instructions](https://github.com/rordenlab/dcm2niix) for your operating system.

dcm2bids builds off the previous package, allowing for direct sorting of nifti files into bids format. Follow the [installation instructions](https://unfmontreal.github.io/Dcm2Bids/3.2.0/) for your operating system.

### fsl (fsleyes)

fsl is a comprehensive neuroimaging analysis toolbox with a nice image viewer (fsleyes). Follow the [installation instructions](https://fsl.fmrib.ox.ac.uk/fsl/docs/#/) for your operating system.

### afni

afni is a software suite for analysis of functional images. Follow the [installation instructions](https://afni.nimh.nih.gov/pub/dist/doc/htmldoc/background_install/main_toc.html) for your operating system.

### laynii

laynii is a standalone software for layer fMRI analysis. Follow the [installation instructions](https://github.com/layerfMRI/LAYNII) for your operating system.

### nordic

nordic is a denoising algorithm for 4D functional images. To use it, install the [nordic script](https://github.com/SteenMoeller/NORDIC_Raw/blob/main/NIFTI_NORDIC.m) and the [vaso wrapper](https://github.com/LasseKnudsen1/NORDIC-VASO/blob/main/NORDIC_VASO_wrapper.m) into a folder called NORDIC.

## 0.2: Setup directory structure

Data directory tree should look like:

data \
├── bade_fmri_task \
├── beads_task\
├── ch_task\
├── discourse_task \
├── mri \
│   ├── bids \
│   │   ├── sub-X \
│   │   │   ├── anat \
│   │   │   ├── fmap \
│   │   │   └── func \
│   │   ├── sub-Y \
│   │   │   ├── anat \
│   │   │   ├── fmap \
│   │   │   └── func \
│   │   └── tmp_dcm2bids \
│   │       ├── log \
│   │       ├── sub-X \
│   │       └── sub-Y\
│   ├── dicom \
│   │	├── sub-X \
│   │   └── sub-Y \
│   ├── minc \
│	│	├── sub-X\
│   │   └── sub-Y\
│   └── spm\
│		├── sub-X\
│       └── sub-Y\
└── physio\

### Folder descriptions

bade_fmri_task: files containing MRI task details

beads_task:	files containing beads task details

ch_task: files containing conditioned hallucinations task details

discourse_task: files containing discourse task details

mri: folder storing all imaging data

	* bids: anatomical, functional, and fmap nifti images per subject
	* dicom / minc: respective image types
	* spm: preprocessed images

physio: contains physiological scan details

## 0.3: Adding data to folders

Manually place the scan images, task details, and physiological data into their respective folders.

For MRI scans, only raw dicom and nifti need to be added. Bids and spm folders will be filled at later steps.

## 0.4: Separate nulled (VASO) & non-nulled (BOLD) data

BOLD vs VASO functional scans can be identified via their sequence code.

Ex: "pilot02_rslh_ep3d_vaso_Trials1_E00_S00_M_11.nii"

Here, the relevant info is the 'S00' code, which indicates a VASO sequence. BOLD sequences have the 'S01' code. You should have one of each sequence for every functional run (or Trial).

### matlab

**Note: Only necessary if using an older VASO sequence**

Use script under "layer-7t-predictive-coding\code\contrast-separation_Atena" (OneDrive).

**For newer sequences**

This step gets performed automatically when converting to nifti format (step 3).

# 1 - IMAGE PRE-PROCESSING

All pre-processing steps are coded in **preprocessing_script.m**. Here is a detailed outline for running individual steps.

## 1.1: Convert nulled and non-nulled to nifti format

### dcm2niix

If on DNP, you'll need to load the modules to be able to use them.

```bash
echo "loading required modules"
module load dcm2niix
module load dcm2bids
```

Use the dicom folder as input for the conversion. The dcm2bids operation also requires a **bids-config.json** file to sort the relevant scans from the acquisition. An example of this file is provided alongside the scripts.

```bash
dcm2bids -d <dicom-dir> -p <subject-id> -c <bids-config.json> -o <output-bids-dir>
```

**Output**: A fully sorted bids directory with distinct anat, func, and fmap folders for all the relevant sequences.

## Raw quality control (QC)

### fsleyes

Open the 4D VASO or BOLD series in fsleyes and click on the Movie icon (looks like a film strip). Watch the software cycle through the different volumes to ensure the intensity of the images is uniform across different volumes to ensure the separation worked properly. Do this for VASO and BOLD separately.

Essentially, we check whether the VASO / BOLD images were successfully separated. Each image type can have noticeably different image intensities.

## 1.2: Defacing anatomical images

### Python

First, load the modules and install the pydeface package for python.

```bash
echo "Loading required modules"
module load python
module load FSL

echo "Installing pydeface"
pip install pydeface
```


All the anatomical scans need to be defaced. Use the following command structure:

```bash
pydeface <anat-scan.nii>
```

**Output**: <anat-scan_defaced.nii> will be a defaced version of the original input scan.

## 1.3: Applying thermal denoising

### matlab & nordic

Using the **NIFTI_NORDIC.m** script, denoising is applied to each of the functional runs (vaso / bold).

**Output**: <**n**_func-image.nii>

## 1.4: Motion correction

### matlab & spm

The manual procedure for applying motion correction is detailed below. For more information, refer to the [spm documentation](https://www.fil.ion.ucl.ac.uk/spm/docs/tutorials/fmri/block/preprocessing/realignment/).

**1. Launch spm**

In the matlab terminal, type ```spm fmri```

**2. Realignment**

In the main spm window, click the top left option **Realign >> Realign (Est + Reslice)**

**3. Creating session**

A new window should pop up (this is the batch editor). Navigate to **Data**, and double-click the option to add a session. Then, navigate to **Selection** and click on the **Specify** button at the bottom of the window.

**4. Selecting data**

In the navigator, find the target 4D image (.nii) to realign. Make sure to replace the **1** in the box near the filter option with **nan** in order to get a proper list of files, then select the target .nii file from the list. Once selected, click **Done** to exit the window.

**5. Reslice options**

Back in the previous window, navigate to the **Resliced Images** options. Ensure that **All Images + Mean Image** is selected (this should be the default).

**6. Adding runs**

If a participant underwent multiple runs, each run must be added as a separate module. In the main window, the left column showcases all the modules to be run. Right-click on the module created for the first run, and select **Replicate Module**. Then, navigate to the **Data >> Session** and add the next run via the **Specify** button. Continue replicating modules for each individual run of data to be added.

IMPORTANT: Run this computation on VASO / BOLD runs separately.

**7. Run the batch**

First, save the batch to have a record of all performed operations. Then, click the green arrow at the top to run the realignment process.

**8. Outputs**

If run correctly, each run should produce three ouputs:

1 - A mean image (preceded by 'mean')

2 - A realigned 4D image (preceded by 'r')

3 - A text file with motion correction details

## 1.5: BOLD correction

### laynii & afni

This step is required to clean the vaso signal which contains contamination from BOLD's T2* dependent signal. Use the **LN_BOCO** command, and clean each pair of images separately (mean and 4D images).

Command structure:
```bash
echo "Loading required module"
module load AFNI

echo "Performing BOLD correction"
LN_BOCO -Nulled <vaso_run.nii> -BOLD <bold_run.nii>
```

**Output**: The file <**VASO_LN.nii**> containing the de-contaminated VASO image gets created. Make sure to rename this file to avoid overwriting it by accident.

## 1.6: Compute T1-like image

If no anatomical image is available, it is possible to generate a T1-like image from the VASO signal.

### matlab

First, you need to determine the functional run which exhibited the least amount of motion. This run will be used as a template to generate our T1-like image.

In matlab, load the text files that were created during the motion correction step, and plot them.

```matlab
MOCO_INFO = load("rp_func-run.txt")
plot(MOCO_INFO)
```

Based on the obtained plots, determine the pair of BOLD / VASO runs that showcase the least motion.

### afni

Open a terminal and use the following command:

```bash
echo "Loading required module"
module load AFNI

echo "Generating T1-like image"
3dcalc -a <mean-bold.nii> -b <mean-vaso.nii> -expr "(a+b)/(a-b)" -datum float -prefix <t1-like.nii> -overwrite
```

**Output**: A t1-like image named according to the prefix given in the previous command.

## 1.7: Co-registration (if anatomical image available)

The manual procedure for co-registering runs is detailed below. For more information, refer to the [spm documentation](https://www.fil.ion.ucl.ac.uk/spm/docs/tutorials/fmri/block/preprocessing/coregistration/).

### matlab & spm

**1. Launch spm**

In the matlab terminal, type ```spm fmri```

**2. Realignment**

In the main spm window, click the option **Coregister >> Coregister: Estimate + Reslice**

**3. Reference image**

Navigate to **Fixed Image** and then specify the target registration file to use. The target scan is the mean image of the least motion run.

**4. Source image**

Navigate to **Moved Image** and then specify the mean image of another run. This image will be co-registered to the target fixed image.

**5. Other images**

Navigate to **Other Images** and then specify the resliced images for the same run. The target image volumes come from the r*.nii run obtained after realignment.

**6. Adding runs**

Similarly to the realignment step, if a participant has multiple runs, each module must be replicated with the run data separately. Only **Source** and **Other** images should be changed between sessions. The **Fixed** image remains the mean image with the least motion.

**7. Run the batch**

First, save the batch to have a record of all performed operations. Then, click the green arrow at the top to run the co-registration process.

**8. Outputs**

All co-registered images (mean and 4D) will be prefixed by **c**. Note: this is not default behavior, but the pre-processing script is modifies an spm flag to make this true.

## matlab

Finally, re-align the VASO and BOLD runs to their respective target mean image. The code used for this section is implemented at the end of the pre-processing script.

# 2 - FIRST-LEVEL ANALYSIS



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
