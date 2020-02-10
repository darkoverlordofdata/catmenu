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

 public class CatMenu.MenuItem : Gtk.Box 
 {
	 private Gdk.Pixbuf pic;
	 private Gtk.Image ico;
	 private Gtk.Label label;


 
	 public MenuItem(GenericArray<RowData> row_data, ItemData item, string category_id = "") 
	 {
		Object(orientation: Gtk.Orientation.HORIZONTAL, spacing: 10);

		Gtk.Image ico;
		try {
			var pic = new Gdk.Pixbuf.from_file_at_size(item.icon, 24, 24);
			ico = new Gtk.Image.from_pixbuf(pic);
		} catch (GLib.Error e) {
			ico = new Gtk.Image.from_icon_name("applications-other", Gtk.IconSize.MENU);
		}
		var label = new Gtk.Label(item.label);

		set_halign(Gtk.Align.START);
		set_margin_start(20);
		set_margin_top(5);
		set_margin_bottom(5);
		label.set_max_width_chars(20);
		label.set_ellipsize(Pango.EllipsizeMode.END);

		pack_start(ico);
		pack_start(label);

		row_data.add(new RowData(Source.ITEM, item.label, category_id, item.command));
		//  applications_list.insert(li2, -1);

	 }
 }
 