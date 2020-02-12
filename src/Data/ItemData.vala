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
