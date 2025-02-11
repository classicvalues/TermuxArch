#!/usr/bin/env bash
## Copyright 2017-2022 by SDRausty. All rights reserved.  🌎 🌍 🌏 🌐 🗺
## Hosted sdrausty.github.io/TermuxArch courtesy https://pages.github.com
## https://sdrausty.github.io/TermuxArch/README has info about this project.
## https://sdrausty.github.io/TermuxArch/CONTRIBUTORS Thank you for your help.
################################################################################

_COPYIMAGE_() { # A systemimage.tar.gz file can be used: 'setupTermuxArch ./[path/]systemimage.tar.gz' and 'setupTermuxArch /absolutepath/systemimage.tar.gz'
if [[ "$LCP" = "0" ]]
then
printf "%s\\n" "Copying $GFILE.md5 to $INSTALLDIR..."
cp "$GFILE".md5  "$INSTALLDIR"
printf "%s\\n" "Copying $GFILE to $INSTALLDIR..."
cp "$GFILE" "$INSTALLDIR"
elif [[ "$LCP" = "1" ]]
then
printf "%s\\n" "Copying $GFILE.md5 to $INSTALLDIR..."
cp "$WDIR$GFILE".md5  "$INSTALLDIR"
printf "%s\\n" "Copying $GFILE to $INSTALLDIR..."
cp "$WDIR$GFILE" "$INSTALLDIR"
fi
GFILE="${GFILE##/*/}"
IFILE="${GFILE##*/}"
}

_DOFUNLCR2_() {
BKPDIR="$INSTALLDIR/var/backups/${INSTALLDIR##*/}/home/$USER"
_BKPTHF_() { # backup the user files
[[ ! -d "$BKPDIR/" ]] && mkdir -p "$BKPDIR/"
cd "$INSTALLDIR/home/$USER"
[[ -f $1 ]] && printf "\\e[1;32m==>\\e[0;32m %s" "File '/${INSTALLDIR##*/}/home/$USER/$1' backed up to /${INSTALLDIR##*/}/var/backups/${INSTALLDIR##*/}/home/$USER/$1.$SDATE.bkp" && cp "$1" "$BKPDIR/$1.$SDATE.bkp" || _PSGI1ESTRING_ "cp '$1' if found maintenanceroutines.bash ${0##*/}"
}
if [ -d "$INSTALLDIR/home" ]
then
if [[ "$USER" != alarm ]]
then
export "$USER"
DOFLIST=(.bash_profile .bashrc .gitconfig .vimrc)
for DOFLNAME in "${DOFLIST[@]}"
do
_BKPTHF_ "$DOFLNAME"
cp "$INSTALLDIR/root/$DOFLNAME" "$INSTALLDIR/home/$USER/"
printf "\\n\\e[0;32mCopied file %s to \\e[1;32m%s\\e[0;32m.\\e[0m\\n" "/${INSTALLDIR##*/}/root/$DOFLNAME" "/${INSTALLDIR##*/}/home/$USER/$DOFLNAME"
done
fi
fi
cd "$INSTALLDIR/root"
}

_DOTHRF_() { # do the root user files
if [[ "${LCR:-}" -eq 3 ]] || [[ "${LCR:-}" -eq 4 ]] 	# LCR equals 3 or 4
then	# do nothing
:
else
[[ -f $1 ]] && (printf "\\e[1;32m%s\\e[0;32m%s\\e[0m\\n" "==>" " cp $1 /var/backups/${INSTALLDIR##*/}/$1.$SDATE.bkp" && cp "$1" "$INSTALLDIR/var/backups/${INSTALLDIR##*/}/$1.$SDATE.bkp") || printf "%s" "copy file '$1' if found; file not found; continuing; "
fi
}

_FUNLCR2_() { # copy from root to home/USER
export FLCRVAR=($(ls "$INSTALLDIR/home/"))
for USER in ${FLCRVAR[@]}
do
_DOFUNLCR2_
done
}

