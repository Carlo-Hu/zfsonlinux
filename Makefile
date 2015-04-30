RELEASE=3.4

# source form https://github.com/zfsonlinux/

# also update version in 
# zfs-changelog.Debian and spl-changelog.Debian
ZFSVER=0.6.4
ZFSPKGREL=3~wheezy
SPLPKGREL=3~wheezy
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
	# list tags with:  git tag --list 'master/*'
	git clone https://github.com/zfsonlinux/pkg-spl.git
	# udate manually to 0.6.4.1 for now
	cd pkg-spl; git checkout upstream
	cd pkg-spl; git pull git://github.com/zfsonlinux/spl.git master
	cd pkg-spl; git checkout master/debian/wheezy/0.6.4-1-wheezy
	cd pkg-spl; git	merge upstream -m "merge upstream"
	git clone https://github.com/zfsonlinux/pkg-zfs.git
	cd pkg-zfs; git checkout master/debian/wheezy/0.6.4-1.1-1-wheezy
	tar czf ${SPLSRC} pkg-spl
	tar czf ${ZFSSRC} pkg-zfs

.PHONY: clean
clean: 	
	rm -rf *~ *.deb *.changes ${ZFSDIR} ${SPLDIR}

.PHONY: distclean
distclean: clean


.PHONY: upload
upload: ${DEBS}
	umount /pve/${RELEASE}; mount /pve/${RELEASE} -o rw 
	mkdir -p /pve/${RELEASE}/extra
	rm -f /pve/${RELEASE}/extra/spl_*.deb
	rm -f /pve/${RELEASE}/extra/spl-dkms_*.deb
	rm -f /pve/${RELEASE}/extra/libnvpair1_*.deb
	rm -f /pve/${RELEASE}/extra/libnvpair1-dbg_*.deb
	rm -f /pve/${RELEASE}/extra/libuutil1_*.deb
	rm -f /pve/${RELEASE}/extra/libuutil1-dbg_*.deb
	rm -f /pve/${RELEASE}/extra/libzfs2_*.deb
	rm -f /pve/${RELEASE}/extra/libzfs2-dbg_*.deb
	rm -f /pve/${RELEASE}/extra/libzfs-dev_*.deb
	rm -f /pve/${RELEASE}/extra/libzpool2_*.deb
	rm -f /pve/${RELEASE}/extra/libzpool2-dbg_*.deb
	rm -f /pve/${RELEASE}/extra/zfs_*.deb
	rm -f /pve/${RELEASE}/extra/zfs-dkms_*.deb
	rm -f /pve/${RELEASE}/extra/zfs-doc_*.deb
	rm -f /pve/${RELEASE}/extra/zfs-dbg_*.deb
	rm -f /pve/${RELEASE}/extra/zfs-initramfs_*.deb
	rm -f /pve/${RELEASE}/extra/zfsutils_*.deb
	rm -f /pve/${RELEASE}/extra/zfsutils-dbg_*.deb
	rm -f /pve/${RELEASE}/extra/Packages*
	cp ${DEBS} /pve/${RELEASE}/extra
	cd /pve/${RELEASE}/extra; dpkg-scanpackages . /dev/null > Packages; gzip -9c Packages > Packages.gz
	umount /pve/${RELEASE}; mount /pve/${RELEASE} -o ro

