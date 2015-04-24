# Manipulating the 1000 genomes imputed ALSPAC data

The ALSPAC data comprises about 18000 individuals (mothers and children) with around 40 million imputed SNPs. The two main formats in which these data are stored are in best guess binary plink (`.bed`, `.bim`, `.fam` files) and gen format dosage files (`.gz` and `.sample`)


## Best guess data

These files are located at:

	/panfs/panasas01/shared/alspac/studies/latest/alspac/genetic/variants/arrays/gwas/imputed/1000genomes/released/27Feb2015/data/genotypes/bestguess/

They are broken up into chromosomes, so 23 sets of binary plink files. If you have a list of SNPs and a list of individuals that you want to extract from across these files then you can use the `extract_plink.sh` script. For information on how to run type

	./extract_plink.sh --help

For example, to extract a subset of SNPs and individuals and merge the results into a single file set (`test.bed`, `test.bim`, `test.fam`) run the following:

	./extract_plink.sh \
		--rootname /panfs/panasas01/shared/alspac/studies/latest/alspac/genetic/variants/arrays/gwas/imputed/1000genomes/released/27Feb2015/data/genotypes/bestguess/data_chr@ \
		--extract snplist.txt \
		--keep idlist.txt \
		--out test

This uses plink2 (by adding the module `apps/plink2`) so it is very fast. If you have the option to work with best guess SNPs instead of dosages it is recommended that you use these (filtering on MAF and INFO score as necessary).


## Dosage data

Extracting or removing SNPs and individuals from the dosage data is also possible, though quite slow running by comparison. There are two options, the `extract_gen.sh` script will run everything by extracting from each chromosome sequentially, this will likely take several hours, or the `extract_gen_pbs.sh` script which is basically just a template for performing the extraction on each chromosome in parallel on bluecrystal3. This one should be much faster.


### Simple one liner (slow)

The `extract_gen.sh` it uses similar syntax to the `extract_plink.sh` script, but you need to provide the gen files and sample file. The dosage files are located here:

	/panfs/panasas01/shared/alspac/studies/latest/alspac/genetic/variants/arrays/gwas/imputed/1000genomes/released/27Feb2015/data/genotypes/dosage/

and the sample file is located here:

	/panfs/panasas01/shared/alspac/studies/latest/alspac/genetic/variants/arrays/gwas/imputed/1000genomes/released/27Feb2015/data/data.sample

Use the help to see the options on running this script:

	./extract_gen.sh --help

Here is an example that would remove a list of SNPs and remove a list of individuals, and merge the results into a single file set (`test.gz` and `test.sample`):

	./extract_gen.sh \
		--rootname /panfs/panasas01/shared/alspac/studies/latest/alspac/genetic/variants/arrays/gwas/imputed/1000genomes/released/27Feb2015/data/genotypes/dosage/data_chr@.gz \
		--sample /panfs/panasas01/shared/alspac/studies/latest/alspac/genetic/variants/arrays/gwas/imputed/1000genomes/released/27Feb2015/data/data.sample
		--exclude snplist.txt \
		--remove idlist.sample \
		--out test \


### Running batch job (much faster)

The `extract_gen_pbs.sh` script will require some modification from the user - just fill in the lines stating where the files listing SNPs or individuals to extract are located, and where to put the output. For example:


	# Change this file to point to where you want the results to go
	outfile="${HOME}/results_chr${i}"

	# Enter file with list of IDs to extract
	keepids="idlist.txt"

	# Enter file with list of SNPs to keep
	keepsnps="snplist.sample"

You can test that the script is actually working by running it for just one chromosome in the frontend:

	./extract_gen_pbs.sh 22

will run the script for chromosome 22. Not a good idea to let this keep running for a long time in the front end, main thing is to just make sure that it does work for you, and then to kill it press `ctrl + c`. To submit the job to extract all chromosomes simply run:

	qsub extract_gen_pbs.sh

and you can monitor the progress by typing

	qstat -u <username>

Once it's complete you should have 23 pairs of files in the output location you specified, to merge them together you need to run:

	gtool -M --g ${HOME}/results_chr*[!sample].gz --s ${HOME}/results_chr*.sample.gz --og ${HOME}/results --os ${HOME}/results.sample
	gzip ${HOME}/results

and then once you're happy that everything has been merged satisfactorily

	rm ${HOME}/results_chr*
