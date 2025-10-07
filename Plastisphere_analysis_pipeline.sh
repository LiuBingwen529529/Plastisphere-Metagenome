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

##6. Prodigal
prodigal -i MAG.fa -p meta -o ./MAG_genes.gff" -a ./MAG_proteins.faa -d ./MAG_orf.fna

##7. ARG
deeparg predict --model LS --type prot --model-version v2 -i ./MAG_proteins.faa -o MAG_deeparg -d DEEPARG_DB --min-prob 0.8 --arg-alignment-identity 50 --arg-alignment-evalue 1e-10 

##8. VFG
blastp -query ./MAG_proteins.faa -db ./VFDB_setA/VFDB_setA -out ./VFG_result -evalue 1e-5 -outfmt "6 qseqid sseqid pident qcovs evalue bitscore qstart qend sstart send" -num_threads 32 -max_target_seqs 1 -qcov_hsp_perc 70
awk '$3 >= 80 && $4 >= 70' ./VFG_result > ./VFG_filtered_result

##9. MGE
blastn -query ./MAG_orf.fna -db ./MGE/MGE_db_nucl -out ./MGE_result -evalue 1e-10 -outfmt "6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore qcovs" -num_threads 64 
awk '$3 >= 80' ./MGE_result > ./MGE_filtered_result

##10. HGT
MetaCHIP PI -g group.txt -t 64 -i ./dereplicated_genomes -x fa -p Plastisphere
MetaCHIP BP -p Plastisphere -g group.txt -t 128 -pfr

##11. Defense System
defense-finder run ./MAG_proteins.faa -o ./Defensefinder


####Identification and annotation of viral contigs

##1. Identification
##1.1 DeepVirFinder
python ./DeepVirFinder/dvf.py -i ./sample.contigs.fa -l 10000 -c 4 -o ./DeepVirusFinder/
##1.2 tRNA
virsorter run --seqfile ./sample.contigs.fa --min-length 10000 --min-score 0.5 --exclude-lt2gene -j 24 -w ./VirSorter/sample
##1.3 CheckV
diamond makedb --in checkv_reps.faa --db checkv_reps.dmnd --threads 32
checkv end_to_end viral_genomes.fasta checkv -t 32

##2. Taxonomic classification
genomad end-to-end --cleanup ./vOTUs/clusterRes_rep_seq.fasta ./Virus/taxonomy ./db/genomad_db

##3. AMG


####Prediction of virus-host linkages

##1. CRISPER
java -cp ./software/CRT1.2-CLI.jar crt ./MAG.fa CRT_output
blastn –query ./extracted_spacer/all_spacers_corrected.fasta -db ./vOTUs_db -outfmt “6 qseqid sseqid pident length mismatch” -perc_identity 95 > blast_results.tsv

##2. tRNA
tRNAscan-SE -Q -B -o ./tRNA_prediction/vOTUs_tRNAs.txt -f ./tRNA_prediction/vOTUs_tRNAs.fasta ./vOTUs/clusterRes_rep_seq.fasta
blastn -query ./tRNA_prediction/extract_tRNAs.fasta -db ./MAGs_db/MAGs_db -outfmt "6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore qlen slen" -perc_identity 100 -num_threads 16 -out ./tRNA_prediction/blast_results_2.tsv
awk '($3 == 100) && ($4 == $13)' blast_results_2.tsv > filtered_results.tsv 

##3. Homology
blastn -query ./vOTUs/clusterRes_rep_seq.fasta -db ./MAGs_db/MAGs_db -outfmt "6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore" -evalue 1e-10 -perc_identity 95 -word_size 28 -num_threads 48 -out ./homology/blast_results.tsv
awk '$12 >= 50 && $3 >= 95 && $4 >= 2500' blast_results.tsv > filtered_hits.tsv