_LOADIMAGE_() {
_NAMESTARTARCH_
_SPACEINFO_
printf "\\n"
_WAKELOCK_
_PREPINSTALLDIR_
_COPYIMAGE_
_MD5CHECK_
_PRINTCU_
rm -f "$INSTALLDIR"/*.tar.gz "$INSTALLDIR"/*.tar.gz.md5
_PRINTDONE_
_PRINTCONFIGUP_
_TOUCHUPSYS_
printf "\\n"
_WAKEUNLOCK_
_PRINTFOOTER_
set +Eeuo pipefail
"$INSTALLDIR/$STARTBIN" || _PRINTPROOTERROR_
set -Eeuo pipefail
_PRINTFOOTER2_
_PRINTSTARTBIN_USAGE_
exit
}

_FIXOWNER_() { # fix owner of INSTALLDIR/home/USER, PR9 by @petkar
_DOFIXOWNER_() {
printf "\\e[1;32m%s\\e[0m\\n" "Adjusting ownership and permissions..."
FXARR="$(ls "$INSTALLDIR/home")"
for USER in ${FXARR[@]}
do
if [[ "$USER" != alarm ]]
then
$STARTBIN c "chmod 777 $INSTALLDIR/home/$USER"
$STARTBIN c "chown -R $USER:$USER $INSTALLDIR/home/$USER"
fi
done
}
_DOFIXOWNER_ || _PSGI1ESTRING_ "_DOFIXOWNER_ maintenanceroutines.bash ${0##*/}"
}

_REFRESHSYS_() { # refresh installation
printf '\033]2; setupTermuxArch refresh 📲 \007'
_NAMESTARTARCH_
_SPACEINFO_
cd "$INSTALLDIR"
_SETLANGUAGE_
_PREPROOTDIR_ || _PSGI1ESTRING_ "_PREPROOTDIR_ _REFRESHSYS_ maintenanceroutines.bash ${0##*/}"
_ADDADDS_
_MAKEFINISHSETUP_
_MAKESETUPBIN_
_MAKESTARTBIN_
_SETLOCALE_
printf "\\n"
_WAKELOCK_
printf "\\e[1;32m==> \\e[1;37m%s \\e[1;32m%s %s...\\n" "Running" "${0##*/}" "$ARGS"
"$INSTALLDIR"/root/bin/setupbin.bash || _PRINTPROOTERROR_
rm -f root/bin/finishsetup.bash
rm -f root/bin/setupbin.bash
printf "\\n\\e[1;32mFiles updated to the newest version %s:\\n\\e[0;32m" "$VERSIONID"
ls "$INSTALLDIR/$STARTBIN" | cut -f7- -d /
ls "$INSTALLDIR"/bin/we | cut -f7- -d /
ls "$INSTALLDIR"/root/.bashrc | cut -f7- -d /
ls "$INSTALLDIR"/root/.bash_profile | cut -f7- -d /
ls "$INSTALLDIR"/root/.vimrc | cut -f7- -d /
ls "$INSTALLDIR"/root/.gitconfig | cut -f7- -d /
printf "\\n\\e[1;32m%s\\n\\e[0;32m" "Files updated to the newest version $VERSIONID in directory ~/${INSTALLDIR##*/}/usr/local/bin/:"
ls "$INSTALLDIR/usr/local/bin/"
_SHFUNC_ () {
_SHFDFUNC_ () {
SHFD="$(find "$RMDIR" -type d -printf '%03d %p\n' | sort -r -n -k 1 | cut -d" " -f 2)"
for SHF1D in $SHFD
do
rmdir "$SHF1D" || printf "%s" "Cannot 'rmdir $SHF1D'; Continuing..."
done
}
printf "%s\n" "Script '${0##*/}' checking and fixing permissions in directory '$PWD': STARTED..."
SDIRS="apex data host-rootfs sdcard storage system vendor"
for SDIR in $SDIRS
do
RMDIR="$INSTALLDIR/$SDIR"
[ -d "$RMDIR" ] && { chmod 755 "$RMDIR" ; printf "%s" "Deleting superfluous '$RMDIR' directory: " && (rmdir "$RMDIR" || _SHFDFUNC_) && printf "%s\n" "Continuing..." ; }
done
PERRS="$(du "$INSTALLDIR" 2>&1 >/dev/null ||:)"
PERRS="$(sed "s/du: cannot read directory '//g" <<< "$PERRS" | sed "s/': Permission denied//g")"
[ -z "$PERRS" ] || { printf "%s" "Fixing  permissions in '$INSTALLDIR': " && for PERR in $PERRS ; do chmod 777 "$PERR" ; done && printf "%s\n" "DONE" ; } || printf "%s" "Fixing  permissions signal PERRS; Continuing..."
printf "%s\n" "Script '${0##*/}' checking and fixing permissions: DONE"
}
[ "$LCR" = 4 ] && [ -d "$INSTALLDIR" ] && _SHFUNC_ "$@"
if [[ "${LCR:-}" = 2 ]]
then
_FUNLCR2_
fi
printf "\\n"
_COPYSTARTBIN2PATH_
_WAKEUNLOCK_
_PRINTFOOTER_
set +Eeuo pipefail
$STARTBIN || _PRINTPROOTERROR_
set -Eeuo pipefail
_PRINTFOOTER2_
_PRINTSTARTBIN_USAGE_
exit
}

