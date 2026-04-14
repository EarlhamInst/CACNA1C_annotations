#!/bin/bash
#SBATCH -p $1
#SBATCH -N $2
#SBATCH -c $3
#SBATCH --mem $4
#SBATCH -t $5
#SBATCH -J calclen_FA
#SBATCH --mail-user= $6
#SBATCH -o $7 
#SBATCH -e $8 
#SBATCH --mail-type=ALL
#SBATCH --array=1-18   # adjust to number of files


### script written to collect read lengths from fasta files

# $1: submission queue
# $2: number of nodes
# $3: number of cpus
# $4: memory
# $5: job duration
# $6: email
# $7: outfile
# $8: error file
# $9: file list
# $10: output directory



# Inputs
FA_filelist=$9
output_dir=$10

mkdir -p "$output_dir"

# Get FASTA file for this task
FA=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "$FA_filelist")

if [ ! -f "$FA" ]; then
    echo "File $FA not found, skipping"
    exit 1
fi

# Sample name = filename without path or extension
SAMPLE=$(basename "$FA")
SAMPLE=${SAMPLE%.fasta}
SAMPLE=${SAMPLE%.fa}

# Output file (one per input FASTA)
OUTFILE="${output_dir}/${SAMPLE}_read_lengths.tsv"
> "$OUTFILE"

awk -v sample="$SAMPLE" '
    BEGIN {
        seqlen = 0
        readID = ""
    }

    /^>/ {
        if (seqlen > 0 && readID != "") {
            print sample "\t" readID "\t" seqlen
        }

        readID = substr($0, 2)
        sub(/ .*/, "", readID)

        seqlen = 0
        next
    }

    {
        seqlen += length($0)
    }

    END {
        if (seqlen > 0 && readID != "") {
            print sample "\t" readID "\t" seqlen
        }
    }
' "$FA" > "$OUTFILE"

echo "Processed $FA to $OUTFILE"
