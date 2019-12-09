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

/**
Directed graph with at most one edge between vertices
*/
class BinaryRelation(Vertex) {
    private RedBlackTree!Vertex[Vertex] adj;
    /**
    :param adj: a dict from vertice to vertex set
    */
    this(RedBlackTree!Vertex[Vertex] _adj=null) {
        adj = _adj;
    }
    bool opEqual(BinaryRelation!Vertex other) {
        return adj == other.adj;
    }
    override nothrow @trusted size_t toHash() {
        return adj.hashOf();
    }
    void add_edge(Vertex src, Vertex dst) {
        value = adj.get( src, null);
        if (value is null)
            adj[src] = redBlackTree( dst);
        else
            value.insert( dst);
    }
    bool adjanced(Vertex src, Vertex dst) {
        s = adj.get( src, null);
        if (s is null) return false;
        return s.contains( dst);
    }
    BinaryRelation!Vertex reverse() {
        auto result = new BinaryRelation!Vertex();
        foreach (pair; adj.byPair)
            foreach (y; pair.value)
                result.add_edge( y, pair.key);
        return result;
    }

    alias KeyFunction = Vertex delegate(Vertex);

    RedBlackTree!Vertex maxima(Elements)(Elements elements, KeyFunction key = v => v) {
        auto s = redBlackTree( elements);
        auto were_changes = true;
        while (were_changes) {
            were_changes = false;
            foreach (e; s) {
                if (adj[key( e)]) {
                    s.remove( e);
                    were_changes = true;
                }
            }
        }
        return s;
    }
}

//# class UniversalSet(object):
//#     def __contains__(self, item):
//#         return True
//#
//#     def __eq__(self, other):
//#         return other is UniversalSet
//#
//#     def __hash__(self):
//#         return 0xadd93fbf4230655a  # was randomly generated
//#
//#     def append(self, value):
//#         pass
//#
//#     # Enumeration deliberately not implemented
//#     # (It is not used in our algorithm when the set of targets is universal,
//#     # because in this case we have already reached the destination namespace.)
//#
//#
//# class BinaryRelationWithUniversalDestination(BinaryRelation):
//#     """
//#     Like binary relation but with possibility to map a source element into
//#     universal set of destinations.
//#     """
//#
//#     def add_universal_destination(self, src):
//#         self.adj[src] = UniversalSet()

/**
Note order of arguments!
*/
BinaryRelation!T compose(T)(BinaryRelation!T b, BinaryRelation!T a) {
    auto result = new BinaryRelation!T();
    foreach (pair; a.adj.byPair())
        foreach (y; pair.value) {
            s2 = b.adj.get( y, None);
            if (s2 !is null)
                foreach (z; s2)
                    result.add_edge( pair.key, z);
        }
    return result;
}

BinaryRelation!T square(T)(BinaryRelation!T graph) {
    return compose(graph, graph);
}

BinaryRelation!T union_(T)(BinaryRelation!T a, BinaryRelation!T b) {
    auto source = redBlackTree();
    source.insert(a.adj.keys());
    source.insert(b.adj.keys());
    RedBlackTree!Vertex[Vertex] adj;
    foreach (x; source) {
        setA = a.adj.get(x, null);
        setB = b.adj.get(x, null);
        if (a !is null || b !is null) {
            auto s = redBlackTree();
            if (setA !is null)
                s |= setA;
            if (setB !is null)
                s |= setB;
            adj[x] = s;
        }
    }
    return new BinaryRelation!T(adj);
}