*Copyright (C) Microsoft Corporation*

# Test results for building a custom Linux-Yocto image on Azure VMs of different SKUs

* Build Script: [build_arm64.sh](../tools/build_arm64.sh)
* Script Version: 0.1.0

| SKU                                         | Disk                     | real          | user         | sys         |
|---------------------------------------------|--------------------------|--------------:|-------------:|------------:|
|Standard D32ads v5 (32 vcpus, 128 GiB memory)|P15 - 1100 IOPS, 125 MB/s |real 54m38.774s|user 0m48.983s|sys 0m14.314s|
|Standard D48ads v5 (48 vcpus, 192 GiB memory)|P15 - 1100 IOPS, 125 MB/s |real 44m44.042s|user 0m47.456s|sys 0m16.440s|
|Standard D64ads v5 (48 vcpus, 192 GiB memory)|P15 - 1100 IOPS, 125 MB/s |real 39m31.062s|user 0m45.761s|sys 0m16.149s|
