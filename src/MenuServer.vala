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

