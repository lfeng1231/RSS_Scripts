docker images |grep indel

docker run -u $UID -it -v /isilon:/isilon -v /remote:/remote -v `pwd`:`pwd` -w `pwd` 7089327318c1 bash

#indel_caller.py -a 0.09 -d <samtools deduped file> -r <reference human genome> -b <panel bed file> -s <sample name> -f <indel freq file> -w <whitelist file> -l <plasma vol in ml> -e <extracted DNA ng amount> -o <vcf output file> -m <annotated whitelist file (vcf)>

indel_caller.py -a 0.09 -d LODsample15.sorted.posdeduped.bam -r /isilon/Analysis/onco/indexes/hg38/hg38.fa -b /isilon/Analysis/onco/indexes/hg38/RUO_P2B_capture_targets.bed -s sample15 -f LODsample15.sorted.posdeduped.bam.indel.freq -w TPV_whitelist.txt -l 4 -e 50 -o sample15_vcf.txt -m sample15_whitelist.txt
