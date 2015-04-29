# ndn-in-one

This all in one script aimed to facilitae installation of NDN on Galileo.
To see more detail, visit [NDN on Galileo](www.gitbook.com/book/schwannden/ndn-on-galileo/)

## Tutorial
To download Galileo image

`
./sdk2Galileo -m get image
`

See [boot from SD card](http://schwannden.gitbooks.io/ndn-on-galileo/content/boot_from_sd_card.html) for how to write image to SD card and boot Galileo from SD card image.

To configure Galileo

`
./sdk2Galileo -a
./sdk2Galileo -m configure
`

During the process, the script will ask you to download required toolchain (or detect your toolchain if you already have one), and ask you to input the IP address of your Galileo. So the computer running script need to be able to connect to the Galileo (if they are in the same LAN, it should be perfect).


## More Tutorial
To download ndn headers, libraries, binaries

`
./sdk2Galileo -m get ndn
`

To copy all ndn headers, libraries, binaries to Galileo to galileo

`
./sdk2Galileo -m copy
`

Copy only `ndn-cxx` to Galileo
`
./sdk2Galileo -m copy -f ndn-cxx
`

Copy only `ndn-cxx` headers to Galileo
`
./sdk2Galileo -m copy -f ndn-cxx -i
`

Copy only `nfd` binaries to Galileo
`
./sdk2Galileo -m copy -f nfd -b
`

In the process, the script will ask you to download required files and your Galileo IP

Use `./sdk2Galileo -h` to display this help message:

```
     -m  mode [default is copy]
         [copy | configure | get]
     -h  display this message
  ## The following flags are only valid in copy mode ##
     -f  files to copy [default is all]
         [all | ndn-cxx | nfd | cryptopp | conf]
     -a  copy everything [default]
     -l  copy libraries
     -b  copy binaries
     -i  copy headers
```
