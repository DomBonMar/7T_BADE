#!/bin/bash

# retrieved from layer fMRI blog post
# https://layerfmri.com/2018/03/11/quick-layering/

scale=$2

# loads required module
module load AFNI

delta_x=$(3dinfo -di $1)
delta_y=$(3dinfo -dj $1)
delta_z=$(3dinfo -dk $1)
sdelta_x=$(echo "((sqrt($delta_x * $delta_x) / $scale))"|bc -l)
sdelta_y=$(echo "((sqrt($delta_y * $delta_y) / $scale))"|bc -l)
sdelta_z=$(echo "((sqrt($delta_z * $delta_z) / 1))"|bc -l) 
# here I only upscale in 2 dimensions.

3dresample -dxyz $sdelta_x $sdelta_y $sdelta_z -rmode Cu -overwrite -prefix scaled$2_$1 -input $1 
