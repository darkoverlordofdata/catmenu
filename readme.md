# catmenu

    I think I'm going to Catmenu
    That's really, really where I'm going to
    If I ever get out of here
    That's what I'm gonna do
    C-c-c-c-c-c Catmenu
    I think that's really where I'm going to
    If I ever get out of here
    I'm going to Catmenu

        -- apologies to Bob Seger

    I just wanted it to sort next to catlock in my project folder.


### build

    meson build --prefix=/usr
    ninja -C build
    sudo ninja -C build install

### menu presentation server

    openbox conpatible
    
    catmenu reads the menu data from ~/.config/openbox/menu.xml

    Usage:
    com.github.darkoverlordofdata.catmenu [OPTION?]

    Help Options:
    -h, --help       Show help options

    Application Options:
    --start  # start the menu server
    --stop   # stop the menu server
    --hide   # hide the menu
    --show   # show the menu
    --reload # reload the xml
    --help   # show this     

### setup

    after installation, add to openbox startup:
    
        com.github.darkoverlordofdata.catmenu --start

    click on the menu launcher to trigger:

        com.github.darkoverlordofdata.catmenu --show

    after adding or removing software:

        com.github.darkoverlordofdata.catmenu --reload

### don't menu show in taskbar
add to ~/.config/openbox/rc.xml
``` xml
<application name="com.github.darkoverlordofdata.catmenu">
<decor>false</decor>
<shade>no</shade>
<focus>yes</focus>
<desktop>all</desktop>
<layer>above</layer>
<iconic>no</iconic>
<skip_pager>no</skip_pager>
<skip_taskbar>yes</skip_taskbar>
<fullscreen>no</fullscreen>
<maximized>false</maximized>
</application>
```