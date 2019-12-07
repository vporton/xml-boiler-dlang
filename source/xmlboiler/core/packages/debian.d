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

import std.exception;
import std.regex;
import std.process;
import xmlboiler.core.rdf_recursive_descent.base;


class DebianPackageManaging(BasePackageManaging) {
    // TODO: Unittest.
    static string determine_package_version(string package_name) {
        enforce(!package_name.contains(' ')); // FIXME: Check also for no special chars.

        auto pipes = pipeProcess("dpkg " ~ package_name, Redirect.stdout);
        auto m = matchFirst(pipes.stdout, RegExp("^Version: (.*)"));
        if (!m) return null;
        string version_ = m.front;
        // https://www.debian.org/doc/debian-policy/#s-f-version
        version_ = matchFirst(version_, r"^([0-9]+:)?(.*)(-[a-zA-Z0-9+.~]+)?$")[2];
        return version_;
    }

    alias VersionClass = UniversalVersion;
}