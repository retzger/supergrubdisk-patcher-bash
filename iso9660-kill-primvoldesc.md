
This patch is to mutilate the SuperGrubDisk_PrimaryVolumeDescriptor
in order to make GParted 0.25.0 (libparted 3.2) show the individual
partitions instead of just one big ISO CD-ROM.
Unfortunately, this seems to break non-UEFI boot.

Our `x` in `CD00x` is a work-around for
https://bugzilla.gnome.org/show_bug.cgi?id=771244#c18 :
Albeit the linefeeds around `CD001` void the one and only PVD, and thus
void the ISO 9660 compliance, gparted and even wipefs still (wrongly)
report it as ISO 9660.
