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

	private Source state = Source.CATEGORY;
	private string category_id = "";
	private string searchFor = "";
	private GenericArray<RowData> app_data;
	private GenericArray<RowData> fav_data;
	
    private Gtk.Button show_menu;
    private Gtk.Button hide_menu;
	private bool is_shown = true;
	private bool in_submenu = false;

	private Gtk.ListBox applications_list;
	private Gtk.ListBox favorites_list;
	
    private bool supports_alpha;
    private static string css_data = """
    * { 
        background: rgba(0, 0, 0, 0.0); 
    }
	""";

	internal MenuWindow (MenuApplication app, MenuData data) {
		Object (application: app, title: "cbmenu", obmenu: data);

		instance = this;
        set_app_paintable(true);
        draw.connect(on_draw);
		screen_changed.connect(on_screen_changed);
		focus_out_event.connect( (e) => menu_hide() );

		move(0,20);
		set_decorated(false);
		set_default_size (200, 380);

        var css_provider = new Gtk.CssProvider();
        css_provider.load_from_data(css_data);
        var context = new Gtk.StyleContext();
        var screen = Gdk.Screen.get_default();
        context.add_provider_for_screen(screen, css_provider, 600);

		applications_list = new Gtk.ListBox();
		favorites_list = new Gtk.ListBox();

		var go_hide = new SimpleAction ("go-hide", null);
		/*
		 *  Escape Key Accelerator
		 *	backup one menu level or hide
		 */
        go_hide.activate.connect( () => {
			if (in_submenu) {
				in_submenu = false;
				is_shown = true;
				state = Source.CATEGORY;
				searchFor = "";
				category_id = "";
				applications_list.invalidate_filter();
				show();
			} 
			else {
				is_shown = false;
				state = Source.CATEGORY;
				searchFor = "";
				category_id = "";
				applications_list.invalidate_filter();
				hide();
			}
        });
        add_action(go_hide);
        app.set_accels_for_action("win.go-hide", {"Escape"});

		//emblem-favorite
		//application-x-executable

		var app_data = new GenericArray<RowData>();
		var fav_data = new GenericArray<RowData>();

		var header = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);

		//  var iconfile = @"/var/lib/AccountsService/icons/$username";
		var user_name = GLib.Environment.get_user_name();
		var iconfile = @"/home/$user_name/.face";
		var avatar = new Granite.Widgets.Avatar.from_file (iconfile, 24);
		avatar.set_tooltip_text(user_name);

		var search = new Gtk.SearchEntry();
		search.set_has_frame(false);

		header.pack_start(avatar, false, false, 0);
		header.pack_start(search, false, false, 0);


		var notebook = new Gtk.Notebook();
		notebook.set_tab_pos(Gtk.PositionType.BOTTOM);
		notebook.set_size_request(200, 350);
		notebook.set_show_border (false);

		var box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
		box.pack_start(header, false, false, 0);
		box.pack_start(notebook, false, false, 0);

		//  var applications_list = new Gtk.ListBox();
		var applications = new Gtk.ScrolledWindow(null, null);
		applications.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC);
		applications.add(applications_list);
		//  notebook.append_page(applications, new Gtk.Label("Applications"));
		notebook.append_page(applications, new Gtk.Image.from_icon_name("application-x-executable", Gtk.IconSize.DND));
		applications_list.set_activate_on_single_click(true);

		//  var favorites_list = new Gtk.ListBox();
		var favorites = new Gtk.ScrolledWindow(null, null);
		favorites.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC);
		favorites.add(favorites_list);
		//  notebook.append_page(favorites, new Gtk.Label("Favorites"));
		notebook.append_page(favorites, new Gtk.Image.from_icon_name("emblem-favorite", Gtk.IconSize.DND));
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
		 
		/**
		 * Favorites Row onclick
		 */
		 favorites_list.row_activated.connect((row) => {
			var i = row.get_index();
			try {
				Process.spawn_command_line_async (fav_data[i].cmd);
			} catch (GLib.Error e) {
				print(@"Error: $(e.message)\n");
				critical (e.message);
			}
			menu_hide();

		});

		/**
		 * Applications Row onclick
		 */
		 applications_list.row_activated.connect((row) => {
			var i = row.get_index();

			if (app_data[i].source == Source.CATEGORY) {
				in_submenu = true;
				state = Source.ITEM;
				category_id = app_data[i].id;
				applications_list.invalidate_filter();
			} 
			else {
				in_submenu = false;
				try {
					Process.spawn_command_line_async (app_data[i].cmd);
				} catch (GLib.Error e) {
					print(@"Error: $(e.message)\n");
					critical (e.message);
				}
				menu_hide();
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
		 * Filter the listbox results, ignore case
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


			if (app_data[i].text.down().index_of(searchFor.down()) >= 0) 
				return true;
			else
				return false;
		});

		add(box);

        var headerbar = new Gtk.HeaderBar();
        headerbar.get_style_context().add_class("default-decoration");
        headerbar.show_close_button = true;
        set_titlebar(headerbar);
		on_screen_changed(null);
		show_all();

	}

	/* 
	 * Load menu data
	 */
	 public int menu_load(string path) {
		return 0;
	}

	/* 
	 * Show menu
	 */
	 public void menu_show() {
		if (is_shown) {
			menu_hide();
		} 
		else {
			is_shown = true;
			show();
		}
	}

	/* 
	 * Hide menu
	 */
	 public bool menu_hide() {
		is_shown = false;
		state = Source.CATEGORY;
		searchFor = "";
		category_id = "";
		applications_list.invalidate_filter();
		favorites_list.invalidate_filter();
		hide();
		return false;
	}

	/* 
	 * Quit
	 */
	 public void menu_quit() {
		Process.exit(0);
	}


	/* 
	charcoal = .2, .2, .2
	choc .247, 0, .058 (3f 00 0f)

	/usr/local/bin/dsblogoutmgr -l close_session
	ch

	 * Set cairo to use alpha channel
	 */
    bool on_draw(Gtk.Widget widget, Cairo.Context context) {
        if (supports_alpha) {
            //  context.set_source_rgba (0.156, 0.156, 0.156, 0.58); 
            context.set_source_rgba (0.2, 0.2, 0.2, 0.69); 
        }
        else {
            //  context.set_source_rgb (1.0, 1.0, 1.0); 
            context.set_source_rgb (0.0, 0.0, 0.0); 
        }
        context.set_operator (Cairo.Operator.SOURCE);
        context.paint ();
        return false;
	}
	
	/* 
	 * detect alpha
	 */
	 void on_screen_changed(Gdk.Screen? old_screen) {
        Gdk.Screen screen = get_screen();
        Gdk.Visual visual = screen.get_rgba_visual();

        if (visual == null) {
            //  print("Your screen does not support alpha channels!\n");
            supports_alpha = false;
            visual = screen.get_system_visual();

        }
        else {
            //  print("Your screen supports alpha channels!\n");
            supports_alpha = true;

        }
        set_visual(visual);

    }

 }
