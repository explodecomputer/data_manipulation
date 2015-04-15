#!/bin/bash

while [[ $# > 1 ]]
do
key="$1"

case $key in
	-g|--rootname)
	genort="${2}"
	shift
	;;
	-s|--sample)
	samplefile="${2}"
	shift
	;;
	-x|--extract)
	snplistfile1="${2}"
	shift
	;;
	-e|--exclude)
	snplistfile2="${2}"
	shift
	;;
	-k|--keep)
	idfile1="${2}"
	shift
	;;
	-r|--remove)
	idfile2="${2}"
	shift
	;;
	-o|--out)
	outfile="${2}"
	shift
	;;
	-h|--help)
	showhelp="yes"
	shift
	;;
	--default)
	DEFAULT=YES
	shift
	;;
	*)
			# unknown option
	;;
esac
shift
done

module add apps/gtool-0.7.5

function instructions {
	echo ""
	echo "This script uses gtool (required in your path) to extract SNPs and/or individuals"
	echo "from impute2 dosage data that has been split into 23 chromosomes"
	echo ""
	echo "--rootname [argument]           Impute2 output rootname. e.g. if the data is located at"
	echo "                                chr01.gz chr02.gz chr03.gz ... etc"
	echo "                                then use: chr@.gz"
	echo "                                where the @ symbol represents the chromosome number"
	echo "--sample [argument]             Impute2 sample file"
	echo "--extract [argument]            File containing list of SNPs to keep"
	echo "--exclude [argument]            File containing list of SNPs to exclude"
	echo "--keep [argument]               File containing list of SNPs to keep"
	echo "--remove [argument]             File containing list of SNPs to exclude"
	echo "--out [argument]                Output filename"
	exit
}


if [ ! -z "${showhelp}" ]; then
	instructions
fi

if [[ -n $1 ]]; then
    echo "Unrecognised argument: ${1}"
    instructions
    exit 1
fi

echo ""
echo "Impute2 root name = ${genort}"
echo "Sample file       = ${samplefile}"
echo "Output files      = ${outfile}"

cmdbase="gtool -S --s ${samplefile}"

if [ ! -z "${snplistfile1}" ]; then
	cmdbase="${cmdbase} --inclusion ${snplistfile1}"
	echo "SNPs to keep      = ${snplistfile1}"
fi

if [ ! -z "${snplistfile2}" ]; then
	cmdbase="${cmdbase} --exclusion ${snplistfile2}"
	echo "SNPs to exclude   = ${snplistfile2}"
fi

if [ ! -z "${idfile1}" ]; then
	cmdbase="${cmdbase} --sample_id ${idfile1}"
	echo "IDs to keep       = ${idfile1}"
fi

if [ ! -z "${idfile2}" ]; then
	cmdbase="${cmdbase} --sample_excl ${idfile2}"
	echo "IDs to remove     = ${idfile1}"
fi

echo ""

mg=""
ms=""

for x in {1..23}
do
	i=`printf "%0*d" 2 ${x}`
	filename=$(sed -e "s/@/$i/g" <<< ${genort})

	if [ ! -f "${filename}" ]; then
		echo "The file '${filename}' does not exist"
		instructions
	fi

	cmd="${cmdbase} --g ${filename} --os ${outfile}_${i}.sample --og ${outfile}_${i}"
	${cmd}


	og="${outfile}_${i}"
	os="${outfile}_${i}.sample"

	if [[ ${filename} =~ \.gz$ ]]; then
		og="${og}.gz"
		os="${os}.gz"
		gflag=1
	fi

	mg="${mg} ${og}"
	ms="${ms} ${os}"

done



printf "\nMerging...\n"

if [[ "${gflag}" -eq "1" ]]; then
	outfileg="${outfile}.gz"
	outfiles="${outfile}.sample.gz"
else
	outfileg="${outfile}"
	outfiles="${outfile}.sample"
fi

gtool -M --g ${mg} --s ${ms} --og ${outfile} --os ${outfile}.sample
gzip ${outfile}

rm ${outfile}_*

echo "Done"
