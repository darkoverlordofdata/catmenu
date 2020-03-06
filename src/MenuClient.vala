/* ******************************************************************************
 * Copyright 2020 bruce davidson <darkoverlordofdata@gmail.com>.
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of the <organization> nor the
 *       names of its contributors may be used to endorse or promote products
 *       derived from this software without specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
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
