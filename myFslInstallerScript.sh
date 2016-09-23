#!/bin/bash
#myfslinstaller.sh

set -e
set -u
set -o errexit
set -o pipefail
set -o nounset

# input args (with defaults):
# * version
# * os (centos 5 to 7)
# * install dir
# * download dir

#myfslinstaller function takes the parameters and downloads the corresponding file of fsl installer from the server 
#with the help of os and version parameters
if [[ $# -eq 0 ]] ; then
    echo 'No parameters are passed, taking default values'
fi

version=${1:-5.0.6}
os=${2:-CentOS7}
user=$USER
installDir=${3:-/home/"$user"/fsl/}
downloadDir=${4:-/home/"$user"/downloads/}

function myFslInstaller {
echo "###----FSL INSTALLER---###"
echo "$version"
echo "$os"
echo "$user"
echo "$installDir"
echo "$downloadDir"

if [[ ! ("$version" =~ ^[0-9].+$) ]]; then 
    echo 'Please pass a number that corresponds to an existing version of FSL'
    exit 1
fi

url=$(getDownloadURL "$version" "$os")

echo "filename"
downloadFileName=$(echo "$url"|sed 's#.*/##')
echo "$downloadFileName"

fslDownloadDir=$downloadDir"$downloadFileName"
echo "$fslDownloadDir"

valid=$(validURL "$url")
echo "Valid: $valid"
if [[ "$valid" == true ]]; then
 download "$url" "$fslDownloadDir"
else
 echo "File doesn't exist in server"
 exit 1
fi

md5Url=$(getMD5Url "$version" "$os")
echo "$md5Url"

md5DownloadDir=$downloadDir"$version"".txt"

download "$md5Url" "$md5DownloadDir"

validateMD5 "$md5DownloadDir" "$fslDownloadDir"

}

function getMD5Url {
version="$1"
os="$2"
os="${os,,}"
main_url='http://fsl.fmrib.ox.ac.uk/fsldownloads/md5sums/'
if [[ "$version" == "5.0.6" ]]; then
         if [[ "$os" == "centos7" || "$os" == "centos6" ]]; then
                 md5Url=$main_url"fsl-5.0.6-centos6_64.tar.gz.md5"
                 echo "$md5Url"
         elif [[ "$os" == "centos5" ]]; then
                 md5Url=$main_url"fsl-5.0.6-centos5_64.tar.gz.md5"
                  echo "$md5Url"
         fi
elif [[ "$version" == "5.0.7" ]]; then
         if [[ "$os" == "centos7" || "$os" == "centos6" ]]; then
                 md5Url=$main_url"fsl-5.0.7-centos6_64.tar.gz.md5"
                 echo "$md5Url"
         elif [[ "$os" == "centos5" ]]; then
                 md5Url=$main_url"fsl-5.0.7-centos5_64.tar.gz.md5"
                 echo "$md5Url"
         fi
elif [[ "$version" == "5.0.8" ]]; then
         if [[ "$os" == "centos7" || "$os" == "centos6" ]]; then
                 md5Url=$mfain_url"fsl-5.0.8-centos6_64.tar.gz.md5"
                 echo "$md5Url"
         elif [[ "$os" == "centos5" ]]; then
                 md5Url=$main_url"fsl-5.0.8-centos5_64.tar.gz.md5"
                 echo "$md5Url"
         fi
fi
}

#Parameters: Version and OS
#Function getDownloadURL will return the url for downloading the requested version.
function getDownloadURL {
version="$1"
os="$2"
os="${os,,}"
#echo "$os"
if [[ ( "$version" == "5.0.6" && "$os" == "centos7" ) || ( "$version" == "5.0.6" && "$os" == "centos6" ) ]]; then
	echo  'http://fsl.fmrib.ox.ac.uk/fsldownloads/oldversions/fsl-5.0.6-centos6_64.tar.gz'
elif [[ ( "$version" == "5.0.6" && "$os" == "centos5" ) ]]; then
        echo 'http://fsl.fmrib.ox.ac.uk/fsldownloads/oldversions/fsl-5.0.6-centos5_64.tar.gz'
elif [[ ( "$version" == "5.0.7" && "$os" == "centos6" ) || ( "$version" == "5.0.7" && "$os" == "centos7" ) ]]; then
        echo 'http://fsl.fmrib.ox.ac.uk/fsldownloads/oldversions/fsl-5.0.7-centos6_64.tar.gz'
elif [[ ( "$version" == "5.0.7" && "$os" == "centos5" ) ]]; then
        echo 'http://fsl.fmrib.ox.ac.uk/fsldownloads/oldversions/fsl-5.0.7-centos5_64.tar.gz'
elif [[ ( "$version" == "5.0.8" && "$os" == "centos6" ) || ( "$version" == "5.0.8" && "$os" == "centos7" ) ]]; then        echo 'http://fsl.fmrib.ox.ac.uk/fsldownloads/oldversions/fsl-5.0.8-centos6_64.tar.gz'
elif [[ ( "$version" == "5.0.8" && "$os" == "centos5" ) ]]; then
        echo 'http://fsl.fmrib.ox.ac.uk/fsldownloads/oldversions/fsl-5.0.8-centos5_64.tar.gz'
else
 echo 'Invalid parameters. Check the input parameters and try again'
 exit 1
fi
}

#Parameter:Download URL
#Function validURL will return true or false according to the status of the url
function validURL {
if [[ `wget -S --spider $1  2>&1 | grep 'HTTP/1.1 200 OK'` ]]; then echo "true"; fi
}

# Download function downloads the file in corresponding directory
function download {
downloadUrl="$1"
fileName="$2"
echo "Downloading.."
wget $downloadUrl -O $fileName
}

#validateMD5

function validateMD5 {
md5FileName="$1"
fslFileName="$2"
value=$(<$md5FileName)
echo "MD5"
echo "$value"
localmd5=$(md5sum "$md5FileName")
echo "$localmd5"
rm "$fileName"
}

#Function call
myFslInstaller


# unpack in install dir and install

# set the environment (check in the installer)
# # Set environment variables (run export not needed)
#export FSLDIR=install_dir
#export PATH=$PATH:${FSLDIR}/bi#. ${FSLDIR}/etc/fslconf/fsl.sh
