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

import std.algorithm;
import xmlboiler.core.rdf_recursive_descent.base;
import rdf.redland.model;
import rdf.redland.node;
import rdf.redland.containers;


class ListParser : NodeParserWithError {
    private NodeParser subparser;
    this(NodeParser _subparser, ErrorMode _error) {
        super(_error);
        subparser = _subparser;
    }
    BaseParseResult parse(ParseContext parse_context, ModelWithoutFinalize model, NodeWithoutFinalize node) {
        auto items = rdfList(parse_context.world, model, node);
        import std.array;
        return createParseResult(map!(elt => subparser.parse(parse_context, model, elt))(items).array);
    }
}