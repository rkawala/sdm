#!/bin/bash                                                                                                                                                               

function copyif() {
    local fl=$1 od=$2
    if [ -f $fl ]
    then
        odfl="$od/$(basename $fl)"
        if [ -f $odfl ]
        then
            if [ $fl -nt $odfl ]
            then
                echo "Copy $fl to $od"
                cp -a $fl $od
            fi
        else
            echo "Copy $fl to $od"
            cp -a $fl $od
        fi
    else
        echo "$fl does not exist. Is this a problem?"
    fi
}

[ $EUID -ne 0 ] && echo "? Script must run as root" && exit

srcdir="$1"
[ "$srcdir" == "" ] && echo "? Usage: $0 /path/to/sdm/sources" && exit

mkdir -p /usr/local/sdm/{1piboot,plugins,local-plugins}
for f in sdm sdm-readparams sdm-apps-example sdm-apt sdm-apt-cacher sdm-cparse sdm-rpcsubs sdm-cryptconfig sdmcryptfs sdm-cportal sdm-customphase sdm-firstboot sdm-logms\
g sdm-phase0 sdm-phase1 sdm-cmdsubs sdm-spawn sdm-gburn sdm-make-luks-usb-key sdm-add-luks-key sdm-ssh-initramfs sdm-collect-labwc-config completion.sd\
m sdm-yubi-config
do
    copyif $srcdir/$f /usr/local/sdm
done

for f in 1piboot.conf
do
    copyif $srcdir/1piboot/$f /usr/local/sdm/1piboot
done

for f in apps apt-addrepo apt-cacher-ng apt-config apt-file bootconfig btwifiset chrony clockfake cloudinit cmdline copydir copyfile cryptroot \
              disables docker-install dovecot-imap explore extractfs gadgetmode git-clone graphics hotspot imon knockd \
              L10n labwc logwatch lxde mkdir modattr ndm network parted piapps pistrong postburn postfix quietness \
              raspiconfig runatboot runscript rxapp samba sdm-plugin-template serial sshd sshhostkey sshkey speedtest swap syncthing system trim-enable \
              ufw update-alternatives user venv vnc wificonfig wireguard wsdd sdm.phaseops
do
    copyif $srcdir/plugins/$f /usr/local/sdm/plugins
done

copyif $srcdir/mysdm /usr/local/bin

[ -L /usr/local/bin/sdm ] || ln -s /usr/local/sdm/sdm /usr/local/bin/sdm
chown -R root:root /usr/local/sdm/*
chmod 755 /usr/local/sdm/sdm*
chmod 755 /usr/local/sdm/plugins/*
