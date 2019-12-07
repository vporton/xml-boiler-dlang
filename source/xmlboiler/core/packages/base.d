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

module xmlboiler.core.packages.base;

import std.typecons;
import std.conv;

interface Version {
    static Version create(string v);
    // opCmp() from Object
}

interface BasePackageManaging {
    /**
    Return `isNull` if not installed.
    The version is stripped any distro-specifics. So it is "1.1.29" not "1.1.29-5".
    */
    Nullable!string determine_package_version(string packageName);
    Version createVersion(string v);
}

private int compareVersionNumbers(string a, string b) {
    import std.ascii, std.algorithm.searching, std.algorithm.comparison;

    // If not numeric, compare lexigraphically:
    if (!all!isDigit(a) || !all!isDigit(b))
        return cmp(a, b);
    else {
        immutable an = to!long(a);
        immutable bn = to!long(b);
        if (an == bn) return 0;
        return an < bn ? -1 : 1;
    }
}

int compareVersions(string a, string b) {
    import std.array;
    auto aSplit = a.split('.');
    auto bSplit = b.split('.');
    for (auto i = aSplit.front, j = bSplit.front; !aSplit.empty && !bSplit.empty; aSplit.popFront, bSplit.popFront) {
        immutable comp = compareVersionNumbers(i, j);
        if (comp != 0) return comp;
    }
    if (aSplit.empty && bSplit.empty) return 0;
    return aSplit.empty ? -1 : 1;
}

// TODO: Support for distribution-specific version comparison rules.
class UniversalVersion : Version {
    this (string _value) {
        value = _value;
    }
    alias value this;
    override int opCmp(Object other) {
        assert(other);
        return compareVersions(this, cast(UniversalVersion) other);
    }
    override string toString() { return value; }
    private string value;
}