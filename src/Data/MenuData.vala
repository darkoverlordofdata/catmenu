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
        /* for now, ignore openbox settings  */
        if (category.label == "Places") return;
        if (category.label == "Advanced Settings") return;
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