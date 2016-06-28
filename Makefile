RELEASE=3.4

# source form https://github.com/zfsonlinux/

# also update version in 
# zfs-changelog.Debian and spl-changelog.Debian
ZFSVER=0.6.5.7
ZFSPKGREL=5~bpo70
SPLPKGREL=5~bpo70
ZFSPKGVER=${ZFSVER}-${ZFSPKGREL}
SPLPKGVER=${ZFSVER}-${SPLPKGREL}

SPLDIR=pkg-spl
SPLSRC=pkg-spl.tar.gz
ZFSDIR=pkg-zfs
ZFSSRC=pkg-zfs.tar.gz

SPL_DEBS= 					\
spl_${SPLPKGVER}_amd64.deb

ZFS_DEBS= 					\
libnvpair1_${ZFSPKGVER}_amd64.deb 		\
libuutil1_${ZFSPKGVER}_amd64.deb		\
libzfs2_${ZFSPKGVER}_amd64.deb			\
libzfs-dev_${ZFSPKGVER}_amd64.deb		\
libzpool2_${ZFSPKGVER}_amd64.deb		\
zfs-dbg_${ZFSPKGVER}_amd64.deb			\
zfs-initramfs_${ZFSPKGVER}_amd64.deb		\
zfsutils_${ZFSPKGVER}_amd64.deb

DEBS=${SPL_DEBS} ${ZFS_DEBS} 

all: ${DEBS}

.PHONY: deb
deb: ${DEBS}

.PHONY: dinstall
dinstall: ${DEBS}
	dpkg -i ${DEBS}

.PHONY: spl
spl ${SPL_DEBS}: ${SPLSRC}
	rm -rf ${SPLDIR}
	tar xf ${SPLSRC}
	mv ${SPLDIR}/debian/changelog ${SPLDIR}/debian/changelog.org
	cat spl-changelog.Debian ${SPLDIR}/debian/changelog.org > ${SPLDIR}/debian/changelog
	cd ${SPLDIR}; ln -s ../spl-patches patches
	cd ${SPLDIR}; quilt push -a
	cd ${SPLDIR}; rm -rf .pc ./patches
	cd ${SPLDIR}; ./debian/rules override_dh_prep-base-deb-files
	cd ${SPLDIR}; dpkg-buildpackage -b -uc -us

.PHONY: zfs
zfs ${ZFS_DEBS}: ${ZFSSRC}
	rm -rf ${ZFSDIR}
	tar xf ${ZFSSRC}
	mv ${ZFSDIR}/debian/changelog ${ZFSDIR}/debian/changelog.org
	cat zfs-changelog.Debian ${ZFSDIR}/debian/changelog.org > ${ZFSDIR}/debian/changelog
	cd ${ZFSDIR}; ln -s ../zfs-patches patches
	cd ${ZFSDIR}; quilt push -a
	cd ${ZFSDIR}; rm -rf .pc ./patches
	cd ${ZFSDIR}; ./debian/rules override_dh_prep-base-deb-files
	cd ${ZFSDIR}; dpkg-buildpackage -b -uc -us 

.PHONY: download
download:
	rm -rf pkg-spl pkg-zfs ${SPLSRC} ${ZFSSRC}
	git clone -b master/debian/wheezy/0.6.5.7-3-wheezy https://github.com/zfsonlinux/pkg-spl.git
	git clone -b master/debian/wheezy/0.6.5.7-8-wheezy https://github.com/zfsonlinux/pkg-zfs.git
	tar czf ${SPLSRC} pkg-spl
	tar czf ${ZFSSRC} pkg-zfs

.PHONY: clean
clean: 	
	rm -rf *~ *.deb *.changes ${ZFSDIR} ${SPLDIR}

.PHONY: distclean
distclean: clean


.PHONY: upload
upload: ${DEBS}
	tar -cf - ${DEBS} | ssh repoman@repo.proxmox.com upload --dist wheezy
