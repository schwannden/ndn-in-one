#!/bin/bash

########################################
# define help message                  #
########################################
thisFile=`basename $0`
read -d '' help <<- EOF
Usage: ./$thisFile
options:
     -m  mode [default is copy]
         [copy | configure]
     -h  display this message
  ## The following flags are only valid in copy mode ##
     -f  files to copy [default is all]
         [all | ndn-cxx | nfd | cryptopp | conf]
     -a  copy everything [default]
     -l  copy libraries
     -b  copy binaries
     -i  copy headers
EOF

########################################
# Set default values                   #
########################################
target='all'
part='all'
mode='copy'
read -d '' initScript <<- EOF
opkg update;
opkg install --force-overwrite uclibc;
opkg install vim git;
opkg install pkgconfig openssl sqlite3;
EOF
imageURL='http://sourceforge.net/projects/ndn-in-one/files/image.tar.gz'
rootURLL='http://sourceforge.net/projects/ndn-in-one/files/root.tar.gz'

########################################
# detect operating system              #
########################################
function detectOS
{
  if [ "$OSTYPE" == "linux-gnu" ]
  then
    sedFlag='-i '
    echo "operating system: linux"
  elif [[ $OSTYPE == darwin* ]]
  then
    sedFlag="-i '' "
    echo "operating system: darwin"
  else
    echo "un-recognized operating system"
    exit
  fi
}

########################################
# get options                          #
########################################
function getOptions
{
  if [ $# -eq 0 ]
  then
    echo "$help"
    exit
  fi
  
  while getopts ":m:f:albih" opt
  do
    case $opt in
      m)
        if [ "$OPTARG" = "copy" ]
        then
          mode='copy'
        elif [ "$OPTARG" = "configure" ]
        then
          mode='configure'
        else
          echo "option -$opt must be one of [copy | configure]"
          echo "$help"
          exit
        fi
        ;;
      f)
        if [ "$OPTARG" = "all" ]
        then
          target='all'
        elif [ "$OPTARG" = "ndn-cxx" ]
        then
          target='ndn-cxx'
        elif [ "$OPTARG" = "nfd" ]
        then
          target='nfd'
        elif [ "$OPTARG" = "cryptopp" ]
        then
          target='cryptopp'
        elif [ "$OPTARG" = "conf" ]
        then
          target='conf'
        else
          echo "option -$opt must be one of [all, ndn-cxx, nfd, cryptopp, conf]"
          echo "$help"
          exit
        fi
        ;;
      a)
        part='all'
        ;;
      l)
        part='library'
        ;;
      b)
        part='binary'
        ;;
      i)
        part='header'
        ;;
      h)
        echo "$help"
        exit
        ;;
      :)
        echo "option -$OPTARG requires an argument"
        echo "$help"
        exit
        ;;
      \?)
        echo un-recognized option
        echo "$help"
        exit
        ;;
    esac
  done
}

########################################
# main program                         #
########################################
getOptions "$@"

if [ -e /opt/ndn/environment-setup-i586-poky-linux-uclibc ]
then
  echo "detecting tool chain installed in /opt/ndn"
  printf "do you want to $mode from toolchain? [y]"
  read response
  if [ $response == y ]
  then
    echo "continuing....."
    source /opt/ndn/environment-setup-i586-poky-linux-uclibc
  else
    exit
  fi
else
  wget $rootURL
  tar -xzvf root.tar.gz
  cd root
  export PKG_CONFIG_SYSROOT_DIR=`pwd`
  exit
fi

cd $PKG_CONFIG_SYSROOT_DIR
echo "switching directory to $PKG_CONFIG_SYSROOT_DIR"

if [ $mode == copy ]
then
  echo "Transfering $part of $target"

  printf "Enter your Galileo IP: "
  read GalileoIP

  if [ $target == "cryptopp" -o $target == all ]
  then
    echo "Moving cryptopp headers to $GalileoIP"
    scp -r include/cryptopp root@$GalileoIP:/include
    echo "Moving cryptopp libraries to $GalileoIP"
    scp lib/libcryptopp.so root@$GalileoIP:/lib
  fi
  if [ $target == "ndn-cxx"  -o $target == all ]
  then
    echo "Moving ndn-cxx headers to $GalileoIP"
    scp -r  usr/include/ndn-cxx root@$GalileoIP:/usr/include
    echo "Moving ndn-cxx libraries to $GalileoIP"
    scp usr/lib/libndn-cxx.a root@$GalileoIP:/usr/lib
    echo "Moving ndn binaries to $GalileoIP"
    scp -r usr/bin/ndn* root@$GalileoIP:/bin
  fi
  if [ $target == "nfd"      -o $target == all ]
  then
    echo "Moving nfd binaries to $GalileoIP"
    scp -r usr/bin/nfd* root@$GalileoIP:/bin
  fi
  if [ $target == "conf"     -o $target == all ]
  then
    echo "Moving /usr/etc/ndn startup scripts to $GalileoIP"
    ssh root@$GalileoIP 'mkdir -p /opt/ndn/sysroots/i586-poky-linux-uclibc/usr/etc/'
    scp -r usr/etc/ndn root@$GalileoIP:/opt/ndn/sysroots/i586-poky-linux-uclibc/usr/etc/
    scp -r usr/etc/ndn root@$GalileoIP:/opt/ndn/sysroots/i586-poky-linux-uclibc/usr/etc/
  
    echo "Moving base-feeds.conf startup scripts to $GalileoIP"
    echo "src/gz all     http://repo.opkg.net/galileo/repo/all" > base-feeds.conf
    echo "src/gz clanton http://repo.opkg.net/galileo/repo/clanton" >> base-feeds.conf
    echo "src/gz i586    http://repo.opkg.net/galileo/repo/i586" >> base-feeds.conf
    scp base-feeds.conf root@$GalileoIP:/etc/opkg/
    rm -f base-feeds.conf
  fi
  echo "========== copying complete ========="
fi

if [ $mode == configure ]
then
  printf "Enter your Galileo IP: "
  read GalileoIP
  echo "The following commands will be run:"
  echo $initScript
  echo $initScript | xargs ssh root@$GalileoIP 
  exit
  echo $initScript | ssh root@$GalileoIP cat >> init.sh && chmod +x init.sh ; ./init.sh
fi