_SPACEINFO_() {
declare SPACEMESSAGE=""
units="$(df "$INSTALLDIR" 2>/dev/null | awk 'FNR == 1 {print $2}')"
if [[ "$units" = Size ]]
then
_SPACEINFOGSIZE_
printf "$SPACEMESSAGE"
elif [[ "$units" = 1K-blocks ]]
then
_SPACEINFOKSIZE_
printf "$SPACEMESSAGE"
fi
}

_SPACEINFOGSIZE_() {
_USERSPACE_
if [[ "$CPUABI" = "$CPUABIX86" ]] || [[ "$CPUABI" = "$CPUABIX8664" ]] || [[ "$CPUABI" = i386 ]]
then
if [[ "$USRSPACE" = *G ]]
then
SPACEMESSAGE=""
elif [[ "$USRSPACE" = *M ]]
then
USSPACE="${USRSPACE:; -1}"
fi
if [[ "$USSPACE" -lt "800" ]] && [[ "$CPUABI" = "$CPUABIX8664" ]]
then
SPACEMESSAGE="\\e[0;33mTermuxArch: \\e[1;33mFREE SPACE WARNING!  \\e[1;30mStart thinking about cleaning out some stuff please.  \\e[33mThere is only $USRSPACE of free user space is available on this device.  \\e[1;30mThe recommended minimum to install Arch Linux in Termux PRoot for x86-64 architecture is 800M of free user space.\\e[0m\\n"
fi
if [[ "$USSPACE" -lt "600" ]] && { [[ "$CPUABI" = "$CPUABIX86" ]] || [[ "$CPUABI" = i386 ]] ; }
then
SPACEMESSAGE="\\e[0;33mTermuxArch: \\e[1;33mFREE SPACE WARNING!  \\e[1;30mStart thinking about cleaning out some stuff please.  \\e[33mThere is only $USRSPACE of free user space is available on this device.  \\e[1;30mThe recommended minimum to install Arch Linux in Termux PRoot for $CPUABI architecture is 600M of free user space.\\e[0m\\n"
fi
elif [[ "$USRSPACE" = *G ]]
then
USSPACE="${USRSPACE:; -1}"
if [[ "$CPUABI" = "$CPUABI8" ]]
then
if [[ "$USSPACE" < "1.5" ]]
then
SPACEMESSAGE="\\e[0;33mTermuxArch: \\e[1;33mFREE SPACE WARNING!  \\e[1;30mStart thinking about cleaning out some stuff please.  \\e[33mThere is only $USRSPACE of free user space is available on this device.  \\e[1;30mThe recommended minimum to install Arch Linux in Termux PRoot for aarch64 architecture is 1.5G of free user space.\\e[0m\\n"
else
SPACEMESSAGE=""
fi
elif [[ "$CPUABI" = "$CPUABI7" ]]
then
if [[ "$USSPACE" < "1.23" ]]
then
SPACEMESSAGE="\\e[0;33mTermuxArch: \\e[1;33mFREE SPACE WARNING!  \\e[1;30mStart thinking about cleaning out some stuff please.  \\e[33mThere is only $USRSPACE of free user space is available on this device.  \\e[1;30mThe recommended minimum to install Arch Linux in Termux PRoot for armv7 architecture is 1.23G of free user space.\\e[0m\\n"
else
SPACEMESSAGE=""
fi
else
SPACEMESSAGE=""
fi
else
SPACEMESSAGE="\\e[0;33mTermuxArch: \\e[1;33mFREE SPACE WARNING!  \\e[1;30mStart thinking about cleaning out some stuff please.  \\e[33mThere is only $USRSPACE of free user space is available on this device.  \\e[1;30mThe recommended minimum to install Arch Linux in Termux PRoot is more than 1.5G for aarch64, more than 1.25G for armv7, 800M for x86-64 and 600M of free user space for x86 architecture.\\e[0m\\n"
fi
}

