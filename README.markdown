Ultima IV Remastered
====================

This is the source for my remastered C64 port of Ultima IV. Details on what has been improved over the original can be found [on my blog](http://magervalp.github.io/2015/03/30/u4-remastered.html).


Required Tools
--------------

To build the source you need:

* [cc65](https://github.com/cc65/cc65)
* c1541 from [VICE](http://sourceforge.net/projects/vice-emu/)
* [exomizer](http://hem.bredband.net/magli143/exo/)
* Python 2.x
* GNU Make


Building
--------

To build the source you need disk images of the original Ultima IV release placed in `files/original`. Untouched original images should have the following sha1 checksums:

    86e118fb496e9e7b5126bc0d1c8fa62129f232fd  files/original/u4britannia.d64
    334228897ff774537e56ad706c0ede3afcf7ebc1  files/original/u4program.d64
    728b6cb40ea5dac9e24c31084d70c852ad7eae24  files/original/u4towne.d64
    312984d7aa7a0b8df40003a5852e8827c436c724  files/original/u4underworld.d64

Track 6 on the Program disk contains errors as part of the copy protection and the checksum can differ depending on which tool is used to create `u4program.d64`. The checksum for `u4britannia.d64` also differs if the Britannia disk has been saved to, but as long as both are made from original disks the source will build without problems.

The source then builds from the top Makefile, e.g. with:

    make -j 8


License and Copyright
---------------------

The code is &copy; 2006-2015 Per Olofsson, and is available under an Apache 2.0 license.

The new graphics are &copy; 2015 Vanja Utne.

The crack intro music is &copy; 2015 Johan Samuelson.

The original Ultima IV game is &copy; 1985 Origin Systems, Inc. However, no data from the original game is included in this repository.
