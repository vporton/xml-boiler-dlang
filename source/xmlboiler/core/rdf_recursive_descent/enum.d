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

import core.exception;
import rdf.redland.model;
import rdf.redland.node;
import xmlboiler.core.base;
import xmlboiler.core.rdf_recursive_descent.base;


class EnumParser : NodeParserWithError {
    private BaseParseResult[URI] map;
    this(BaseParseResult[URI] _map, ErrorMode _on_error=ErrorMode.IGNORE) {
        super(on_error);
        map = _map;
    }
    BaseParseResult parse(ParseContext parse_context, ModelWithoutFinalize model, NodeWithoutFinalize node) {
        import std.format;
        if (!node.isResource)
            parse_context.raise(on_error, () => parse_context.translate("Node %s should be an IRI.").format(node));
        try {
            return map[*new URI(node.uri.toString)];
        }
        catch (RangeError) {
            parse_context.raise(on_error, () => parse_context.translate("The IRI %s is unknown.").format(node));
        }
        assert(0);
    }
}