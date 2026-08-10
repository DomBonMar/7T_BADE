import numpy as np
import nibabel as nib

# metadata
SUB = "pilot03"
RUN = "pilot03-vaso-run1.nii" # received as input
REGIONS = ['VC','ACC','HC','FC']

# directories
BASEDIR = '/data/lavlab/layer-7t-predictive-coding/'
DATADIR = f"{BASEDIR}data/{SUB}/nifti/"
FUNCDIR = f'{DATADIR}func/'
ANATDIR = f'{DATADIR}anat/'

def nii_to_np(filename):
    img = nib.load(filename) # loads mask
    print(f"Image has size {img.shape}")
    return img.get_fdata() # converts to np

# loads main img
anatf = f"{ANATDIR}{SUB}-t1w.nii"
anatimg = nii_to_np(anatf)
funcf = f"{FUNCDIR}{RUN}"
funcimg = nii_to_np(funcf)

full_mask = anatimg * 0

# generates list of ROI masks to merge
for reg in REGIONS:
    mfile = f"{ANATDIR}mask-{reg}_layers-{RUN}"
    mask = nii_to_np(mfile)
    full_mask = np.add(full_mask, mask)

# saving merged mask
OUTFILE = f"{ANATDIR}ROI-mask-{RUN}"
new_img = nib.Nifti1Image(full_mask, np.eye(4))
nib.save(new_img,OUTFILE)

# center the output mask pls!!!