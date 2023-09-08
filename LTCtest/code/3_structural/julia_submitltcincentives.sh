### julia_submit.sh START ###
#!/bin/bash
#$ -cwd
# error = Merged with joblog
#$ -o joblog.$JOB_ID
#$ -j y
# Edit the line below to request the appropriate runtime and memory
# (or to add any other resource) as needed:
#$ -l h_rt=24:00:00,h_data=1G
# Add multiple cores/nodes as needed:
#$ -pe shared 1
# Email address to notify
#$ -M $USER@mail
# Notify when
#$ -m bea

# echo job info on joblog:
echo "Job $JOB_ID started on:   " `hostname -s`
echo "Job $JOB_ID started on:   " `date `
echo " "

# load the job environment:
. /u/local/Modules/default/init/modules.sh
module load matlab
module li
echo " "
export MCR_CACHE_ROOT=$TMPDIR
echo "MCR_CACHE_ROOT=$MCR_CACHE_ROOT"
echo " "

# substitute the command to run your code below:
echo "matlab -nodisplay -nosplash -r masterservertemp_00 >> output.$JOB_ID"
matlab -nodisplay -nosplash -r masterservertemp_00 >> output.$JOB_ID

# echo job info on joblog:
echo "Job $JOB_ID ended on:   " `hostname -s`
echo "Job $JOB_ID ended on:   " `date `
echo " "
#### submit_matlab.sh STOP ####