_SPACEINFOKSIZE_() {
_USERSPACE_
if [[ "$CPUABI" = "$CPUABI8" ]]
then
if [[ "$USRSPACE" -lt "1500000" ]]
then
SPACEMESSAGE="\\e[0;33mTermuxArch: \\e[1;33mFREE SPACE WARNING!  \\e[1;30mStart thinking about cleaning out some stuff please.  There is only \\e[33m$USRSPACE $units of free user space \\e[1;30mavailable on this device.  The recommended minimum to install Arch Linux in Termux PRoot for aarch64 architecture is 1.5G of free user space.\\e[0m\\n"
else
SPACEMESSAGE=""
fi
elif [[ "$CPUABI" = "$CPUABI7" ]]
then
if [[ "$USRSPACE" -lt "1250000" ]]
then
SPACEMESSAGE="\\e[0;33mTermuxArch: \\e[1;33mFREE SPACE WARNING!  \\e[1;30mStart thinking about cleaning out some stuff please.  There is only \\e[33m$USRSPACE $units of free user space \\e[1;30mavailable on this device.  The recommended minimum to install Arch Linux in Termux PRoot for armv7 architecture is 1.25G of free user space.\\e[0m\\n"
else
SPACEMESSAGE=""
fi
elif [[ "$CPUABI" = "$CPUABIX8664" ]]
then
if [[ "$USRSPACE" -lt "800000" ]]
then
SPACEMESSAGE="\\e[0;33mTermuxArch: \\e[1;33mFREE SPACE WARNING!  \\e[1;30mStart thinking about cleaning out some stuff please.  There is only \\e[33m$USRSPACE $units of free user space \\e[1;30mavailable on this device.  The recommended minimum to install Arch Linux in Termux PRoot for x86-64 architecture is 800M of free user space.\\e[0m\\n"
else
SPACEMESSAGE=""
fi
elif [[ "$CPUABI" = "$CPUABIX86" ]] || [[ "$CPUABI" = "i386" ]]
then
if [[ "$USRSPACE" -lt "600000" ]]
then
SPACEMESSAGE="\\e[0;33mTermuxArch: \\e[1;33mFREE SPACE WARNING!  \\e[1;30mStart thinking about cleaning out some stuff please.  There is only \\e[33m$USRSPACE $units of free user space \\e[1;30mavailable on this device.  The recommended minimum to install Arch Linux in Termux PRoot for $CPUABI architecture is 600M of free user space.\\e[0m\\n"
else
SPACEMESSAGE=""
fi
fi
}

_SYSINFO_() {
_NAMESTARTARCH_
_SPACEINFO_
printf "\\e[38;5;76m"
printf "%s\\n" "Generating TermuxArch version $VERSIONID system information;  Please wait..."
_TASPINNER_ clock & _SYSTEMINFO_ ; kill $! || _PRINTERRORMSG_ "_SYSINFO_ _SYSTEMINFO_ ${0##*/} maintenanceroutines.bash"
cat "${WDIR}setupTermuxArchSysInfo$STIME".log
printf "\\n\\e[1mPlease share relevant system information along with an issue and pull request at https://github.com/TermuxArch/TermuxArch/issues and also include the input and output with information which may be quite important when planning issues at https://github.com/TermuxArch/TermuxArch/issues with the hope of improving this script, \'%s\'.\\n\\nIf you believe screenshots will help in a quicker resolution for an issue, also include them as well.  Please include the input as well as the output, along with screenshots relrevant to Xserver on Android device, and similar.\\n\\n" "${0##*/}"
exit
}

