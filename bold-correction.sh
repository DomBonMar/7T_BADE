#!/bin/bash

# script by Domenico
# based on BOCO.sh from layer fmri blog post

# inputs
# $1 -> BOLD realigned filename
# $2 -> VASO realigned filename
# $3 -> TR in seconds
# $4 -> number of trials per run

tr=$3
# nTrials=$4

#3dcalc -a Nulled_Basis_b.nii'[1..$(2)]' -expr 'a' -prefix Nulled.nii -overwrite
#3dcalc -a Not_Nulled_Basis_a.nii'[0..$(2)]' -expr 'a' -prefix BOLD.nii -overwrite

# loads required module
module load AFNI

# moves to directory with scans
cd $funcdir

# rename input files
bold=$1 #bold scan
vaso=$2

# upsampling runs
echo "Upsampling runs"
3dUpsample -overwrite  -datum short -prefix VASO_up.nii -n 2 -input $vaso
3dUpsample -overwrite  -datum short -prefix BOLD_up.nii -n 2 -input $bold
NumVol=`3dinfo -nv BOLD_up.nii`
3dTcat -overwrite -prefix VASO_up.nii VASO_up.nii'[0]' VASO_up.nii'[0..'`expr $NumVol - 2`']' 

# bold correction step
# ASK ABOUT TRIAL BOCO
echo "BOLD correction happens now"
LN_BOCO -Nulled VASO_up.nii -BOLD BOLD_up.nii # -trialBOCO $nTrials

# correcting TR (also ask about this part)
echo "Correcting for the proper TR in the header"
3drefit -TR $(echo "$tr / 2" | bc -l) BOLD_up.nii
3drefit -TR $(echo "$tr / 2" | bc -l) VASO_LN.nii

# deleting temp files
mv VASO_LN.nii  "c$2"
rm BOLD.nii
rm VASO_up.nii
rm BOLD_up.nii


#echo "calculating T1 in EPI space"
#3NumVol=`3dinfo -nv Nulled_Basis_b.nii`
#3dcalc -a Nulled_Basis_b.nii'[3..'`expr $NumVol - 2`']' -b  Not_Nulled_Basis_a.nii'[3..'`expr $NumVol - 2`']' -expr 'a+b' -prefix combined.nii -overwrite
#3dTstat -cvarinv -prefix T1_weighted.nii -overwrite combined.nii 
#rm combined.nii

#echo "calculating Mean and tSNR maps"
#3dTstat -mean -prefix mean_nulled.nii Nulled.nii -overwrite
#3dTstat -mean -prefix mean_notnulled.nii BOLD.nii -overwrite
#  3dTstat  -overwrite -mean  -prefix BOLD.Mean.nii \
#     BOLD_intemp.nii'[1..$]'
#  3dTstat  -overwrite -cvarinv  -prefix BOLD.tSNR.nii \
#     BOLD_intemp.nii'[1..$]'
#  3dTstat  -overwrite -mean  -prefix VASO.Mean.nii \
#     VASO_LN.nii'[1..$]'
#  3dTstat  -overwrite -cvarinv  -prefix VASO.tSNR.nii \
#     VASO_LN.nii'[1..$]'

#echo "curtosis and skew"
#LN_SKEW -timeseries BOLD.nii
#LN_SKEW -timeseries VASO_LN.nii
