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

 public class CatMenu.ItemData : Object 
 {

	public string id 	{ get { return _id; } }
	public string label { get { return _label; } }
	public string icon 	{ get { return _icon; } }
	public string command { get { return _command; } }

	private string _id;
	private string _label;
	private string _icon;
	private string _command;

	public ItemData.from_xml(Xml.Node* node)
	{
		_id = node->get_prop("id");
		_label = node->get_prop("label");
		_icon = node->get_prop("icon");

		var first = node->first_element_child();
		_command = first->get_content();
	}
 
 }
