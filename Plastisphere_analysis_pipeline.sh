######Assembly of reads into contigs

##1. Trim
java -jar /home/amax/software/Trimmomatic-0.39/trimmomatic-0.39.jar PE -threads 48 -phred33 ./sample.R1.fq.gz ./sample.R2.fq.gz ./sample_paired_1.fastq.gz ./sample_unpaired_1.fastq.gz ./sample_paired_2.fastq.gz ./sample_unpaired_2.fastq.gz ILLUMINACLIP:/home/amax/software/Trimmomatic-0.39/adapters/TruSeq3-PE-2.fa:2:30:10:8:true SLIDINGWINDOW:4:20 LEADING:2 TRAILING:2 MINLEN:50 

##2. Assembly
megahit -1 ./sample_paired_1.fastq.gz -2 ./sample_paired_2.fastq.gz --memory 0.9 --num-cpu-threads 32 --out-dir ./sample _megahit_output --min-count 1



####Generation of prokaryotic metagenome-assembled genomes (MAGs)

##1. bin
##1.1 metawrap binning
metawrap binning -o ./INITIAL_BINNING -t 20 -a ./sample.contigs.fa --metabat2 --maxbin2 --concoct --universal ./sample_1.fastq ./sample_2.fastq
##1.2 metawrap bin_refinement
metawrap bin_refinement -o ./REFINED_BINS -A ./INITIAL_BINNING/metabat2_bins -B ./INITIAL_BINNING/maxbin2_bins -C ./INITIAL_BINNING/concoct_bins -c 50 -x 10 -t 32 -m 64

##2. dRep
dRep dereplicate non_redundant -g ./*.fa -comp 50 -con 10 -nc 0.30 -pa 0.9 -sa 0.95 -p 64 --genomeInfo genome_info_2.csv

##3. GTDB
gtdbtk classify_wf --genome_dir ./00MAG_50_10/ --out_dir ./ --extension fa --prefix bin --cpus 32

####The maximum-likelihood phylogenetic trees of MAGs
The maximum-likelihood phylogenetic trees of MAGs were constructed based on a concatenated dataset of 400 universally conserved marker proteins using PhyloPhlAn v3.0.64
phylophlan -i ./ 01drep95_prodigal -d /user/db/phylophlan --diversity high -f my_genome_cell.cfg --accurate -o ./drep95-tree --nproc 15 --min_num_markers 80

###The RPKM values of the MAGs were calculated using CoverM v0.6.1
coverm genome --coupled sample_1.fastq.gz sample_2.fastq.gz -d ./dereplicated_genomes -x fa -t 10 --min-read-percent-identity 0.95 --min-read-aligned-percent 0.75 --contig-end-exclusion 0 -m rpkm -o sample_rpkm.txt
