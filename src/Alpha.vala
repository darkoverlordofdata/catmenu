using Gtk;

int main (string[] args) {
    Gtk.init (ref args);
    var window = new AlphaDemo();
    window.destroy.connect (Gtk.main_quit);
    window.show_all ();
    Gtk.main ();
    return 0;
}

/*
 * 1 make the window background widget draw transparent.
 * 2 give everything else a css sheet
 */
class AlphaDemo : Window 
{

    bool supports_alpha;

    string css_data = """
    * { 
        background: rgba(0, 0, 0, 0.5); 
    }
    window button { 
        background: rgba(0, 0, 0, 0.5); 
    }        
    window button label { 
        background: rgba(0, 0, 0, 0.0); 
    }        
    """;

    public AlphaDemo() {
        window_position = WindowPosition.CENTER;
        set_default_size (400, 400);
        title = "Alpha Demo";
    
        set_app_paintable(true);
        draw.connect(draw_event);
        screen_changed.connect(screen_changed_event);

        set_decorated(false);
        add_events(Gdk.EventMask.BUTTON_PRESS_MASK);

        var css_provider = new CssProvider();
        css_provider.load_from_data(css_data);
        var context = new StyleContext();
        var screen = Gdk.Screen.get_default();
        context.add_provider_for_screen(screen, css_provider, 600);

        var fixed_container = new Fixed();

        var button = new Button.with_label ("Click me!");
        button.set_size_request(100, 100);
        button.clicked.connect (() => set_decorated(!get_decorated()) );
    
        fixed_container.put(button, 0, 0);
        add(fixed_container);
        screen_changed_event(null);

    
    }

    bool draw_event(Widget widget, Cairo.Context context) {
        if (supports_alpha) {
            context.set_source_rgba (0.0, 0.0, 0.0, 0.50); 
        }
        else {
            //  context.set_source_rgb (1.0, 1.0, 1.0); 
            context.set_source_rgb (0.0, 0.0, 0.0); 
        }
        context.set_operator (Cairo.Operator.SOURCE);
        context.paint ();
        return false;
    }

    void screen_changed_event(Gdk.Screen? old_screen) {
        Gdk.Screen screen = get_screen();
        Gdk.Visual visual = screen.get_rgba_visual();

        if (visual == null) {
            print("Your screen does not support alpha channels!\n");
            supports_alpha = false;
            visual = screen.get_system_visual();

        }
        else {
            print("Your screen supports alpha channels!\n");
            supports_alpha = true;

        }
        set_visual(visual);

    }
}


