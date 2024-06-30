## Tutorial for creating a ATAC count seurat object using NCBI SRA files

  
## 1. Download NCBI SRR/SRA files

## 1.1 Get Data List from SRA Run Selector
Located to the GEO site, here using [GSE228660](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE228660) as an example.  
  
At the bottom of the page, navigate to the [SRA Run Selector](https://www.ncbi.nlm.nih.gov/Traces/study/?acc=PRJNA950970&o=acc_s%3Aa). Use the filter options to select the desired samples. In the **Select** box, locate and download both the **Metadata** and **Accessertion List**.  
  
## 1.2 Download fastq files to the Cluster using Accessertion List
Activate the environment with `sra-tools`.  

Use `downloadSRA_head.sh` to download fastq files to Cluster. This process will automatically invoke the `array.sh` srcipts. Make sure that both scripts are located in the same directory before starting the download.  

```
$ conda activate env_with_sratools
$ sbatch downloadSRA_head.sh
```

## 2 Specify the fastq input for cellranger

For `cellranger-atac` installation, follow the instruction in [10x genomics ATAC](https://support.10xgenomics.com/single-cell-atac/software/pipelines/latest/installation) website.  
  
### 2.1 Retrive SRA files from NCBI

Retrive SRA files from NCBI, here using **SRR24036956** as an example. Check the [Metadata](https://trace.ncbi.nlm.nih.gov/Traces/index.html?view=run_browser&display=metadata) to confirm the details of the SRA file.  

Normally an ATAC-seq SRA file includes four fastq files: two index file and two read files.
```
$ ls -lh
```
Here's a sample output:
```
total 23G
-rw-rw-r-- 1 user 2.5G Jun 20 17:08 SRR24036956_1.fastq.gz
-rw-rw-r-- 1 user 7.7G Jun 20 17:08 SRR24036956_2.fastq.gz
-rw-rw-r-- 1 user 4.6G Jun 20 17:08 SRR24036956_3.fastq.gz
-rw-rw-r-- 1 user 7.8G Jun 20 17:08 SRR24036956_4.fastq.gz
```
Normally, two files of similar size are two read files `Read 1` and `Read 2`. The remaining two files would be the index files, the smaller file is  `Index 1` and the larger would be `Index 2`.  

So here:  
SRR24036956_1.fastq.gz is `Index 1`  
SRR24036956_2.fastq.gz is `Read 1`  
SRR24036956_3.fastq.gz is `Index 2`  
SRR24036956_4.fastq.gz is `Read 2`  

### 2.2 Prepare fastq file names for cellranger

The readable fastq file names for `cellranger-atac` are:  

`[Sample Name]_S1_L00[Lane Number]_[Read Type]_001.fastq.gz`  

`[Sample Name]_S1__[Read Type]_001.fastq.gz`  

Where Read Type is one of:

`I1: Sample index read`  
`I2: Sample index read`  
`R1: Read 1`  
`R2: Read 2`  
  
To create the required fastq file names, soft copies are needed:  
```
$ ln -s SRR24036956_1.fastq.gz SRR24036956_S1_I1_001.fastq.gz; ln -s SRR24036956_3.fastq.gz SRR24036956_S1_I2_001.fastq.gz; ln -s SRR24036956_2.fastq.gz SRR24036956_S1_R2_001.fastq.gz; ln -s SRR24036956_4.fastq.gz SRR24036956_S1_R2_001.fastq.gz
```

The output should be:
```
$ ls -lh

total 23G
-rw-rw-r-- 1 user 2.5G Jun 20 17:08 SRR24036956_1.fastq.gz
-rw-rw-r-- 1 user 7.7G Jun 20 17:08 SRR24036956_2.fastq.gz
-rw-rw-r-- 1 user 4.6G Jun 20 17:08 SRR24036956_3.fastq.gz
-rw-rw-r-- 1 user 7.8G Jun 20 17:08 SRR24036956_4.fastq.gz
lrwxrwxrwx 1 user   22 Jun 27 21:59 SRR24036956_S1_I1_001.fastq.gz -> SRR24036956_1.fastq.gz
lrwxrwxrwx 1 user   22 Jun 27 21:59 SRR24036956_S1_I2_001.fastq.gz -> SRR24036956_3.fastq.gz
lrwxrwxrwx 1 user   22 Jun 25 15:43 SRR24036956_S1_R1_001.fastq.gz -> SRR24036956_2.fastq.gz
lrwxrwxrwx 1 user   22 Jun 25 15:43 SRR24036956_S1_R2_001.fastq.gz -> SRR24036956_4.fastq.gz
```

For detailed instructions on preparing SRA data for Cell Ranger, please refer to the 10x Genomics guide:  
[How do I prepare Sequence Read Archive (SRA) data from NCBI for Cell Ranger?](https://kb.10xgenomics.com/hc/en-us/articles/115003802691-How-do-I-prepare-Sequence-Read-Archive-SRA-data-from-NCBI-for-Cell-Ranger).  

## 3 Run cellranger-atac count
```
$ sbatch cellranger_atac.sh
```
Remeber to edit required parameters in the `cellranger_atac.sh` scripts:   

`--id=ID` A unique run ID string (e.g., SRR24036956).  
`--reference=PATH` Path to folder containing a Cell Ranger ATAC reference.  
`--fastqs`	Path of the fastq files.  
`--description=TEXT` Description of the SRA file (e.g., 18mo_Treg_1).  


