# ndn-in-one

This all in one script aimed to facilitae installation of NDN on Galileo.
To see more detail, visit [NDN on Galileo](www.gitbook.com/book/schwannden/ndn-on-galileo/)

## Tutorial
to download Galileo image

`
./sdk2Galileo -m get image
`

to download ndn headers, libraries, binaries

`
./sdk2Galileo -m get ndn
`

to copy all ndn headers, libraries, binaries to Galileo

`
./sdk2Galileo -a
`

In the process, the script will ask you to download required files and your Galileo IP

to configure everything on Galileo

`
./sdk2Galileo -m configure
`
