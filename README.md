
<!--#echo json="package.json" key="name" underline="=" -->
supergrubdisk-patcher
=====================
<!--/#echo -->

<!--#echo json="package.json" key="description" -->
Patch the SuperGrub2 disk image
<!--/#echo -->


Now you can reconfigure your
[SuperGrub](https://github.com/supergrub/supergrub/)
without needing to compile it.


Usage
-----

```text
$ ln --symbolic super_grub2_disk_hybrid_2.04rc1s1-beta4.iso orig.iso
$ ./patcher.sh --restore --patch *.hax --reupload thumbdrive.dev
D: restore: ‘orig.iso’ -> ‘custom.iso’
D: gonna write 'iso9660-kill-primvoldesc.hax' into 'custom.iso' at offset 32768
D: gonna write 'search_same_device.hax' into 'custom.iso' at offset 3450880
D: reupload 'custom.iso' onto 'thumbdrive.dev': 15946+0 records in
15946+0 records out
16328704 bytes (16 MB) copied, 5.60342 s, 2.9 MB/s
```


CLI
---

:TODO: explain available commands and the patch file format



<!--#toc stop="scan" -->



Known issues
------------

* Needs more/better tests and docs.




&nbsp;


License
-------
<!--#echo json="package.json" key=".license" -->
GPL-3.0
<!--/#echo -->
