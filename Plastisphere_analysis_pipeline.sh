######Assembly of reads into contigs
##1. Trim
The metagenomic raw reads were examined using FastQC v0.11.9 (http://www.bioinformatics.babraham.ac.uk/projects/fastqc/), low-quality sequences, primers, and adaptors were trimmed using the Trimmomatic v0.39.
java -jar trimmomatic-0.39.jar PE -threads 8 ./sample_1.fastq.gz ./sample_2.fastq.gz ./sample_1.qc.fq.gz ./sample_unpair_1.qc.fq.gz ./sample_2.qc.fq.gz ./sample_unpair_2.qc.fq.gz ILLUMINACLIP:TruSeq3-PE-2.fa:2:30:10 LEADING:2 TRAILING:2 SLIDINGWINDOW:4:20 MINLEN:50
