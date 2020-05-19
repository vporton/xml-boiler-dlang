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

module xmlboiler.core.graph.connect;

import xmlboiler.core.graph.relation;

GraphT transitive_closure(GraphT)(GraphT graph) {
    while (true) {
        immutable GraphT result = union_(graph, square(graph));
        if (result == graph) return result;
        graph = result;
    }
}

class Connectivity(T) {
    BinaryRelation!T connectivity = new BinaryRelation!T();
    bool is_connected(T src, T dst) {
        return src == dst || connectivity.adjanced(src, dst);
    }
    void add_relation(BinaryRelation!T relation) {
        connectivity = transitive_closure(union_(connectivity, relation));
    }
}