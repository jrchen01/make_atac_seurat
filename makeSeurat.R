#!/usr/bin/env Rscript
##SBATCH --mem 90G
#
library(Seurat)
library(dplyr)
library(stringr)
library(data.table)
library(tidyr)
library(tidyverse)
library(Signac)


fragments = fread('fragments_inputs.txt', col.names = c('1'))[[1]]
names(fragments )= fragments %>% gsub('/outs/fragments.tsv.gz','',.)%>% str_split('/') %>% 
    sapply(tail,1)
fragments[1:5]

cell_types = list.files(pattern = '_celltypes_atac.tsv')
names(cell_types) = cell_types %>% gsub('_celltypes_atac.tsv','',.)
cell_types = cell_types %>% lapply(fread) %>% bind_rows(.id = 'compartment') 
cell_types$sample = cell_types$Cell %>% str_split('#') %>% sapply(head,1)
cell_types %>% head



sample_m = read.csv('sample_meta.txt', header = FALSE, sep = "\t")  %>% 
    dplyr::rename('Sample Name' = 1, meta = 2) %>%
    dplyr::mutate(`Sample Name` = `Sample Name` %>% gsub(' ','',.)) %>%
    dplyr::filter(meta %like% 'scATACseq') %>% 
    dplyr::mutate(sample = meta %>% str_split(',') %>% sapply(head,1),
                 new_sample = case_when(
                                       meta %like% 'Replicate1' ~ paste0(sample, '-D-R1'),
                                        meta %like% 'Replicate2' ~ paste0(sample, '-D-R2'),
                                        meta %like% 'S2' ~ paste0(sample, '-S2'), 
                                         meta %like% 'A002-C-202' ~ 'A002-C-202-D-OCT',
                     
                                        TRUE ~ paste0(sample, '-D')
                                       ))

inputs = fread('h5_inputs.txt', col.names = 'i')[[1]]

seurats = c()
for (i in inputs){

   sample_name = i %>% gsub('/outs/filtered_peak_bc_matrix.h5','',.) %>% 
        str_split('/') %>% sapply(tail,1)

    ###### get the paired fragment file path
    fragment = fragments[[sample_name]]

    ##### ignore
    meta = fread('META.csv') %>% 
        dplyr::filter(Run == sample_name) %>% 
        dplyr::select(source_name,tissue,disease_state,disease_stage, `Sample Name`,sex)

    compartment = meta$tissue
    sample_name = meta[['Sample Name']]
    sample_meta = sample_m %>% 
        dplyr::filter(`Sample Name`== sample_name) 

    if (dim(sample_meta)[[1]] > 0){

        ##### read h5 file ; output is a matrix 
        seurat = Read10X_h5(i)
        new_barcodes = paste0(sample_meta$new_sample, '#',colnames(seurat))

        # ggvenn::ggvenn(list('new_barcode' = new_barcodes,
        #                 'all_available_annotated_barcodes' = cell_types$Cell))
        ##### create signac object chromatinassay
        chrom_assay <- CreateChromatinAssay(
            counts = seurat,
            sep = c(":", "-"),
            fragments = fragment,
            min.cells = 10,
            min.features = 200
            )
        
        ###### ignore ; might have to make your own meta.table ;
        ###### meta_cells is a dataframe where rownames are barcodes and columns are relevant meta labels i.e. sample, condition, etc. 
       meta_cells = cell_types %>% dplyr::filter(Cell %in% new_barcodes) %>% 
            dplyr::mutate(barcode = Cell %>% str_split('#') %>% sapply(tail,1) ) %>%
            dplyr::mutate(tissue = meta$tissue, 
                                disease_state = meta$disease_state, 
                                sex = meta$sex) %>% column_to_rownames('barcode')

        if (dim(meta_cells)[[1]]>0){

        
            ### create seurat object
            seurat = CreateSeuratObject(chrom_assay, assay = 'ATAC', meta.data = meta_cells, project = i)
            seurat$barcode = seurat@meta.data %>% row.names

            #### skip 
            seurat = subset(seurat, subset = barcode %in% row.names(meta_cells))
            RenameCells(seurat, add.cell.id = sample_meta$new_sample)
            seurats[[sample_name]] = seurat
        }

    }else{
        print('no valid barcodes')
    }
}

    
index = which(seurats %>% lapply(function(x) (x %>% class) == 'Seurat') == TRUE)
seurats = seurats[index]
seurats %>% saveRDS('00LIST_raw_polyps_colorectalcancer_human.rds')
seurats = readRDS('00LIST_raw_polyps_colorectalcancer_human.rds')
print('saved list')
seurat = merge(seurats[[1]], seurats[2:length(seurats)])
seurat %>% saveRDS('raw_polyps_colorectalcancer_human.rds')
print('saved merged object')