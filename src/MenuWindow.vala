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
 using Xml;


public class CatMenu.MenuWindow : Gtk.ApplicationWindow {

	public static MenuWindow instance;
	public Gtk.Application app { get; construct; }
	public MenuData obmenu { get; construct; }

	private Source state = Source.CATEGORY;
	private string category_id = "";
	private string searchFor = "";
	private GenericArray<RowData> applications_data;
	private GenericArray<RowData> favorites_data;
	private GenericArray<RowData> places_data;
	
    private Gtk.Button show_menu;
    private Gtk.Button hide_menu;
	private bool is_shown = true;
	private bool in_submenu = false;

	private Gtk.ListBox applications_list;
	private Gtk.ListBox favorites_list;
	private Gtk.ListBox computer_list;
	private Gtk.ListBox preferences_list;
	
    private bool supports_alpha;
    private static string css_data = """
    * { 
		background: rgba(0, 0, 0, 0.0); 
		border-width: 0;
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
		computer_list = new Gtk.ListBox();
		preferences_list = new Gtk.ListBox();

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

		var applications_data = new GenericArray<RowData>();
		var favorites_data = new GenericArray<RowData>();
		var places_data = new GenericArray<RowData>();
		var preferences_data = new GenericArray<RowData>();

		var header = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);

		//  var iconfile = @"/var/lib/AccountsService/icons/$username";
		var user_name = GLib.Environment.get_user_name();
		var iconfile = @"/home/$user_name/.face";
		var avatar = new Granite.Widgets.Avatar.from_file (iconfile, 48);
		avatar.set_tooltip_text(user_name);
		//BUTTON_PRESS_MASK
		//button_press_event
		avatar.touch_event.connect(() => {
			print("menu touched\n");
			return false;
		});
        //  load_button.clicked.connect(() => load_images.begin());

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

		/* Applications Tab */
		var applications = new Gtk.ScrolledWindow(null, null);
		applications.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC);
		applications.add(applications_list);
		var applications_icon = new Gtk.Image.from_icon_name("start-here", Gtk.IconSize.DND);
		applications_icon.set_tooltip_text("Applications");
		notebook.append_page(applications, applications_icon);
		applications_list.set_activate_on_single_click(true);

		/* Favorites Tab */
		var favorites = new Gtk.ScrolledWindow(null, null);
		favorites.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC);
		favorites.add(favorites_list);
		var favorites_icon = new Gtk.Image.from_icon_name("emblem-favorite", Gtk.IconSize.DND);
		favorites_icon.set_tooltip_text("Favorites");
		notebook.append_page(favorites, favorites_icon);
		favorites_list.set_activate_on_single_click(true);

		/* Computer (Places) Tab */
		var computer = new Gtk.ScrolledWindow(null, null);
		computer.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC);
		computer.add(computer_list);
		var computer_icon = new Gtk.Image.from_icon_name("computer", Gtk.IconSize.DND);
		computer_icon.set_tooltip_text("Places");
		notebook.append_page(computer, computer_icon);
		computer_list.set_activate_on_single_click(true);

		/* Openbox Tab (preferences-desktop?) */
		var preferences = new Gtk.ScrolledWindow(null, null);
		preferences.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC);
		preferences.add(preferences_list);
		var preferences_icon = new Gtk.Image.from_icon_name("preferences", Gtk.IconSize.DND);
		preferences_icon.set_tooltip_text("Openbox");
		notebook.append_page(preferences, preferences_icon);
		preferences_list.set_activate_on_single_click(true);


		/**
		 * Add categories to the menu:
		 * loop thru each category, and add each item to build 
		 * the next level menu. The selection filter will decide 
		 * what to show in the presentation.
		*/
		obmenu.categories.foreach((category) => { 
			applications_list.insert(new MenuCategory(applications_data, category), -1);
			category.items.foreach((item) => {
				applications_list.insert(new MenuItem(applications_data, item, category.id), -1);
			});
		});

		/**
		 * Applications Row onclick
		 */
		applications_list.row_activated.connect((row) => {
			var i = row.get_index();

			if (applications_data[i].source == Source.CATEGORY) {
				in_submenu = true;
				state = Source.ITEM;
				category_id = applications_data[i].id;
				applications_list.invalidate_filter();
			} 
			else {
				in_submenu = false;
				try {
					Process.spawn_command_line_async (applications_data[i].cmd);
				} catch (GLib.Error e) {
					print(@"Error: $(e.message)\n");
					critical (e.message);
				}
				menu_hide();
			}
		}); 


		/**
		 * Add to favorites menu
		 * favorites are the top level apps on the obmenu
		 */
		obmenu.favorites.foreach((item) => {
			favorites_list.insert(new MenuItem(favorites_data, item), -1);
		});
		 
		/**
		 * Favorites Row onclick
		 */
		 favorites_list.row_activated.connect((row) => {
			var i = row.get_index();
			try {
				Process.spawn_command_line_async (favorites_data[i].cmd);
			} catch (GLib.Error e) {
				print(@"Error: $(e.message)\n");
				critical (e.message);
			}
			menu_hide();

		});

		computer_list.row_activated.connect((row) => {
			var i = row.get_index();
			try {
				Process.spawn_command_line_async (places_data[i].cmd);
			} catch (GLib.Error e) {
				print(@"Error: $(e.message)\n");
				critical (e.message);
			}
			menu_hide();

		});
		/**
		 * Computer (Places) menu
		 */
		computer_list.insert(new PlaceItem(places_data, "Home", @"/home/$user_name/"), -1);
		computer_list.insert(new PlaceItem(places_data, "Trash", "trash://"), -1);
		computer_list.insert(new PlaceItem(places_data, "Desktop", @"/home/$user_name/Desktop"), -1);
		computer_list.insert(new PlaceItem(places_data, "File System", "/"), -1);
		var bookmarks = File.new_for_path(@"/home/$user_name/.config/gtk-3.0/bookmarks");
		if (bookmarks.query_exists()) {
			try {
				var places = new DataInputStream (bookmarks.read ());
				string line;
				while ((line = places.read_line (null)) != null) {
					var place = line.split(" ");
					computer_list.insert(new PlaceItem(places_data, place[1], place[0]), -1);
				}				
			}
			catch (GLib.Error e) { }
		}

		/**
		 * Openbox preferences 
		 */
		//   preferences_list.insert(new PrefItem(preferences_data, "Reconfig", "openbox --reconfigure"));
		//   preferences_list.insert(new PrefItem(preferences_data, "Refresh", "obmenu-generator -d"));

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
					if (applications_data[i].source == Source.CATEGORY) return true;
					else return false;
				}
				else {
					if (applications_data[i].source 	== Source.ITEM 
					 && applications_data[i].id 		== category_id) return true;
					else return false;
				}
			}


			if (applications_data[i].text.down().index_of(searchFor.down()) >= 0) 
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
			if (MenuClient.screen_capture) {
				MenuClient.screen_capture = false;
				Process.spawn_command_line_async ("/usr/local/bin/scrot -d 1");
			}
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
