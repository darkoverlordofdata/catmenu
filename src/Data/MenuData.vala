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
 * Load the openbox menu.xml:
 *
 * 	<menu ... label="category">
 *		<item ... label="desc" icon="*.png">
 *			<action ... name="Execute">
 *				<command><![CDATA[...]]</command></action></item></menu>
 *
 */ 

public class CatMenu.MenuData : Object
{
    string menuPath = @"$(Environment.get_user_config_dir())/openbox/menu.xml";

    public GenericArray<CategoryData> categories { get { return _categories; }}
    public GenericArray<ItemData> favorites { get { return _favorites; }}

    private GenericArray<CategoryData> _categories;
    private GenericArray<ItemData> _favorites;
    
    public MenuData() {

        _categories = new  GenericArray<CategoryData>();
        _favorites = new  GenericArray<ItemData>();

        print("%s\n", to_string());
        try {
            loadMenuXml();
        }
        catch (Error e) {
            print("%s\n", e.message);
        }
    }
  
    private void loadMenuXml() throws Exception {
        //  var menuSource = @"$(Environment.get_user_config_dir())/openbox/menu.xml";
        uint8[] src;
        try {
            FileUtils.get_data(menuPath, out src);
        }
        catch (FileError e) {
            print("%s\n", e.message);
            return;
        }

        var doc = Xml.Parser.parse_doc((string)src);
        if (doc == null) {
            throw new Exception.XmlParser("Invalid xml document");
        }
        var root = doc->get_root_element();
        if (root == null) {
            delete doc;
            throw new Exception.XmlParser("Root mode not found in xml");
        }
        if (root->name != "openbox_menu") {
            throw new Exception.XmlParser(@"Openbox Menu not found, $(root->name) found instead");
        }

        for (var node = root->children; node != null; node = node->next) {
            var id = node->get_prop("id");
            if (id == "root-menu") {
                loadRootMenu(node);
            }
        }
	}

	/**
	 * Load the top level menu nodes
	 */
	private void loadRootMenu(Xml.Node* root_menu) {

		for (var node = root_menu->children; node != null; node = node->next) {
			switch (node->name) {
                case "item": 
                    _favorites.add(new ItemData.from_xml(node));
					break;
				case "menu": 
					loadSubMenu(node);
					break;
				case "separator": 	// ignore
					break;
				default: break;		// ignore

			}
		}
	}

	/**
	 * Load the sub-menu nodes
	 */
	 private void loadSubMenu(Xml.Node* sub_menu) {

        var category = new CategoryData.from_xml(sub_menu);
        _categories.add(category);
        
		print("submenu %s\n", category.label);
		for (var node = sub_menu->children; node != null; node = node->next) {
			switch (node->name) {
                case "item": 
                    var n = category.add_item(node);
                    print("(%s) - %s\n", n.label, n.command);
					break;
				case "menu": 
					break;
				case "separator": 	// ignore
					break;
				default: break;		// ignore

			}
		}
	}

    /**
    * String representation of current node
    */
    public string to_string() {
      return "MenuData: %s".printf(menuPath);
    }
}