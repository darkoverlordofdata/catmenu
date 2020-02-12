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
[DBus (name = "com.darkoverlordofdata.catmenu")]
interface Menu : Object {
   public abstract int load(string msg) throws GLib.Error;
   public abstract int show() throws GLib.Error;
   public abstract int hide() throws GLib.Error;
   public abstract int quit() throws GLib.Error;
}

[DBus (name = "com.darkoverlordofdata.catmenu")]
public class MenuServer : Object {

   	public int load(string msg) throws GLib.Error {
		return CatMenu.MenuWindow.instance.menu_load(msg);
   }

	public int show() throws GLib.Error{
		CatMenu.MenuWindow.instance.menu_show();
		return 0;
	}

	public int hide() throws GLib.Error{
		CatMenu.MenuWindow.instance.menu_hide();
		return 0;
	}

	public int quit() throws GLib.Error{
		CatMenu.MenuWindow.instance.menu_quit();
		return 0;
	}
}

void on_bus_aquired (DBusConnection conn) {
	try {
		conn.register_object ("/com/darkoverlordofdata/catmenu", new MenuServer ());
	} catch (IOError e) {
		stderr.printf ("Could not register service\n");
	}
}

