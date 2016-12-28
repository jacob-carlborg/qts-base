# Docker Image for QTS

This repository contains a Dockerfile for building a Docker image for QTS, the
operating system running on QNAP NAS products. It's useful for developing for
QTS without having to install the development tools directly on your NAS.

This repository does not contain the actual root filesystem. It's easily
extracted from a running QTS system.

This Dockerfile has been tested on a root filesystem from a 64bit QNAP NAS
running QTS 4.2.2.

## Building the Image

### Prerequisites

* A QNAP NAS running the version of QTS you want to build a Docker image for

### Building

1. Make sure SSH is enabled on the NAS
1. Login on the NAS using SSH
1. Execute the following command to bundle the root filesystem in a TAR archive:
    ```
    tar --numeric-owner --exclude=/proc --exclude=/sys --exclude=/share -cvf rootfs.tar /
    ```

    We're excluding `/share` since there is where all the hard drives are
    mounted

1. Copy the newly created TAR file to your local machine using SCP
1. Clone this repository
1. Put the TAR file in the `res` directory, it needs to be called `rootfs.tar`
1. Run `./build.sh` to build the Docker image
1. After the Docker image is built it should be available under the name `qts`

## Developing in the Docker container

To develop in the Docker container install the QTS developer tools (QDK) and/or
install the Entware-ng package manager, which contains most of the common Posix
development tools, like GCC.

### Installing QPKG Packages

A QPKG package consist of a shell script containing a form of startup script and
the binary data for the rest of the package. Since QPKG packages are regular
shell scripts they can be easily installed by just executing the shell script.

Unfortunately there's a caveat when it comes to installing QPKG packages inside
a Docker container. In the beginning of a QPKG package there's a piece of code
looking something like this:

```
/bin/grep "/mnt/HDA_ROOT" /proc/mounts >/dev/null 2>&1 || exit 1
```

This command checks if a filesystem is mounted to `/mnt/HDA_ROOT`. This check
will fail inside a Docker container. One way to workaround this is to modify the
QPKG package (using vim or similar) and comment out that line. If that line is
commented out there's another line that needs to be updated, a line looking
something like this: `script_len=724`. That value needs to be updated to match
the number of characters in the package before the binary data begins. So if `#`
is added to the above line to comment it out, increment the `script_len`
variable with 1.

Another caveat is that it seems most QPKG packages exist with a status code of
10 when installing the package, even though the package was successfully
installed. This makes it a bit more difficult to install a QPKG package as part
of a Dockerfile.
