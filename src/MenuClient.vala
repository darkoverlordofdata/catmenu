/* ******************************************************************************
 * Copyright 2020 darkoverlordofdata.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 2.1 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 *
 ******************************************************************************/
/**
 * Menu Client Application
 */
public class CatMenu.MenuClient : GLib.Object 
{
    /**
     * Command line
     * 
     *  Usage:
     *  com.github.darkoverlordofdata.cbmenu [OPTION?]
     *
     *  Help Options:
     *  -h, --help       Show help options
     *
     *  Application Options:
     *  --start  # start the menu server
     *  --stop   # stop the menu server
     *  --hide   # hide the menu
     *  --show   # show the menu
     *  --reload # reload the xml
     *  --help   # show this     
     *
     */
     const OptionEntry[] options = {
		{ "start", 0, 0, OptionArg.NONE, ref server_start, "Start the menu server", null },
		{ "stop", 0, 0, OptionArg.NONE, ref server_stop, "Stop the menu server", null },
		{ "hide", 0, 0, OptionArg.NONE, ref menu_hide, "Hide the menu", null },
		{ "show", 0, 0, OptionArg.NONE, ref menu_show, "Show the menu", null },
		{ "reload", 0, 0, OptionArg.NONE, ref menu_reload, "Reload xml", null },
		{ "scrot", 0, 0, OptionArg.NONE, ref screen_capture, "Screen capture", null },
		{ null }
    };

    public static bool server_start;
    public static bool server_stop;
    public static bool menu_hide;
    public static bool menu_show;
    public static bool menu_reload;
    public static bool screen_capture;
    private Menu server = null;
    private int res = -1;

    /**
     * 
     * com.github.darkoverlordofdata.cbmenu
     */
    public MenuClient() 
    {
        try {
            server = Bus.get_proxy_sync (BusType.SESSION, 
                                            "com.darkoverlordofdata.catmenu",
                                            "/com/darkoverlordofdata/catmenu");
        } catch (IOError e) {
            stderr.printf ("%s\n", e.message);
        }
    }

    public static int main(string[] args)
    {
        MenuClient client = null;
        /** get flags & options */
		try {
            var opt_context = new OptionContext();
            opt_context.set_help_enabled(true);
			opt_context.add_main_entries(options, null);
            opt_context.parse(ref args);
		} catch (OptionError e) {
			print("error: %s\n", e.message);
			print("Run '%s --help' to see a full list of available command line options.\n", args[0]);
            critical (e.message);
			return 0;
        }

        /** 
         * Start the server
         */ 
        if (server_start) {

            Bus.own_name (BusType.SESSION, "com.darkoverlordofdata.catmenu", 
                            BusNameOwnerFlags.NONE,
                            on_bus_aquired,
                            () => {},
                            () => stderr.printf ("Could not aquire name\n"));

            return new CatMenu.MenuApplication ().run (args);

        }

        /** 
         *  Stop the service
         */ 
        if (server_stop) {
            client = new MenuClient();
            return client.quit();
        }

        /** 
         * Show the menu
         */ 
        if (menu_show) {
            client = new MenuClient();
            return client.show();
        }

        /** 
         * Hide the menu
         */ 
        if (menu_hide) {
            client = new MenuClient();
            return client.hide();
        }

        /** 
         * Reload menu data
         */ 
        if (menu_reload) {
            client = new MenuClient();
            return client.reload("menu.xml");
        }

        print("Run '%s --help' to see a full list of available command line options.\n", args[0]);
        return 0;
    }

    private int quit() {
        try {
            res = server.quit();
        } catch (Error e) {
            if (e is DBusError.NO_REPLY) {
                /* 
                 * we executed Process.exit(0), so just ignore this 
                 */
                stderr.printf("OK: Message recipient disconnected from message bus without replying.\n");
            }
            else {
                stderr.printf("%s\n", e.message);
            }
        }
        return res;
    }
    private int show() {
        try {
            res = server.show();
        } catch (Error e) {
            stderr.printf("%s\n", e.message);
        }
        return res;
    }
    private int hide() {
        try {
            res = server.hide();
        } catch (Error e) {
            stderr.printf("%s\n", e.message);
        }
        return res;
    }
    private int reload(string path) {
        try {
            res = server.load(path);
        } catch (Error e) {
            stderr.printf("%s\n", e.message);
        }
        return res;
    }

}
