#!/bin/bash

# 20210626WF - copied from /Volumes/Governator/ANTISTATELONG/preprocessWrapper to here for posterity
# 20120210   - final. date based on ls -l timestamp and "date="

#Make sure to run it with & at end so that program doesn't stop when ssh logs me out
#Another option is to use "screen" program (workspace saver) and no &
#Also if want to output to screen and save, do:
# ./preprocessWrapper 2>> <date>_preprocessWrapperStdErr.txt | tee -a <date>_preprocessWrapperStdOut.txt

Usage () { 
	echo "Usage: ./preprocessWrapper 1>> <date>_preprocessWrapperStdOut.txt 2>> <date>_preprocessWrapperStdErr.txt" 
}

Usage

##User defined variables
date="2012_02_10"
rootdir="/Volumes/Governator/ANTISTATELONG"
stepone='0'
steptwo='0'
steptwodelete='0'
stepthree='0'
stepthreedelete='0'
stepfour='0'
stepfourfix='0'
stepfourexceptions='0'
stepfive='0'
stepfivedelete='0'
stepfiveexceptions='1'
stepsix='0'
#Set a breakpoint @ CGErrorBreakpoint() to catch errors as they are logged

#${rootdir}/${subjdir}/${visitdir}/mprage
#${rootdir}/${subjdir}/${visitdir}/run1
#${rootdir}/${subjdir}/${visitdir}/run2
#${rootdir}/${subjdir}/${visitdir}/run3
#${rootdir}/${subjdir}/${visitdir}/run4

#Will stop script if there are any errors - dont use b/c stops script if folder doesnt have script
#set -e
#Will output everything that was run
#set -x

# 1 Determine all filenames
if [ ${stepone} = "1" ]; then
	for subjdir in $( ls ${rootdir} ); do

		if [ -d ${rootdir}/${subjdir} ]; then
	
			#Limit subjdir to just directories that are subjdirs
			#Could also do ^[0-9][0-9][0-9][0-9][0-9]
			if [[ ${subjdir} =~ ^[0-9]{5} ]]; then
		
				for visitdir in $( ls ${rootdir}/${subjdir} ); do
					#set +x			
					if [ -d ${rootdir}/${subjdir}/${visitdir} ]; then
					
						echo "${subjdir}/${visitdir}" >> "${date}"_1_subjdirs.txt
						
						#This part is optional
						for datadir in $( ls ${rootdir}/${subjdir}/${visitdir} ); do
							
							echo -e "\n" "${subjdir}/${visitdir}/${datadir}" >> "${date}"_1_subjdirs.txt
						
						done
					
					fi 
					#set -x
				done
			fi
		fi
	done
fi

