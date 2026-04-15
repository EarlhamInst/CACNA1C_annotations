#!/bin/bash
#SBATCH -p $1
#SBATCH -t $2
#SBATCH -c $3
#SBATCH --mem=$4
#SBATCH --array=1-3
#SBATCH --job-name=processGTEx
#SBATCH -o $5
#SBATCH -e $6
#SBATCH --mail-type=ALL
#SBATCH --mail-user=$7


# $1: submission queue
# $2: job duration
# $3: number of cpus
# $4: memory
# $5: out file
# $6: error file
# $7: email


####### Script to extract fastq from bam, trim reads, and remap the reads using STAR, and counting reads mapping to exons using DEXSeq





# $8: list of bam files
# $9: path to the trimmed output
# $10: path to the mapped output
# $11: outpath for DESeq

source jre-8u92
source samtools-1.10
source star-2.6.0c
source python-2.7.10
source trim_galore-0.5.0



bamlist=$8
bamfile=$(sed -n ${SLURM_ARRAY_TASK_ID}p ${bamlist})
outname=${bamfile##*/}
echo $outname

### CONVERT BAM TO FASTQ AND STAR ALIGNMENT RUN
outpathtrimmed= $9
outpathSTAR= ${10}
referenceSTAR= ${11}
mkdir "$outpathSTAR${outname%.bam}"

samtools collate -u -O $bamfile | samtools fastq -n -1 $outpathSTAR${outname%.bam}_R1.fastq -2 $outpathSTAR${outname%.bam}_R2.fastq -s $outpathSTAR${outname%.bam}_singletons.fastq  

echo "bam --> fastq conversion done"

trim_galore --paired --retain_unpaired $outpathSTAR${outname%.bam}_R1.fastq $outpathSTAR${outname%.bam}_R2.fastq -o $outpathtrimmed #####

echo "TRIMMING alignment done" 

echo "starting STAR run for ${outname%.bam}"

STAR --runThreadN 12 --genomeDir $referenceSTAR --readFilesIn $outpathSTAR${outname%.bam}_R1_val_1.fq $outpathSTAR${outname%.bam}_R2_val_2.fq --outFileNamePrefix $outpathSTAR${outname%.bam}/${outname%.bam}. --twopassMode Basic --outSAMstrandField intronMotif --outSAMtype BAM SortedByCoordinate

echo "STAR alignment done" 

### DEXSEQ PREPARATION

echo "starting DEXSeq counts"

outpathDEX= ${12}
gfftranscriptome= ${13}

mkdir "$outpathDEX${outname%.bam}"

samtools view $outpathSTAR${outname%.bam}/${outname%.bam}.Aligned.sortedByCoord.out.bam | python dexseq_count.py $gfftranscriptome  $outpathDEX${outname%.bam}/${outname%.bam}_splice_counts.txt

echo "DEXSeq counts done"

# REMOVE FASTQs ONCE FINISHED

rm $outpathSTAR${outname%.bam}_R1.fastq
rm $outpathSTAR${outname%.bam}_R2.fastq
rm $outpathSTAR${outname%.bam}_singletons.fastq
rm $outpathSTAR${outname%.bam}_R1_val_1.fq
rm $outpathSTAR${outname%.bam}_R2_val_2.fq

echo "intermediary fastq files removed successfully"
echo "${outname%.bam} successfully completed"
