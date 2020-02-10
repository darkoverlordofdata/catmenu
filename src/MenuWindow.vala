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
 ****************g**************************************************************/
using Xml;


public class CatMenu.MenuWindow : Gtk.ApplicationWindow {

	public static MenuWindow instance;
	public Gtk.Application app { get; construct; }
	public MenuData obmenu { get; construct; }
	public Source state = Source.CATEGORY;
	public string category_id = "";
	public string searchFor = "";
	public GenericArray<RowData> app_data;
	public GenericArray<RowData> fav_data;
	
    private Gtk.Button show_menu;
    private Gtk.Button hide_menu;
    private Gtk.Button button;

	internal MenuWindow (MenuApplication app, MenuData data) {
		Object (application: app, title: "cbmenu", obmenu: data);
		move(0,20);
		set_decorated(false);
		this.set_default_size (200, 380);
		instance = this;

        button = new Gtk.Button.with_label("Back");
        button.get_style_context().add_class ("back-button");

        button.clicked.connect( () =>{
			app.quit();
			print("click back button\n");
        });

        var go_back = new SimpleAction ("go-back", null);
        go_back.activate.connect( () => {
			app.quit();
			print("back shortcut\n");
        });
        add_action(go_back);
        app.set_accels_for_action("win.go-back", {"<Alt>Left", "Back"});


        show_menu = new Gtk.Button.with_label("Show");
        show_menu.get_style_context().add_class ("show_menu");

        show_menu.clicked.connect( () => {
			show();
			print("clicked on Show\n");
        });

        var go_show = new SimpleAction ("go-show", null);
        go_show.activate.connect( () => {
			show();
			print("action go-show\n");
        });
        add_action(go_show);
        app.set_accels_for_action("win.go-show", {"<Alt>Right"});

        hide_menu = new Gtk.Button.with_label("Hide");
        hide_menu.get_style_context().add_class ("hide_menu");

        hide_menu.clicked.connect( () => {
			hide();
			print("clicked on Hide\n"); 
        });

        var go_hide = new SimpleAction ("go-hide", null);
        go_hide.activate.connect( () => {
			hide();
			print("action go-hide\n");
        });
        add_action(go_hide);
        app.set_accels_for_action("win.go-hide", {"Escape"});


		var app_data = new GenericArray<RowData>();
		var fav_data = new GenericArray<RowData>();

		var search = new Gtk.SearchEntry();
		var notebook = new Gtk.Notebook();
		notebook.set_tab_pos(Gtk.PositionType.BOTTOM);
		notebook.set_size_request(200, 345);

		var box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
		box.pack_start(search, false, false, 0);
		box.pack_start(notebook, false, false, 0);

		var applications_list = new Gtk.ListBox();
		var applications = new Gtk.ScrolledWindow(null, null);
		applications.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC);
		applications.add(applications_list);
		notebook.append_page(applications, new Gtk.Label("Applications"));
		applications_list.set_activate_on_single_click(true);

		var favorites_list = new Gtk.ListBox();
		var favorites = new Gtk.ScrolledWindow(null, null);
		favorites.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC);
		favorites.add(favorites_list);
		notebook.append_page(favorites, new Gtk.Label("Favorites"));
		favorites_list.set_activate_on_single_click(true);

		/**
		 * Add categories to the menu:
		 * loop thru each category, and add each item to build 
		 * the next level menu. The selection filter will decide 
		 * what to show in the presentation.
		*/
		obmenu.categories.foreach((category) => { 
			applications_list.insert(new MenuCategory(app_data, category), -1);
			category.items.foreach((item) => {
				applications_list.insert(new MenuItem(app_data, item, category.id), -1);
			});
		});

		/**
		 * Add to favorites menu
		 * favorites are the top level apps on the obmenu
		 */
		 obmenu.favorites.foreach((item) => {
			favorites_list.insert(new MenuItem(fav_data, item), -1);
		});
		 
		favorites_list.row_activated.connect((row) => {
			var i = row.get_index();
			if (fav_data[i].text == "Exit") {
				Process.exit(0);
			}
			try {
				Process.spawn_command_line_async (fav_data[i].cmd);
			} catch (GLib.Error e) {
				print(@"Error: $(e.message)\n");
				critical (e.message);
			}
			state = Source.CATEGORY;
			searchFor = "";
			category_id = "";
			applications_list.invalidate_filter();
			hide();

		});
		/**
		 * Row onclick
		 */
		 applications_list.row_activated.connect((row) => {
			var i = row.get_index();

			if (app_data[i].source == Source.CATEGORY) {
				state = Source.ITEM;
				category_id = app_data[i].id;
				applications_list.invalidate_filter();
			} 
			else {
				// run the command at i
				try {
					Process.spawn_command_line_async (app_data[i].cmd);
				} catch (GLib.Error e) {
					print(@"Error: $(e.message)\n");
					critical (e.message);
				}

					// reset ui
				state = Source.CATEGORY;
				searchFor = "";
				category_id = "";
				applications_list.invalidate_filter();
				hide();
			}

		}); 

		/**
		 * Search onchange
		 */
		search.search_changed.connect(() => {
			searchFor = search.get_text();
			applications_list.invalidate_filter();
		});

		/**
		 * Filter the listbox results
		 *
		 * put all categories and items into this menu.
		 * use filter to show only entries that are appropriate for state:
		 *
		 * If no search entry:
		 *		first show categories only. Once a category is chosen.
		 *		show only items who have that category as a parent.
		 *
		 * If there is a search entry:
		 *		Show all items that match the search entry
		 */ 
		 applications_list.set_filter_func((row) => {

			var i = row.get_index();

			if (searchFor == "") {
				if (state == Source.CATEGORY) {
					if (app_data[i].source == Source.CATEGORY) return true;
					else return false;
				}
				else {
					if (app_data[i].source 	== Source.ITEM 
					 && app_data[i].id 		== category_id) return true;
					else return false;
				}
			}


			if (app_data[i].text.index_of(searchFor) >= 0) 
				return true;
			else
				return false;
		});


		add(box);

        var headerbar = new Gtk.HeaderBar();
        headerbar.get_style_context().add_class("default-decoration");
        headerbar.show_close_button = true;
        headerbar.pack_start(button);
        headerbar.pack_start(show_menu);
        headerbar.pack_start(hide_menu);
        set_titlebar(headerbar);

		show_all();

	}

	public int load(string path) {
		return 0;
	}

	public void quit() {
		Process.exit(0);
	}

 }
