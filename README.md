# Manipulating the 1000 genomes imputed ALSPAC data

The ALSPAC data comprises about 18000 individuals (mothers and children) with around 40 million imputed SNPs. The two main formats in which these data are stored are in best guess binary plink (`.bed`, `.bim`, `.fam` files) and gen format dosage files (`.gz` and `.sample`)


## Best guess

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

Extracting or removing SNPs and individuals from the dosage data is also possible, though quite slow running. It will take several hours to run this. Use the `extract_gen.sh` script - it uses similar syntax to the `extract_plink.sh` script, but you need to provide the gen files and sample file. The dosage files are located here:

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
