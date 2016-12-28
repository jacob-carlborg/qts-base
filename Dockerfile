FROM scratch

ADD res/rootfs.tar /

# These directories and files are required to install QPKG packages.
# On the actual NAS the hard drives are mounted to these directories.

RUN \
  # These two directories need to match the ones in res/smb.conf, basically
  # telling where the system default share is located.
  mkdir -p /share/CACHEDEV1_DATA/Public && \
  mkdir -p /share/CACHEDEV1_DATA/_.share/Public/.snapshot && \
  mkdir -p /mnt/HDA_ROOT/.config && \
  ln -sf /mnt/HDA_ROOT/.config /etc/config && \
  # For some reason this directory needs to exist to be able to install the QDK
  # package.
  mkdir -p /share/CACHEDEV1_DATA/.qpkg/QDK

ADD res/smb.conf /etc/config/smb.conf

CMD ["/bin/bash"]
