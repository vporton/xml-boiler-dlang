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
:param graph:
:param path: a list of nodes
:param weight: a function
:return: a list of lists of edges
*/
Edge[][] shortest_path_to_edges(Graph, Vertex, Edge)(Graph graph, Vertex[] path, real delegate(Edge) weight) {
    Edge[][] result;
    foreach(i; 0 .. path.length) {
        real last_weight = infinity;
        Edge[] last_edges;

        foreach(e; edgesBetween(path[i], path[i + 1])) {
            real new_weight = weight(e);
            if (new_weight < last_weight)
                last_edges = [];
            if (new_weight <= last_weight) {
                last_weight = new_weight;
                last_edges.append(e);
            }
        }
        result.append(last_edges);
    }
    return result;
}

/**
:param graph:
:param paths: a list of lists of nodes
:param weight: a function
:return: a list of lists of edges
*/
Edge[][] shortest_paths_to_edges(Graph, Vertex, Edge)(Graph graph, Vertex[][] paths, real delegate(Edge) weight) {
    Edge[][] result;
    real last_weight = infinity;
    foreach (path; paths) {
        Edge[][] new_lists_of_edges = shortest_path_to_edges(graph, path, weight);
        foreach(new_edges; new_lists_of_edges) {
            import std.algorithm.iteration;
            immutable real new_weight = reduce!((a,b) => a + b)(0, map!weight(new_edges));
            if (new_weight < last_weight) result = [];
            if (new_weight <= last_weight) {
                last_weight = new_weight;
                result.append(new_edges);
            }
        }
    }
    return result;
}

/**
:param edges: a list of lists of edges
:param weight: a function
:return: a list of lists of edges
*/
Edge[][] shortest_lists_of_edges(Edge)(Edge[][] edges, real delegate(Edge) weight) {
    Edge[][] result;
    real last_weight = infinity;
    foreach (cur_edges; edges) {
        immutable real new_weight = reduce!((a,b) => a + b)(0, map!weight(cur_edges));
        if (new_weight < last_weight)
            result = [];
        if (new_weight <= last_weight) {
            last_weight = new_weight;
            result.append( cur_edges);
        }
    }
    return result;
}