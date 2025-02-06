#variable declaration 
kernelUrl=https://github.com/torvalds/linux.git #linux kernel git repo
busyboxUrl=https://git.busybox.net/busybox #busybox userspace repo
ncurseUrl=https://ftp.gnu.org/pub/gnu/ncurses/ncurses-6.4.tar.gz
klogfile=../kernel_log.txt #kernel make output log
busylogfile=../busy_log.txt #busybox make output log
kerneldir=linux #kernel directory
busydir=busybox #busybox directory
initramdir=intiramfs #intiramfs directory
cursedir=ncurses-6.4
linker=/lib64/ld-linux-x86-64.so.2
ncurseinsdir=$initramdir/usr
makeargs=-j ($nprocs - 2)


#set up all the intial folders needed
echo initial folder creation
mkdir $initramdir $kerneldir $busydir
cd $initramdir
mkdir  usr bin etc
mkdir usr/lib



#grab the kerenel and userspace
echo pulling latest linux kernel from:"https://github.com/torvalds/linux.git"
git pull --depth 1 $kernelUrl
echo pulling usrspace for initramfs...
git pull --depth 1 $busyboxUrl


#copy the repsective config files so we have to
#run make menuconfig  everytime
echo applying configs...
touch $keneldir/.config
touch $busydir/.config
cp .kernelconfig $kerneldir/.config
cp .busyboxconfig $busydir/.config


#make the kernel using supplied config...
echo entering $kerneldir ...
cd $kerneldir
echo running make...
echo make  output can be found at:
echo $klogfile
make $makeargs > $klogfile


#...and copy the kernel bin to the proj root.
echo copying bzimage to project root... 
cp arch/x86_64/boot/bzImage ..
echo exiting $kerneldir
cd ..



#build the busybox userspace...
echo entering $busydir ...
cd $busydir
echo building busybox userspace
make $makeargs > $busylog


#...and then install it into the folder $initramdir
make CONFIG_PREFIX=../$initramdir install $makeargs
echo Exiting $busydir ...
cd ..
#pull Ncurses and install into $initramdir/lib
echo downlaoding Ncurses...
wget $ncurseUrl
tar -xvzf ncurses-6.4.tar.gz 
cd $cursedir
./configure --prefix=/usr --without-debug --without-ada --enable-widec
make $makeargs
make DESTDIR=../$ncursedir install
echo "/usr/lib" >> $intiramdir/etc/ld.so.conf
