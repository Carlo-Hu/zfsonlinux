RELEASE=5.1

# source form https://github.com/zfsonlinux/

ZFSVER=0.7.12
ZFSPKGREL=pve1~bpo1
SPLPKGREL=pve1~bpo1
ZFSPKGVER=${ZFSVER}-${ZFSPKGREL}
SPLPKGVER=${ZFSVER}-${SPLPKGREL}

SPLDIR=spl-${ZFSVER}
SPLSRC=spl/upstream
SPLPKG=spl/debian
ZFSDIR=zfs-${ZFSVER}
ZFSSRC=zfs/upstream
ZFSPKG=zfs/debian

SPL_DEB = 					\
spl_${SPLPKGVER}_amd64.deb

ZFS_DEB1= libnvpair1linux_${ZFSPKGVER}_amd64.deb
ZFS_DEB2= 					\
libuutil1linux_${ZFSPKGVER}_amd64.deb		\
libzfs2linux_${ZFSPKGVER}_amd64.deb		\
libzfslinux-dev_${ZFSPKGVER}_amd64.deb		\
libzpool2linux_${ZFSPKGVER}_amd64.deb		\
zfs-dbg_${ZFSPKGVER}_amd64.deb			\
zfs-zed_${ZFSPKGVER}_amd64.deb			\
zfs-initramfs_${ZFSPKGVER}_all.deb		\
zfs-test_${ZFSPKGVER}_amd64.deb		\
zfsutils-linux_${ZFSPKGVER}_amd64.deb
ZFS_DEBS= $(ZFS_DEB1) $(ZFS_DEB2)

DEBS=${SPL_DEB} ${ZFS_DEBS}

all: deb
deb: ${DEBS}

.PHONY: dinstall
dinstall: ${DEBS}
	dpkg -i ${DEBS}

.PHONY: submodule
submodule:
	test -f "${ZFSSRC}/README.markdown" || git submodule update --init
	test -f "${SPLSRC}/README.markdown" || git submodule update --init

.PHONY: spl
spl: ${SPL_DEB}
${SPL_DEB}: ${SPLSRC}
	rm -rf ${SPLDIR}
	mkdir ${SPLDIR}
	cp -a ${SPLSRC}/* ${SPLDIR}/
	cp -a ${SPLPKG} ${SPLDIR}/debian
	cd ${SPLDIR}; dpkg-buildpackage -b -uc -us

.PHONY: zfs
zfs: $(ZFS_DEBS)
$(ZFS_DEB2): $(ZFS_DEB1)
$(ZFS_DEB1): $(ZFSSRC)
	rm -rf ${ZFSDIR}
	mkdir ${ZFSDIR}
	cp -a ${ZFSSRC}/* ${ZFSDIR}/
	cp -a ${ZFSPKG} ${ZFSDIR}/debian
	cd ${ZFSDIR}; dpkg-buildpackage -b -uc -us

.PHONY: clean
clean: 	
	rm -rf *~ *.deb *.changes *.buildinfo ${ZFSDIR} ${SPLDIR}

.PHONY: distclean
distclean: clean

.PHONY: upload
upload: ${DEBS}
	tar -cf - ${DEBS} | ssh repoman@repo.proxmox.com -- upload --product pve,pmg --dist stretch --arch amd64
