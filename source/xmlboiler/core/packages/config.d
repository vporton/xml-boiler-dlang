/*
Copyright (c) 2019 Victor Porton,
XML Boiler - http://freesoft.portonvictor.org

This file is part of XML Boiler.

XML Boiler is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program. If not, see <http://www.gnu.org/licenses/>.
*/

import std.regex;
import distro;
import xmlboiler.core.packages.base;

alias DeterminePackageVersion = dstring function(string package_name);

DeterminePackageVersion determine_os() {
    if (distro.id == "debian" || matchFirst(distro.like, regex(r"\bdebian\b"d))) {
        import xmlboiler.core.packages.debian;
        return &DebianPackageManaging.determine_package_version;
    }
    return null;
}