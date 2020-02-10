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

public enum Source { CATEGORY, ITEM }
public class CatMenu.RowData : Object 
{
		public Source source;
		public string text;
		public string id;
		public string cmd;

		public RowData(Source source, string text, string id, string cmd = "") 
		{
			this.source = source;
			this.text = text;
			this.id = id; 
			this.cmd = cmd;
		}
}
