######Assembly of reads into contigs
##1. Trim
java -jar /home/amax/software/Trimmomatic-0.39/trimmomatic-0.39.jar PE -threads 48 -phred33 ./sample.R1.fq.gz ./sample.R2.fq.gz ./sample_paired_1.fastq.gz ./sample_unpaired_1.fastq.gz ./sample_paired_2.fastq.gz ./sample_unpaired_2.fastq.gz ILLUMINACLIP:/home/amax/software/Trimmomatic-0.39/adapters/TruSeq3-PE-2.fa:2:30:10:8:true SLIDINGWINDOW:4:20 LEADING:2 TRAILING:2 MINLEN:50 
##2. Assembly
megahit -1 ./sample_paired_1.fastq.gz -2 ./sample_paired_2.fastq.gz --memory 0.9 --num-cpu-threads 32 --out-dir ./sample _megahit_output --min-count 1


####Generation of prokaryotic metagenome-assembled genomes (MAGs)
##1. bin
##1.1 metawrap binning
metawrap binning -o sample_INITIAL_BINNING -t 48 -a samplecontigs.fasta --metabat2 --maxbin2 --concoct sample_1.fastq sample_2.fastq

##1.2 metawrap bin_refinement
metawrap bin_refinement -o sample_BIN_REFINEMENT_50_10 -t 48 -A ./sample_INITIAL_BINNING/metabat2_bins/ -B ./sample_INITIAL_BINNING/maxbin2_bins/ -C ./ sample_INITIAL_BINNING/concoct_bins/ -c 50 -x 10

##2. dRep
All produced bin sets were aggregated and de-replicated at 95% average nucleotide identity (ANI) using dRep v3.2.2
dRep dereplicate ./drep95/ -g ./*.fa -p 15 -d -comp 50 -con 10 -nc 0.30 -pa 0.9 -sa 0.95

##3. GTDB
The taxonomy of each MAG was assigned using GTDB-Tk v1.5.0
gtdbtk classify_wf --genome_dir ./00MAG_50_10/ --out_dir ./ --extension fa --prefix bin --cpus 32

####The maximum-likelihood phylogenetic trees of MAGs
The maximum-likelihood phylogenetic trees of MAGs were constructed based on a concatenated dataset of 400 universally conserved marker proteins using PhyloPhlAn v3.0.64
phylophlan -i ./ 01drep95_prodigal -d /user/db/phylophlan --diversity high -f my_genome_cell.cfg --accurate -o ./drep95-tree --nproc 15 --min_num_markers 80

###The RPKM values of the MAGs were calculated using CoverM v0.6.1
coverm genome --coupled sample_1.fastq.gz sample_2.fastq.gz -d ./dereplicated_genomes -x fa -t 10 --min-read-percent-identity 0.95 --min-read-aligned-percent 0.75 --contig-end-exclusion 0 -m rpkm -o sample_rpkm.txt
