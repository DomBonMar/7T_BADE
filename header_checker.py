import nibabel as nib

# Load the image (handles .nii.gz automatically)
filename = "/data/lepage/LAM/data/raw/nifti/8048/Scan2/8048_2_DWI_b1000_64dirs_AP_TRACEW_27.nii.gz"
img = nib.load(filename)

# Access the header
header = img.header

# Print specific fields (e.g., image dimensions, voxel size)
print(header.get_data_shape())
print(header.get_zooms())
print(header)