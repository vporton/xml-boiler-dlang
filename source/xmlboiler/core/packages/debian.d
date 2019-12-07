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

module xmlboiler.core.packages.debian;

import std.algorithm;
import std.exception;
import std.regex;
import std.process;
import xmlboiler.core.packages.base;


class DebianPackageManaging : BasePackageManaging {
    // TODO: Unittest.
    static dstring determine_package_version(string package_name) {
        enforce(!package_name.canFind(' ')); // FIXME: Check also for no special chars.

        auto pipes = pipeProcess("dpkg " ~ package_name, Redirect.stdout);
        // TODO: Suboptimal efficiency:
        import std.array;
        immutable dstring text = cast(dstring) pipes.stdout.byLine.joiner.array;
        auto m = matchFirst(text, regex("^Version: (.*)"d));
        if (!m) return null;
        dstring version_ = m.front;
        // https://www.debian.org/doc/debian-policy/#s-f-version
        version_ = matchFirst(version_, r"^([0-9]+:)?(.*)(-[a-zA-Z0-9+.~]+)?$"d)[2];
        return version_;
    }

    static Version createVersion(string v) {
        return new VersionClass(v);
    }

    alias VersionClass = UniversalVersion;
}