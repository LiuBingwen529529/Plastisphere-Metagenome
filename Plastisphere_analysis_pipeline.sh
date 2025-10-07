######Assembly of reads into contigs
##1. Trim
for seq in $(cat /home/amax/plastisphere/DNA/Clean_data/seq.txt); do
mkdir /home/amax/plastisphere/DNA/Clean_data/$seq
java -jar /home/amax/software/Trimmomatic-0.39/trimmomatic-0.39.jar PE -threads 48 -phred33 /home/amax/plastisphere/DNA/Raw_data/$seq/${seq}.R1.fq.gz /home/amax/plastisphere/DNA/Raw_data/$seq/${seq}.R2.fq.gz /home/amax/plastisphere/DNA/Clean_data/$seq/${seq}_paired_1.fastq.gz /home/amax/plastisphere/DNA/Clean_data/$seq/${seq}_unpaired_1.fastq.gz /home/amax/plastisphere/DNA/Clean_data/$seq/${seq}_paired_2.fastq.gz /home/amax/plastisphere/DNA/Clean_data/$seq/${seq}_unpaired_2.fastq.gz ILLUMINACLIP:/home/amax/software/Trimmomatic-0.39/adapters/TruSeq3-PE-2.fa:2:30:10:8:true SLIDINGWINDOW:4:20 LEADING:2 TRAILING:2 MINLEN:50 
done
##2. Assembly
for seq in $(cat /home/amax/plastisphere/DNA/Contigs/seq.txt); do
megahit -1 /home/amax/plastisphere/DNA/Clean_data/$seq/${seq}_paired_1.fastq.gz -2 /home/amax/plastisphere/DNA/Clean_data/$seq/${seq}_paired_2.fastq.gz --memory 0.9 --num-cpu-threads 32 --out-dir /home/amax/plastisphere/DNA/Contigs/$seq --min-count 1
done 
