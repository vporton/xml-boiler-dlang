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

import std.conv;
import std.format;
import rdf.redland.model;
import rdf.redland.node;
import rdf.redland.uri;
import xmlboiler.core.rdf_recursive_descent.base;

class IRILiteral : NodeParserWithError {
    this(ErrorMode _on_error) {
        super(_on_error);
    }
    ParseResult!URIWithoutFinalize parse(ParseContext parse_context, ModelWithoutFinalize model, NodeWithoutFinalize node) {
        if (node.isResource)
            return new ParseResult!URIWithoutFinalize(node.uri);
        else {
            parse_context.raise(on_error, () => parse_context.translate( "Node %s should be an IRI.").format(node));
            assert(0);
        }
    }
}

class StringLiteral : NodeParserWithError {
    this(ErrorMode _on_error) {
        super(_on_error);
    }
    ParseResult!string parse(ParseContext parse_context, ModelWithoutFinalize model, NodeWithoutFinalize node) {
        // TODO: xsd:normalizedString is not supported
        if (!node.isLiteral || node.datatypeURI.handle)
            parse_context.raise(on_error, () => parse_context.translate("Node %s is not a string literal.").format(node));
        return new ParseResult!string(node.toString);
    }
}

class BooleanLiteral : NodeParserWithError {
    this(ErrorMode _on_error) {
        super(_on_error);
    }
    ParseResult!bool parse(ParseContext parse_context, ModelWithoutFinalize model, NodeWithoutFinalize node) {
        if (!node.isLiteral || node.datatypeURI != URI.fromString(parse_context.world, "http://www.w3.org/2001/XMLSchema#boolean"))
            parse_context.raise(on_error,
                                () => parse_context.translate("Node {node} is not a boolean literal.").format(node));
        return new ParseResult!bool(node.toString == "true" || node.toString == "1");
    }
}

class IntegerLiteral : NodeParserWithError {
    this(ErrorMode _on_error) {
        super(_on_error);
    }
    ParseResult!long parse(ParseContext parse_context, ModelWithoutFinalize model, NodeWithoutFinalize node) {
        import std.range;
        if (node.isLiteral && node.datatypeURI != URI.fromString(parse_context.world, "http://www.w3.org/2001/XMLSchema#integer") &&
                !node.toString.empty && node.toString[0] != ' ' && node.toString[$-1] != ' ')
            try {
                return new ParseResult!long(to!long(node.toString));
            }
            catch (ConvException) { }
        parse_context.raise(on_error, () => parse_context.translate("Node %s is not an integer literal.").format(node));
        assert(0);
    }
}

class FloatLiteral : NodeParserWithError {
    this(ErrorMode _on_error) {
        super(_on_error);
    }
    ParseResult!double parse(ParseContext parse_context, ModelWithoutFinalize model, NodeWithoutFinalize node) {
        import std.algorithm;
        auto types = map!(s => URI.fromString(parse_context.world, "http://www.w3.org/2001/XMLSchema#" ~ s))(
            [ "integer", "float", "double", "decimal" ]
        );
        if (node.isLiteral && types.canFind(node.datatypeURI)) {
            try {
                return new ParseResult!double( to!double( node.toString));
            }
            catch (ConvException) { }
        }
        parse_context.raise( on_error, () => parse_context.translate( "Node %s is not a float literal.").format( node));
        assert(0);
    }
}