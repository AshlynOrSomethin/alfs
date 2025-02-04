#!/bin/bash

cd /sources

tar xvf perl-5.34.0.tar.xz

cd Perl-5.34.0

patch -Np1 -i ../perl-5.34.0-upstream_fixes-1.patch

export BUILD_ZLIB=False
export BUILD_BZIP2=0

sh Configure -des                                         \
             -Dprefix=/usr                                \
             -Dvendorprefix=/usr                          \
             -Dprivlib=/usr/lib/perl5/5.34/core_perl      \
             -Darchlib=/usr/lib/perl5/5.34/core_perl      \
             -Dsitelib=/usr/lib/perl5/5.34/site_perl      \
             -Dsitearch=/usr/lib/perl5/5.34/site_perl     \
             -Dvendorlib=/usr/lib/perl5/5.34/vendor_perl  \
             -Dvendorarch=/usr/lib/perl5/5.34/vendor_perl \
             -Dman1dir=/usr/share/man/man1                \
             -Dman3dir=/usr/share/man/man3                \
             -Dpager="/usr/bin/less -isR"                 \
             -Duseshrplib                                 \
             -Dusethreads

make -j6

make install

unset BUILD_ZLIB BUILD_BZIP2

cd /sources

rm -rf perl-5.34.0

echo "Done with Perl"

tar xfv XML-Parser-2.46.tar.gz

cd XML-Parser-2.46

perl Makefile.PL

make -j6 

make install

cd /sources

rm -rf XML-Parser-2.46

echo "Done with XML Parser"

tar xvf intltool-0.51.0.tar.gz

cd intltool-0.51.0

sed -i 's:\\\${:\\\$\\{:' intltool-update.in

./configure --prefix=/usr

make -j6

make install

install -v -Dm644 doc/I18N-HOWTO /usr/share/doc/intltool-0.51.0/I18N-HOWTO

cd /sources

rm -rf intltool-0.51.0

echo "Done with intltool"

tar xvf autoconf-2.71.tar.xz

cd autoconf-2.71

./configure --prefix=/usr

make -j6

make install

cd /sources

rm -rf autoconf-2.71

echo "Done with autoconf"

tar xvf automake-1.16.5.tar.xz

cd automake-1.16.5

./configure --prefix=/usr --docdir=/usr/share/doc/automake-1.16.5

make -j6

make install

cd /sources

rm -rf automake-1.16.5

echo "Done with automake"

tar xvf openssl-3.0.1.tar.gz

cd openssl-3.0.1

./config --prefix=/usr         \
         --openssldir=/etc/ssl \
         --libdir=lib          \
         shared                \
         zlib-dynamic

make -j6

sed -i '/INSTALL_LIBS/s/libcrypto.a libssl.a//' Makefile
make MANSUFFIX=ssl install

mv -v /usr/share/doc/openssl /usr/share/doc/openssl-3.0.1

