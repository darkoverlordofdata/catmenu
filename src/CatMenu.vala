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
using Config;
namespace CatMenu { 

    errordomain Exception {
        XmlParser,
        //  JsonParser,
    }
        
    public const string APPLICATION_ID =   "com.github.darkoverlordofdata.catmenu";
    public const string APPLICATION_URI = "/com/github/darkoverlordofdata/catmenu";
    public const string DATADIR = Config.DATADIR;
    public const string PKGDATADIR = Config.PKG_DATADIR;
    public const string GETTEXT_PACKAGE = Config.GETTEXT_PACKAGE;
    public const string INSTALL_PREFIX = Config.PREFIX;
    public const string EXEC_NAME = Config.PACKAGE;
    public const string ICON_NAME = Config.PACKAGE;
    public const string LOCALE_DIR = Config.LOCALE_DIR;
    public const string VERSION = Config.VERSION;
    public const string APP_NAME = "CatMenu";
    public const string VERSION_INFO = "Dev";
    public const string RELEASE = "dev";

}
