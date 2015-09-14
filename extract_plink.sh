#!/bin/bash

while [[ $# > 1 ]]
do
key="$1"

case $key in
	-p|--rootname)
	plinkrt="${2}"
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
	-l|--leading)
	leading="true"
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

module add apps/plink2

function instructions {
	echo ""
	echo "This script uses plink1.90 (required in your path) to extract SNPs and/or individuals"
	echo "from binary plink data that has been split into 23 chromosomes"
	echo ""
	echo "--rootname [argument]           Binary plinkfile rootname. e.g. if the data is located at"
	echo "                                chr01.bed chr01.bim chr01.fam chr02.bed chr02.bim ... etc"
	echo "                                then use: chr@"
	echo "                                where the @ symbol represents the chromosome number"
	echo "--extract [argument]            File containing list of SNPs to keep"
	echo "--exclude [argument]            File containing list of SNPs to exclude"
	echo "--keep [argument]               File containing list of SNPs to keep"
	echo "--remove [argument]             File containing list of SNPs to exclude"
	echo "--out [argument]                Output filename"
	echo "--leading                       Use leading zeros in filename"
	echo ""
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
echo "Plink root name = ${plinkrt}"
echo "Output file     = ${outfile}"

rm -f ${outfile}_mergelist.txt
firstchr="1"
flag="0"

cmdbase="plink --noweb --make-bed"

if [ ! -z "${snplistfile1}" ]; then
	cmdbase="${cmdbase} --extract ${snplistfile1}"
	echo "SNPs to keep    = ${snplistfile1}"
fi

if [ ! -z "${snplistfile2}" ]; then
	cmdbase="${cmdbase} --exclude ${snplistfile2}"
	echo "SNPs to exclude = ${snplistfile2}"
fi

if [ ! -z "${idfile1}" ]; then
	cmdbase="${cmdbase} --keep ${idfile1}"
	echo "IDs to keep     = ${idfile1}"
fi

if [ ! -z "${idfile2}" ]; then
	cmdbase="${cmdbase} --remove ${idfile2}"
	echo "IDs to remove   = ${idfile1}"
fi

echo ""

for x in {1..23}
do
	i=${x}
	if [ "${leading}" -eq "true" ]; then
		i=`printf "%0*d" 2 ${x}`
	fi
	
	filename=$(sed -e "s/@/$i/g" <<< ${plinkrt})

	if [ ! -f "${filename}.bed" ]; then
		echo "The file '${filename}'.bed does not exist"
		instructions
	fi

	if [ ! -f "${filename}.bim" ]; then
		echo "The file '${filename}'.bim does not exist"
		instructions
	fi

	if [ ! -f "${filename}.fam" ]; then
		echo "The file '${filename}'.fam does not exist"
		instructions
	fi

	printf "Chromsome ${x} ... "
	cmd="${cmdbase} --bfile ${filename} --out ${outfile}_${i}"
	${cmd} >/dev/null 2>&1
	if [ -f "${outfile}_${i}.bed" ]; then
		echo "${outfile}_${i}.bed ${outfile}_${i}.bim ${outfile}_${i}.fam" >> ${outfile}_mergelist.txt    
		printf "%d individuals and %d SNPs\n" `grep -c ^ ${outfile}_${i}.fam` `grep -c ^ ${outfile}_${i}.bim`
		if [ "${flag}" == "0" ]; then
			firstchr=${i}
		fi
		flag="1"
	else 
		printf "no data after applying filters\n"
	fi
done

printf "\nMerging...\n"
sed -i 1d ${outfile}_mergelist.txt
plink --noweb --bfile ${outfile}_${firstchr} --merge-list ${outfile}_mergelist.txt --make-bed --out ${outfile}

rm ${outfile}_*

echo "Done"