cp -vfr doc/* /usr/share/doc/openssl-3.0.1

cd /sources

rm -rf openssl-3.0.1

echo "Done with openssl"

tar xvf kmod-29.tar.xz

cd kmod-29

./configure --prefix=/usr          \
            --sysconfdir=/etc      \
            --with-openssl         \
            --with-xz              \
            --with-zstd            \
            --with-zlib

make -j6

make install

for target in depmod insmod modinfo modprobe rmmod; do
  ln -sfv ../bin/kmod /usr/sbin/$target
done

ln -sfv kmod /usr/bin/lsmod

cd /sources

rm -rf kmod-29

echo "Done with kmod"

tar xvf elfutils-0.186.tar.bz2

cd elfutils-0.186

./configure --prefix=/usr                \
            --disable-debuginfod         \
            --enable-libdebuginfod=dummy

make -j6

make -C libelf install
install -vm644 config/libelf.pc /usr/lib/pkgconfig
rm /usr/lib/libelf.a

cd /sources

rm -rf elfutils-0.186.tar.bz2

echo "Done with libelf"

tar xvf libffi-3.4.2.tar.gz

cd libffi-3.4.2

./configure --prefix=/usr          \
            --disable-static       \
            --with-gcc-arch=native \
            --disable-exec-static-tramp

make -j6

make install

cd /sources

rm -rf libffi-3.4.2

echo "Done with libffi-3.4.2"

tar xvf Python-3.10.2.tar.xz

cd Python-3.10.2

./configure --prefix=/usr        \
            --enable-shared      \
            --with-system-expat  \
            --with-system-ffi    \
            --with-ensurepip=yes \
            --enable-optimizations

make -j6

make install

install -v -dm755 /usr/share/doc/python-3.10.2/html

tar --strip-components=1  \
    --no-same-owner       \
    --no-same-permissions \
    -C /usr/share/doc/python-3.10.2/html \
    -xvf ../python-3.10.2-docs-html.tar.bz2

cd /sources

rm -rf Python-3.10.2

echo "Done with Python"

tar xvf ninja-1.10.2.tar.gz 

cd ninja-1.10.2

export NINJAJOBS=4

sed -i '/int Guess/a \
  int   j = 0;\
  char* jobs = getenv( "NINJAJOBS" );\
  if ( jobs != NULL ) j = atoi( jobs );\
  if ( j > 0 ) return j;\
' src/ninja.cc

python3 configure.py --bootstrap

install -vm755 ninja /usr/bin/
install -vDm644 misc/bash-completion /usr/share/bash-completion/completions/ninja
install -vDm644 misc/zsh-completion  /usr/share/zsh/site-functions/_ninja

cd /sources

rm -rf ninja-1.10.2

echo "Done with Ninja and his Fortnite streams"

tar xvf meson-0.61.1.tar.gz

cd meson-0.61.1

python3 setup.py build

python3 setup.py install --root=dest
cp -rv dest/* /
install -vDm644 data/shell-completions/bash/meson /usr/share/bash-completion/completions/meson
install -vDm644 data/shell-completions/zsh/_meson /usr/share/zsh/site-functions/_meson

cd /sources

rm -rf meson-0.61.1

echo "Done with meson"

tar xvf coreutils-9.0.tar.xz

cd coreutils-9.0

patch -Np1 -i ../coreutils-9.0-i18n-1.patch

patch -Np1 -i ../coreutils-9.0-chmod_fix-1.patch

autoreconf -fiv
FORCE_UNSAFE_CONFIGURE=1 ./configure \
            --prefix=/usr            \
            --enable-no-install-program=kill,uptime

make -j6 

make NON_ROOT_USERNAME=tester check-root

echo "dummy:x:102:tester" >> /etc/group

chown -Rv tester . 

su tester -c "PATH=$PATH make RUN_EXPENSIVE_TESTS=yes check"

sed -i '/dummy/d' /etc/group

make install

mv -v /usr/bin/chroot /usr/sbin
mv -v /usr/share/man/man1/chroot.1 /usr/share/man/man8/chroot.8
sed -i 's/"1"/"8"/' /usr/share/man/man8/chroot.8

cd /sources

rm -rf coreutils-9.0

echo "Done with Coreutils"

tar xvf check-0.15.2.tar.gz

cd check-0.15.2

./configure --prefix=/usr --disable-static

make -j6

meke docdir=/usr/share/doc/check-0.15.2 install

cd /sources

rm -rf check-0.15.2

echo "Done with Check"

tar xvf diffutils-3.8.tar.xz

cd diffutils-3.8

./configure --prefix=/usr

make -j6 

make install

cd /sources

rm -rf diffutils-3.8

echo "Done with diffutils"

tar xvf gawk-5.1.1.tar.xz

cd gawk-5.1.1

sed -i 's/extras//' Makefile.in

./configure --prefix=/usr

make -j6 

make install

mkdir -pv                                   /usr/share/doc/gawk-5.1.1
cp    -v doc/{awkforai.txt,*.{eps,pdf,jpg}} /usr/share/doc/gawk-5.1.1

cd /sources

rm -rf gawk-5.1.1

echo "Done with gawk"

tar xvf findutils-4.9.0.tar.xz

cd findutils-4.9.0

case $(uname -m) in
    i?86)   TIME_T_32_BIT_OK=yes ./configure --prefix=/usr --localstatedir=/var/lib/locate ;;
    x86_64) ./configure --prefix=/usr --localstatedir=/var/lib/locate ;;
esac

make -j6

chown -Rv tester .
su tester -c "PATH=$PATH make check"

make install

cd /sources

rm -rf findutils-4.9.0

echo "Done with findutils"

tar xvf groff-1.22.4.tar.gz

cd groff-1.22.4

PAGE=<paper_size> ./configure --prefix=/usr

make -j1

make install

cd /sources

rm -rf groff-1.22.4

echo "Done with groff"

tar xvf gzip-1.11.tar.xz

cd gzip-1.11

./configure --prefix=/usr

make -j6 

make install

cd /sources

rm -rf gzip-1.11

echo "Done with gzip"

tar xvf iproute2-5.16.0.tar.xz

cd iproute2-5.16.0

sed -i /ARPD/d Makefile
rm -fv man/man8/arpd.8

make -j6

make SBINDIR=/usr/sbin install

mkdir -pv             /usr/share/doc/iproute2-5.16.0
cp -v COPYING README* /usr/share/doc/iproute2-5.16.0

cd /sources

rm -rf iproute2-5.16.0

echo "Done with iproute"

tar xvf kbd-2.4.0.tar.xz

cd kbd-2.4.0

patch -Np1 -i ../kbd-2.4.0-backspace-1.patch

sed -i '/RESIZECONS_PROGS=/s/yes/no/' configure
sed -i 's/resizecons.8 //' docs/man/man8/Makefile.in

./configure --prefix=/usr --disable-vlock

make -j6

make install

mkdir -pv           /usr/share/doc/kbd-2.4.0
cp -R -v docs/doc/* /usr/share/doc/kbd-2.4.0

cd /sources

rm -rf kbd-2.4.0

echo "Done with kbd"

tar xvf libpipeline-1.5.5.tar.gz

cd libpipeline-1.5.5

./configure --prefix=/usr

make -j6

make install

cd /sources

rm -rf libpipeline-1.5.5

echo "Done with libpipeline"

tar xvf make-4.3.tar.gz

cd make-4.3

./configure --prefix=/usr

make -j6

make install

cd /sources

rm -rf make-4.3

tar xvf patch-2.7.6.tar.xz

cd patch-2.7.6

./configure --prefix=/usr

make -j6

make install

cd /sources

rm -rf patch-2.7.6

echo "Done with patch"

tar xvf tar-1.34.tar.xz

cd tar-1.34

FORCE_UNSAFE_CONFIGURE=1  \
./configure --prefix=/usr

make -j6

make install
make -C doc install-html docdir=/usr/share/doc/tar-1.34

cd /sources

rm -rf tar-1.34

echo "Done with tar"

tar xvf texinfo-6.8.tar.xz

cd texinfo-6.8

./configure --prefix=/usr

sed -e 's/__attribute_nonnull__/__nonnull/' \
    -i gnulib/lib/malloc/dynarray-skeleton.c

make -j6

make install

make TEXMF=/usr/share/texmf install-tex

cd /sources

rm -rf texinfo-6.8

echo "Done with texinfo"

tar xvf nano-6.3.tar.xz

cd nano-6.3

./configure --prefix=/usr     \
            --sysconfdir=/etc \
            --enable-utf8     \
            --docdir=/usr/share/doc/nano-6.3 &&
make -j6

make install &&
install -v -m644 doc/{nano.html,sample.nanorc} /usr/share/doc/nano-6.3

cd /sources

rm -rf nano-6.3

tar xvf MarkupSafe-2.0.1.tar.gz

cd MarkupSafe-2.0.1

python3 setup.py build

python3 setup.py install --optimize=1

cd /sources

rm -rf MarkupSafe-2.0.1

tar xvf Jinja2-3.0.3.tar.gz

cd Jinja2-3.0.3

python3 setup.py install --optimize=1

cd /sources

rm -rf Jinja2-3.0.3

tar xvf systemd-250.tar.gz

cd systemd-250

patch -Np1 -i ../systemd-250-upstream_fixes-1.patch

sed -i -e 's/GROUP="render"/GROUP="video"/' \
       -e 's/GROUP="sgx", //' rules.d/50-udev-default.rules.in

mkdir -p build
cd       build

meson --prefix=/usr                 \
      --sysconfdir=/etc             \
      --localstatedir=/var          \
      --buildtype=release           \
      -Dblkid=true                  \
      -Ddefault-dnssec=no           \
      -Dfirstboot=false             \
      -Dinstall-tests=false         \
      -Dldconfig=false              \
      -Dsysusers=false              \
      -Db_lto=false                 \
      -Drpmmacrosdir=no             \
      -Dhomed=false                 \
      -Duserdb=false                \
      -Dman=false                   \
      -Dmode=release                \
      -Ddocdir=/usr/share/doc/systemd-250 \

ninja

ninja install

tar -xf ../../systemd-man-pages-250.tar.xz --strip-components=1 -C /usr/share/man

rm -rf /usr/lib/pam.d

systemd-machine-id-setup

systemctl preset-all

cd /sources

rm -rf systemd-250

tar xvf dbus-1.12.20.tar.gz

cd dbus-1.12.20

./configure --prefix=/usr                        \
            --sysconfdir=/etc                    \
            --localstatedir=/var                 \
            --disable-static                     \
            --disable-doxygen-docs               \
            --disable-xml-docs                   \
            --docdir=/usr/share/doc/dbus-1.12.20 \
            --with-console-auth-dir=/run/console \
            --with-system-pid-file=/run/dbus/pid \
            --with-system-socket=/run/dbus/system_bus_socket

make -j6

make install

ln -sfv /etc/machine-id /var/lib/dbus

cd /sources

rm -rf dbus-1.12.20

tar xvf man-db-2.10.1.tar.xz

cd man-db-2.10.1

./configure --prefix=/usr                         \
            --docdir=/usr/share/doc/man-db-2.10.1 \
            --sysconfdir=/etc                     \
            --disable-setuid                      \
            --enable-cache-owner=bin              \
            --with-browser=/usr/bin/lynx          \
            --with-vgrind=/usr/bin/vgrind         \
            --with-grap=/usr/bin/grap

make -j6

make install

cd /sources

tar xvf procps-ng-3.3.17.tar.xz

cd procps-ng-3.3.17

./configure --prefix=/usr                            \
            --docdir=/usr/share/doc/procps-ng-3.3.17 \
            --disable-static                         \
            --disable-kill                           \
            --with-systemd

make -j6

make install

cd /sources

rm -rf procps-ng-3.3.17

tar xvf util-linux-2.37.4.tar.xz

cd util-linux-2.37.4

./configure ADJTIME_PATH=/var/lib/hwclock/adjtime   \
            --bindir=/usr/bin    \
            --libdir=/usr/lib    \
            --sbindir=/usr/sbin  \
            --docdir=/usr/share/doc/util-linux-2.37.4 \
            --disable-chfn-chsh  \
            --disable-login      \
            --disable-nologin    \
            --disable-su         \
            --disable-setpriv    \
            --disable-runuser    \
            --disable-pylibmount \
            --disable-static     \
            --without-python

make -j6

make install

cd /sources

rm -rf util-linux-2.37.4

tar xvf e2fsprogs-1.46.5.tar.gz

cd e2fsprogs-1.46.5

mkdir -v build
cd       build

../configure --prefix=/usr           \
             --sysconfdir=/etc       \
             --enable-elf-shlibs     \
             --disable-libblkid      \
             --disable-libuuid       \
             --disable-uuidd         \
             --disable-fsck

make -j6

make install

rm -fv /usr/lib/{libcom_err,libe2p,libext2fs,libss}.a

gunzip -v /usr/share/info/libext2fs.info.gz
install-info --dir-file=/usr/share/info/dir /usr/share/info/libext2fs.info

makeinfo -o      doc/com_err.info ../lib/et/com_err.texinfo
install -v -m644 doc/com_err.info /usr/share/info
install-info --dir-file=/usr/share/info/dir /usr/share/info/com_err.info