#2 Determine who already has processed MPRAGE files and DELETE (if steptwodelete = 1)
if [ ${steptwo} = 1 ]; then
for subjdir in $( ls ${rootdir} ); do

	if [ -d ${rootdir}/${subjdir} ] && [[ ${subjdir} =~ ^[0-9]{5} ]]; then
	
		for visitdir in $( ls ${rootdir}/${subjdir} ); do
		
			if [ -d ${rootdir}/${subjdir}/${visitdir} ] && \
			[[ ! ${subjdir}/${visitdir} == 10278/060330161349 ]] && \
			[[ ! ${subjdir}/${visitdir} == 10480/101023122142 ]] && \
			[[ ! ${subjdir}/${visitdir} == 10472/101012162314 ]]; then
							
				#Get the MPRAGE directory string
				mpragedir=${rootdir}/${subjdir}/${visitdir}/mprage
				
				#Check to see how many DICOM files are in this directory
				mprageDcmCount=$( ls ${mpragedir}/*.dcm | wc -l )
				echo ${mprageDcmCount} ${mpragedir} >> "${date}"_2_mprageDcmCount.txt
				
				#Check to see if any preprocessed MPRAGE files already exist
				mprageProcCount=$( ls ${mpragedir}/*.nii.gz | wc -l )
				mprageProcName=$( ls ${mpragedir}/*.nii.gz )
				echo ${mprageProcCount} ${mprageProcName} >> "${date}"_2_mprageProcCount.txt
				
				#If steptwodelete=1 AND if old preprocessed files exist, delete them
				if [ ${steptwodelete} = 1 ]; then
				
					if [ ${mprageProcCount} -ge "1" ]; then
					echo "Deleted *.nii.gz for ${mpragedir}" >> "${date}"_2_mprageProc_deleted.txt 
					#rm ${mpragedir}/*.nii.gz
					#rm ${mpragedir}/mprage_to_Talairach_2mm_affine.mat
					#rm ${mpragedir}/mprage_to_Talairach_2mm_fnirt_settings.log	
					rm ${mpragedir}/mprage_final_to_MNI_2mm_affine.mat
					rm ${mpragedir}/mprage_final_to_MNI_2mm_fnirt_settings.log
					rm ${mpragedir}/dimon.files.run.*
					rm ${mpragedir}/GERT_Reco_dicom_*
					fi
				fi 
			fi
		done	
	fi
done
fi

#3 Determine who already has processed functional files and DELETE (if stepthreedelete = 1)
if [ ${stepthree} = 1 ]; then
for subjdir in $( ls ${rootdir} ); do
	
	if [ -d ${rootdir}/${subjdir} ] && [[ ${subjdir} =~ ^[0-9]{5} ]]; then
	
		for visitdir in $( ls ${rootdir}/${subjdir}); do
		
			if [ -d ${rootdir}/${subjdir}/${visitdir} ]; then
				
				for funcdir in run1 run2 run3 run4; do
						
					#Check to see how many DICOM files are in this directory
					funcDcmCount=$( ls ${rootdir}/${subjdir}/${visitdir}/${funcdir}/*.dcm | wc -l )
					echo ${funcDcmCount} ${subjdir}/${visitdir}/${funcdir} >> "${date}"_3_funcDcmCount.txt
				
					#Check to see if any preprocessed FUNC files already exist
					funcNiiProcName=$( ls ${rootdir}/${subjdir}/${visitdir}/${funcdir}/*.nii.gz )	
					funcNiiProcCount=$( ls ${rootdir}/${subjdir}/${visitdir}/${funcdir}/*.nii.gz | wc -l )
					funcPngProcName=$( ls ${rootdir}/${subjdir}/${visitdir}/${funcdir}/*.png )
					funcPngProcCount=$( ls ${rootdir}/${subjdir}/${visitdir}/${funcdir}/*.png | wc -l )
					funcParProcName=$( ls ${rootdir}/${subjdir}/${visitdir}/${funcdir}/*.par ) 
					funcParProcCount=$( ls ${rootdir}/${subjdir}/${visitdir}/${funcdir}/*.par | wc -l )
					echo ${funcNiiProcCount} ${funcNiiProcName} >> "${date}"_3_funcProcCount.txt
					echo ${funcPngProcCount} ${funcPngProcName} >> "${date}"_3_funcProcCount.txt
					echo ${funcParProcCount} ${funcParProcName} >> "${date}"_3_funcProcCount.txt
				
					#If stepthreedelete=1 AND if old preprocessed files exist, delete them
					if [ ${stepthreedelete} = 1 ]; then
				
						if [ ${funcNiiProcCount} -ge "1" ]; then
							echo "Deleted *.nii.gz for ${subjdir}/${visitdir}/${funcdir}" >> "${date}"_3_funcProc_deleted.txt
							rm ${subjdir}/${visitdir}/${funcdir}/*.nii.gz
						fi
						
						if [ ${funcPngProcCount} -ge "1" ]; then
							echo "Deleted *.png for ${subjdir}/${visitdir}/${funcdir}" >> "${date}"_3_funcProc_deleted.txt 
							rm ${subjdir}/${visitdir}/${funcdir}/*.png
						fi
						
						if [ ${funcParProcCount} -ge "1" ]; then
							echo "Deleted *.par for ${subjdir}/${visitdir}/${funcdir}" >> "${date}"_3_funcProc_deleted.txt 
							rm ${subjdir}/${visitdir}/${funcdir}/*.par
						fi
					fi 
				done
			fi
		done	
	fi
done
fi

#4 Run preprocessMPRAGE
#This works, but check intensities in fslview if can't see final image
if [ ${stepfour} = 1 ]; then
for subjdir in $( ls ${rootdir} ); do

	if [ -d ${rootdir}/${subjdir} ]; then
		#&& [[ ${subjdir} -gt 10480 ]]  (can be inserted between ] and ; above)
		
		for visitdir in $( ls ${rootdir}/${subjdir} ); do
			echo "${subjdir}/${visitdir}"
			
			if [ -d ${rootdir}/${subjdir}/${visitdir} ] && \
			[[ ! ${subjdir}/${visitdir} == 10278/060330161349 ]] && \
			[[ ! ${subjdir}/${visitdir} == 10480/101023122142 ]] && \
			[[ ! ${subjdir}/${visitdir} == 10472/101012162314 ]]; then
		
				#Change directory to be in that persons mprage dir
				cd ${rootdir}/${subjdir}/${visitdir}/mprage
				
				#This outputs something useless to each persons folder!!FIX NEXT TIME
				echo "changed directory to ${subjdir}/${visitdir}/mprage" >> "${date}_4_preprocessMprage.txt"

				#Jobs is a command that returns one line for each job running.  Works only if & @ end of command below				
				while [ "$( jobs | wc -l )" -ge 4 ]; do
					sleep 5		
				done	
				
				preprocessMprage -b "-R -f 0.5 -v" -d n -o mprage_final.nii.gz -p "*.dcm" -r MNI_2mm &
			fi
		done
	fi
done
fi

if [ ${stepfourfix} = 1 ]; then
	
	#Print contents of this file and feed it as "mpragedir" variable
	for mpragedir in $( cat 2011_06_23_preprocessStructural_NeedToRun ); do
		
		echo "${mpragedir}"

		#Same as above but cd
		#Change directory to be in that persons mprage dir
		cd ${mpragedir}
		
		#This outputs something useless to each persons folder!!FIX NEXT TIME
		echo "changed directory to ${mpragedir}" >> "${date}_4fix_preprocessMprage.txt"
		
		#Jobs is a command that returns one line for each job running.   Works only if & @ end of command below	
		while [ "$( jobs | wc -l )" -ge 4 ]; do
				sleep 5
		done		
		
		preprocessMprage -b "-R -f 0.5 -v" -d n -o mprage_final.nii.gz -p "*.dcm" -r MNI_2mm &
				
	done
fi


if [ ${stepfourexceptions} = 1 ]; then
for subjdir in $( ls ${rootdir} ); do

	if [ -d ${rootdir}/${subjdir} ]; then
		
		for visitdir in $( ls ${rootdir}/${subjdir} ); do
						
			if [ -d ${rootdir}/${subjdir}/${visitdir} ] && \
			[[ ${subjdir}/${visitdir} == 10816/111109163617 ]] || \
			[[ ${subjdir}/${visitdir} == 10699/111217121758 ]] || \
			[[ ${subjdir}/${visitdir} == 10279/111217135911 ]] || \
			[[ ${subjdir}/${visitdir} == 10134/111217152311 ]] || \
			[[ ${subjdir}/${visitdir} == 10241/111220144044 ]] || \
			[[ ${subjdir}/${visitdir} == 10185/120104092116 ]]; then
			#[[ ${subjdir}/${visitdir} == 10278/060330161349 ]] || \
			#[[ ${subjdir}/${visitdir} == 10480/101023122142 ]] || \
			#[[ ${subjdir}/${visitdir} == 10472/101012162314 ]]; then
	
				#Change directory to be in that persons mprage dir
				cd ${rootdir}/${subjdir}/${visitdir}/mprage
				echo "${subjdir}/${visitdir}/mprage"
					
				#This outputs something useless to each persons folder!!FIX NEXT TIME
				echo "changed directory to ${subjdir}/${visitdir}/mprage" >> "${date}_4addon_preprocessMprage.txt"

				#Jobs is a command that returns one line for each job running.  Works only if & @ end of command below				
				while [ "$( jobs | wc -l )" -ge 4 ]; do
					sleep 5		
				done	
				
				#preprocessMprage -b "-R -f 0.5 -v" -d n -o mprage_final.nii.gz -r MNI_2mm -n mprage.nii.gz &
				preprocessMprage -b "-R -f 0.5 -v" -d n -o mprage_final.nii.gz -p "*.dcm" -r MNI_2mm &
			fi
		done
	fi
done
fi


#5 Run preprocessfunctional
if [ ${stepfive} = 1 ]; then
for subjdir in $( ls ${rootdir} ); do
	
	if [ -d ${rootdir}/${subjdir} ] && [[ ${subjdir} =~ ^[0-9]{5} ]]; then
		
		for visitdir in $( ls ${rootdir}/${subjdir} ); do
		
			if [ -d ${rootdir}/${subjdir}/${visitdir} ] && \
			[[ ! ${subjdir}/${visitdir} == 10278/060330161349 ]] && \
			[[ ! ${subjdir}/${visitdir} == 10480/101023122142 ]] && \
			[[ ! ${subjdir}/${visitdir} == 10472/101012162314 ]]; then
	
				for datadir in $( ls ${rootdir}/${subjdir}/${visitdir} ); do
								
					if [ -d ${rootdir}/${subjdir}/${visitdir}/${datadir} ] && [[ ${datadir} =~ run[1-4] ]]; then
								
						#Change directory to be in that person's run dir
						cd ${rootdir}/${subjdir}/${visitdir}/${datadir}
						echo "preprocessing ${rootdir}/${subjdir}/${visitdir}/${datadir}"
						echo "preprocessing ${rootdir}/${subjdir}/${visitdir}/${datadir}" >> "${rootdir}/${date}_5_preprocessFunctional.txt"				
						
						while [ "$( jobs | wc -l )" -ge 12 ]; do
							sleep 13
						done
						preprocessFunctional -delete_dicom no -dicom "*.dcm" -mprage_bet ../mprage/mprage_bet.nii.gz -rescaling_method 100_voxelmean -slice_acquisition interleaved -tr 1.5 -warpcoef ../mprage/mprage_warpcoef.nii.gz >> "NOTE_Preprocessing_${datadir}_${date}.txt" &		
						#preprocessFunctional -4d functional.nii.gz -mprage_bet ../mprage/mprage_bet.nii.gz -rescaling_method 100_voxelmean -slice_acquisition interleaved -tr 1.5 -warpcoef ../mprage/mprage_warpcoef.nii.gz >> "NOTE_Preprocessing_${datadir}_${date}.txt" &	
					fi
				done			
			fi
		done
	fi
done
fi

#Delete all preprocessed files (only if you ran it and didn't mean to)
if [ ${stepfivedelete} = 1 ]; then
for subjdir in $( ls ${rootdir} ); do
	
	if [ -d ${rootdir}/${subjdir} ]; then
		
		for visitdir in $( ls ${rootdir}/${subjdir} ); do
			
			if [ -d ${rootdir}/${subjdir}/${visitdir} ] && \
			[[ ! ${subjdir}/${visitdir} == 10278/060330161349 ]] && \
			[[ ! ${subjdir}/${visitdir} == 10480/101023122142 ]] && \
			[[ ! ${subjdir}/${visitdir} == 10472/101012162314 ]]; then
				
				for datadir in $( ls ${rootdir}/${subjdir}/${visitdir} ); do
				
					if [ -d ${rootdir}/${subjdir}/${visitdir}/${datadir} ] && [[ ${datadir} =~ run[1-4] ]]; then
						
						cd ${rootdir}/${subjdir}/${visitdir}/${datadir}
						echo "${rootdir}/${subjdir}/${visitdir}/${datadir}"
						rm functional.nii.gz
						rm *.png
						rm *.nii.gz
						rm *.mat
						rm *.par
						rm .*complete #note: .complete are hidden files you can see via ls -a
					
					else
					
						echo "did not delete in ${rootdir}/${subjdir}/${visitdir}/${datadir}"
					
					fi
				done
			fi
							
		done
	fi
done
fi

if [ ${stepfiveexceptions} = 1 ]; then
for subjdir in $( ls ${rootdir} ); do

	if [ -d ${rootdir}/${subjdir} ]; then
	
		for visitdir in $( ls ${rootdir}/${subjdir} ); do
		
			#This is the same as the other way I scripted with David
			#(${subjdir}/${visitdir} == 10278/060330161349 || \
			# ${subjdir}/${visitdir} == 10480/101023122142 || \
 			# ${subjdir}/${visitdir} == 10472/101012162314) 
 			#[[ ${subjdir}/${visitdir} == 10343/081202160138 ]]; then
 			##
 			#[[ ${subjdir}/${visitdir} == 10134/111217152311 ]] || \
 			#[[ ${subjdir}/${visitdir} == 10185/120104092116 ]] || \
 			#[[ ${subjdir}/${visitdir} == 10241/111220144044 ]]
			if [ -d ${rootdir}/${subjdir}/${visitdir} ] && \
			[[ ${subjdir}/${visitdir} == 10816/111109163617 ]] || \
			[[ ${subjdir}/${visitdir} == 10699/111217121758 ]] || \
			[[ ${subjdir}/${visitdir} == 10279/111217135911 ]]; then

				for datadir in $( ls ${rootdir}/${subjdir}/${visitdir} ); do
					
					if [ -d ${subjdir}/${visitdir}/${datadir} ] &&\
					[[ ${datadir} =~ run[1-4] ]]; then
					
						echo "preprocessing ${rootdir}/${subjdir}/${visitdir}/${datadir}"
						cd ${rootdir}/${subjdir}/${visitdir}/${datadir}
						echo "preprocessing ${rootdir}/${subjdir}/${visitdir}/${datadir}" >> "${rootdir}/${date}_5_preprocessFunctional.txt"		
						
						while [ "$( jobs | wc -l )" -ge 2 ]; do
							sleep 3
						done
								
						#preprocessFunctional -4d functional.nii.gz -mprage_bet ../mprage/mprage_bet.nii.gz -rescaling_method 100_voxelmean -slice_acquisition interleaved -tr 1.5 -warpcoef ../mprage/mprage_warpcoef.nii.gz >> "NOTE_Preprocessing_${datadir}_${date}.txt" &	
						 
						preprocessFunctional -delete_dicom no -dicom "*.dcm" -mprage_bet ../mprage/mprage_bet.nii.gz -rescaling_method 100_voxelmean -slice_acquisition interleaved -tr 1.5 -warpcoef ../mprage/mprage_warpcoef.nii.gz >> "NOTE_Preprocessing_${datadir}_${date}.txt" 	
					
						cd ${rootdir}
					fi
				done	
			fi
		done	
	fi
done	
fi

##Stepsix
#if [ ${stepsixdelete} = 1]; then
##SEE MotionOutliers/createCensor
##BEFORE DOING THIS, FIGURE OUT ALL THE RULE OUTS
##see ring_prep_deconvolve_4 in governator/Miya/ring_rew_old
#mcplot.par has motion data in an array form - note: brik=array
#instead of determining movement according to voxels moved, he did:
#if velocity > 0.8 voxels/TR, then censor it (threshold it)
#This creates a censor file that has a 1 or 0 for each TR.  Makes 0 if don't want to use
#fi
