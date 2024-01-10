# BEGIN ANSIBLE MANAGED BLOCK
#!/bin/sh\n\nuserresources=$HOME/.Xresources\nusermodmap=$HOME/.Xmodmap\nsysresources=/etc/X11/xinit/.Xresources\nsysmodmap=/etc/X11/xinit/.Xmodmap\n\n# merge in defaults and keymaps\n\nif [ -f $sysresources ]; then\n\n\n\n\n\n\n\n    xrdb -merge $sysresources\n\nfi\n\nif [ -f $sysmodmap ]; then\n    xmodmap $sysmodmap\nfi\n\nif [ -f "$userresources" ]; then\n\n\n\n\n\n\n\n    xrdb -merge "$userresources"\n\nfi\n\nif [ -f "$usermodmap" ]; then\n    xmodmap "$usermodmap"\nfi\n\n# start some nice programs\n\nif [ -d /etc/X11/xinit/xinitrc.d ] ; then\n for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do\n  [ -x "$f" ] && . "$f"\n done\n unset f\nfi\n
~/.fehbg &
exec awesome
# END ANSIBLE MANAGED BLOCK
