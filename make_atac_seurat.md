## Tutorial for creating a ATAC count seurat object using NCBI SRA files

  
## 1. Download NCBI SRR/SRA files

## 1.1 Get Data List from SRA Run Selector
Located to the GEO site, here using [GSE228660](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE228660) as an example.  
  
At the bottom of the page, navigate to the [SRA Run Selector](https://www.ncbi.nlm.nih.gov/Traces/study/?acc=PRJNA950970&o=acc_s%3Aa). Use the filter options to select the desired samples. In the **Select** box, locate and download both the **Metadata** and **Accessertion List**.  
  
## 1.2 Download fastq files in Cluster using Accessertion List
Activate a environment with `sra-tools`.  

Use `downloadSRA_head.sh` to download fastq files to Cluster. This process will automatically invoke the `array.sh` srcipts. Make sure that both scripts are located in the same directory before starting the download.  

```
$ conda activate env_with_sratools
$ sbatch downloadSRA_head.sh
```

## 2. Run cellranger-atac for each fastq file

For `cellranger-atac` installation, follow the instruction in [10x genomics ATAC](https://support.10xgenomics.com/single-cell-atac/software/pipelines/latest/installation) website.