_SYSTEMINFO_ () {
printf "%s\\n" "dpkg --print-architecture result:" >> "${WDIR}setupTermuxArchSysInfo$STIME".log
dpkg --print-architecture >> "${WDIR}setupTermuxArchSysInfo$STIME".log
printf "%s\\n" "uname -a results:" >> "${WDIR}setupTermuxArchSysInfo$STIME".log
uname -a >> "${WDIR}setupTermuxArchSysInfo$STIME".log
printf "\\n" >> "${WDIR}setupTermuxArchSysInfo$STIME".log
for n in 0 1 2 3 4 5
do
printf "%s\\n" "BASH_VERSINFO[$n] = ${BASH_VERSINFO[$n]}"  >> "${WDIR}setupTermuxArchSysInfo$STIME".log
done
printf "%s\\n" "cat /proc/cpuinfo results:" >> "${WDIR}setupTermuxArchSysInfo$STIME".log
cat /proc/cpuinfo >> "${WDIR}setupTermuxArchSysInfo$STIME".log
printf "%s\\n" "getprop | grep product.cpu results:" >> "${WDIR}setupTermuxArchSysInfo$STIME".log
getprop | grep product.cpu >> "${WDIR}setupTermuxArchSysInfo$STIME".log
printf "%s\\n" "getprop | grep net\\\\. results:" >> "${WDIR}setupTermuxArchSysInfo$STIME".log
getprop | grep net\\. >> "${WDIR}setupTermuxArchSysInfo$STIME".log
printf "Further getprop results:\\n" >> "${WDIR}setupTermuxArchSysInfo$STIME".log
printf "%s %s\\n" "[getprop gsm.sim.operator.iso-country]:" "[$(getprop gsm.sim.operator.iso-country)]" >> "${WDIR}setupTermuxArchSysInfo$STIME".log
printf "%s %s\\n" "[getprop persist.sys.locale]:" "[$(getprop persist.sys.locale)]" >> "${WDIR}setupTermuxArchSysInfo$STIME".log
printf "%s %s\\n" "[getprop ro.build.target_country]:" "[$(getprop ro.build.target_country)]" >> "${WDIR}setupTermuxArchSysInfo$STIME".log
printf "%s %s\\n" "[getprop ro.build.version.release]:" "[$SYSVER(getprop ro.build.version.release)]" >> "${WDIR}setupTermuxArchSysInfo$STIME".log
printf "%s %s\\n" "[getprop ro.build.version.preview_sdk]:" "[$(getprop ro.build.version.preview_sdk)]" >> "${WDIR}setupTermuxArchSysInfo$STIME".log
printf "%s %s\\n" "[getprop ro.build.version.sdk]:" "[$(getprop ro.build.version.sdk)]" >> "${WDIR}setupTermuxArchSysInfo$STIME".log
printf "%s %s\\n" "[getprop ro.com.google.clientidbase]:" "[$(getprop ro.com.google.clientidbase)]" >> "${WDIR}setupTermuxArchSysInfo$STIME".log
printf "%s %s\\n" "[getprop ro.com.google.clientidbase.am]:" "[$(getprop ro.com.google.clientidbase.am)]" >> "${WDIR}setupTermuxArchSysInfo$STIME".log
printf "%s %s\\n" "[getprop ro.com.google.clientidbase.ms]:" "[$(getprop ro.com.google.clientidbase.ms)]" >> "${WDIR}setupTermuxArchSysInfo$STIME".log
printf "%s %s\\n" "[getprop ro.product.device]:" "[$(getprop ro.product.device)]" >> "${WDIR}setupTermuxArchSysInfo$STIME".log
printf "%s %s\\n" "[getprop ro.product.first_api_level]:" "[$(getprop ro.product.first_api_level)]" >> "${WDIR}setupTermuxArchSysInfo$STIME".log
printf "%s %s\\n" "[getprop ro.product.locale]:" "[$(getprop ro.product.locale)]" >> "${WDIR}setupTermuxArchSysInfo$STIME".log
printf "%s %s\\n" "[getprop ro.product.manufacturer]:" "[$(getprop ro.product.manufacturer)]" >> "${WDIR}setupTermuxArchSysInfo$STIME".log
printf "%s %s\\n" "[getprop ro.product.model]:" "[$(getprop ro.product.model)]" >> "${WDIR}setupTermuxArchSysInfo$STIME".log
printf "%s\\n" "Download directory information results:" >> "${WDIR}setupTermuxArchSysInfo$STIME".log
[[ -e /sdcard/Download ]] && printf "%s\\n" "/sdcard/Download exists" || printf "%s\\n" "/sdcard/Download not found" >> "${WDIR}setupTermuxArchSysInfo$STIME".log
[[ -e /storage/emulated/0/Download ]] && printf "%s\\n" "/storage/emulated/0/Download exists" || printf "%s\\n" "/storage/emulated/0/Download not found" >> "${WDIR}setupTermuxArchSysInfo$STIME".log
[[ -e "$HOME"/downloads ]] && printf "%s\\n" "$HOME/downloads exists" || printf "%s\\n" "~/downloads not found" >> "${WDIR}setupTermuxArchSysInfo$STIME".log
[[ -e "$HOME"/storage/downloads ]] && printf "%s\\n" "$HOME/storage/downloads exists" || printf "%s\\n" "$HOME/storage/downloads not found" >> "${WDIR}setupTermuxArchSysInfo$STIME".log
printf "%s\\n" "Device information results:" >> "${WDIR}setupTermuxArchSysInfo$STIME".log
[[ -e /dev/ashmem ]] && printf "%s\\n" "/dev/ashmem exists" || printf "%s\\n" "/dev/ashmem does not exist" >> "${WDIR}setupTermuxArchSysInfo$STIME".log
[[ -r /dev/ashmem ]] && printf "%s\\n" "/dev/ashmem is readable" || printf "%s\\n" "/dev/ashmem is not readable" >> "${WDIR}setupTermuxArchSysInfo$STIME".log
[[ -w /dev/ashmem ]] && printf "%s\\n" "/dev/ashmem is writable" || printf "%s\\n" "/dev/ashmem is not writable" >> "${WDIR}setupTermuxArchSysInfo$STIME".log
printf "\\n%s" "Ascertaining system information;  Please wait a moment  "
[[ -e /dev/shm ]] && printf "%s\\n" "/dev/shm exists" || printf "%s\\n" "/dev/shm does not exist" >> "${WDIR}setupTermuxArchSysInfo$STIME".log
[[ -r /dev/shm ]] && printf "%s\\n" "/dev/shm is readable" || printf "%s\\n" "/dev/shm is not readable" >> "${WDIR}setupTermuxArchSysInfo$STIME".log
[[ -e /proc/stat ]] && printf "%s\\n" "/proc/stat exits" || printf "%s\\n" "/proc/stat does not exit" >> "${WDIR}setupTermuxArchSysInfo$STIME".log
[[ -r /proc/stat ]] && printf "%s\\n" "/proc/stat is readable" || printf "%s\\n" "/proc/stat is not readable">> "${WDIR}setupTermuxArchSysInfo$STIME".log
[[ -e /sys/ashmem ]] && printf "%s\\n" "/sys/ashmmem exists" || printf "%s\\n" "/sys/ashmmem does not exist" >> "${WDIR}setupTermuxArchSysInfo$STIME".log
[[ -r /sys/ashmmem ]] && printf "%s\\n" "/sys/ashmmem is readable" || printf "%s\\n" "/sys/ashmmem is not readable" >> "${WDIR}setupTermuxArchSysInfo$STIME".log
[[ -e /sys/shm ]] && printf "%s\\n" "/sys/shm exists" || printf "%s\\n" "/sys/shm does not exist" >> "${WDIR}setupTermuxArchSysInfo$STIME".log
[[ -r /sys/shm ]] && printf "%s\\n" "/sys/shm is readable" || printf "%s\\n" "/sys/shm is not readable" >> "${WDIR}setupTermuxArchSysInfo$STIME".log
printf "\\n%s\\n" "Disk report $USRSPACE on /data $(date)" >> "${WDIR}setupTermuxArchSysInfo$STIME".log
printf "\\n%s\\n" "df $INSTALLDIR results:" >> "${WDIR}setupTermuxArchSysInfo$STIME".log
df "$INSTALLDIR" >> "${WDIR}setupTermuxArchSysInfo$STIME".log 2>/dev/null ||:
printf "\\n%s\\n\\n" "df results:" >> "${WDIR}setupTermuxArchSysInfo$STIME".log
df >> "${WDIR}setupTermuxArchSysInfo$STIME".log 2>/dev/null ||:
printf "\\n%s\\n\\n" "du -hs $INSTALLDIR results:" >> "${WDIR}setupTermuxArchSysInfo$STIME".log
du -hs "$INSTALLDIR" >> "${WDIR}setupTermuxArchSysInfo$STIME".log 2>/dev/null ||:
printf "\\n%s\\n\\n" "ls -al $INSTALLDIR results:" >> "${WDIR}setupTermuxArchSysInfo$STIME".log
ls -al "$INSTALLDIR" >> "${WDIR}setupTermuxArchSysInfo$STIME".log 2>/dev/null ||:
printf "\\n%s\\n" "This file is found at '${WDIR}setupTermuxArchSysInfo$STIME.log'." >> "${WDIR}setupTermuxArchSysInfo$STIME".log
printf "\\n%s\\e[0m\\n" "End 'setupTermuxArchSysInfo$STIME.log' version $VERSIONID system information." >> "${WDIR}setupTermuxArchSysInfo$STIME".log
}

_USERSPACE_() {
USRSPACE="$(df "$INSTALLDIR" 2>/dev/null | awk 'FNR == 2 {print $4}')"
if [[ "$USRSPACE" = "" ]]
then
USRSPACE="$(df "$INSTALLDIR" 2>/dev/null | awk 'FNR == 3 {print $3}')"
fi
}
# maintenanceroutines.bash FE
