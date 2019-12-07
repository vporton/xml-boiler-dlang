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

// For "X.*" at the end of version see
// https://en.wikiversity.org/wiki/Automatic_transformation_of_XML_namespaces/RDF_resource_format

// WARNING: Comparison like like y.n > x.* does not work
// (we never compare it, because x.* can be only the upper bound not lower)
class VersionWrapper(object) {
    enum Kind { specific, infinity, minusInfinity };
    private Kind kind;
    private Version version_;
    invariant { kind == Kind.specific || !version_; }

    this(Version _version_, Kind _kind = Kind.specific) {
        version_ = _version_;
        kind = _kind;
    }
    string toString() {
        immutable str = kind == infinity ? "+inf" : kind == minusInfinity ? "-inf" : version_;
        return "VersionWrapper(%s)".format(str);
    }
    override int opCmp(VersionWrapper other) {
        if (version_ == other.version_) return 0;
        if (kind == Kind.infinity) return other.kind == infinity ? 0 : 1;
        if (kind == Kind.minusInfinity) return other.kind == minusInfinity ? 0 : -1; // never met in practice but check for completeness
        // x.* > x.n is the only special case for .*
        // (we never compare like y.n > x.*)
        if (version_ == other.version_) // encompasses the case if both end with .*
            return 0;
        // Check the only special case when both start with the same prefix
        if (kind == Kind.specific && version_[$-2..$] == ".*" &&
            other.version_.startsWith(version_[$..$-2] ~ '.')
        )
            return 1;
        immutable version2 = version_[$-2..$] == ".*" ? version_[$..$-2] : version_;
        return new UniversalVersion(version2).cmp(other.version_); // FIXME: UniversalVersion here is wrong.
    }
}

// TODO
//def version_wrapper_create(version_class):
//    def inner(version):
//        return VersionWrapper(version_class, version)
//    return inner