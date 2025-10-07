######Assembly of reads into contigs

##1. Trim
java -jar /home/amax/software/Trimmomatic-0.39/trimmomatic-0.39.jar PE -threads 48 -phred33 ./sample.R1.fq.gz ./sample.R2.fq.gz ./sample_paired_1.fastq.gz ./sample_unpaired_1.fastq.gz ./sample_paired_2.fastq.gz ./sample_unpaired_2.fastq.gz ILLUMINACLIP:/home/amax/software/Trimmomatic-0.39/adapters/TruSeq3-PE-2.fa:2:30:10:8:true SLIDINGWINDOW:4:20 LEADING:2 TRAILING:2 MINLEN:50 

##2. Assembly
megahit -1 ./sample_paired_1.fastq.gz -2 ./sample_paired_2.fastq.gz --memory 0.9 --num-cpu-threads 32 --out-dir ./sample _megahit_output --min-count 1



####Recovery and annotation of metagenome-assembled genomes (MAGs)

##1. bin
##1.1 metawrap binning
metawrap binning -o ./INITIAL_BINNING -t 20 -a ./sample.contigs.fa --metabat2 --maxbin2 --concoct --universal ./sample_1.fastq ./sample_2.fastq
##1.2 metawrap bin_refinement
metawrap bin_refinement -o ./REFINED_BINS -A ./INITIAL_BINNING/metabat2_bins -B ./INITIAL_BINNING/maxbin2_bins -C ./INITIAL_BINNING/concoct_bins -c 50 -x 10 -t 32 -m 64

##2. dRep
dRep dereplicate non_redundant -g ./*.fa -comp 50 -con 10 -nc 0.30 -pa 0.9 -sa 0.95 -p 64 --genomeInfo genome_info_2.csv

##3. GTDB
gtdbtk classify_wf --genome_dir ./non_redundant/dereplicated_genomes --out_dir ./taxonomy_gtdb --extension fa --cpus 64 

##4. The maximum-likelihood phylogenetic trees of MAGs
phylophlan_write_config_file -o phylo.cfg -d a --db_aa diamond --map_aa diamond --msa mafft --trim trimal --tree1 iqtree --tree2 raxml --verbose
phylophlan -i ./phylo/input_dir -d phylophlan -f ./phylo/phylo.cfg --diversity high --min_num_markers 80 --accurate --nproc 128 -o ./phylo/output_dir --verbose 

##5. The RPKM values of the MAGs 
coverm genome --coupled ./sample_1.fastq ./sample_2.fastq --genome-fasta-files ./dereplicated_genomes/*.fa --min-read-percent-identity 0.95 --min-read-aligned-percent 0.75 --contig-end-exclusion 0 -m rpkm -o ./sample_rpkm --threads 64

