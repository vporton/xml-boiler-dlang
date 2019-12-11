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

module xmlboiler.core.rdf_recursive_descent.base;

import struct_params;
import pure_dependency.providers;
import rdf.redland.world;
import rdf.redland.model;
import rdf.redland.node;
import xmlboiler.core.execution_context;

/**
Some people say that exceptions for control flow are bad. Some disagree.

Victor Porton finds that doing this without exceptions is somehow cumbersome and may be error-prone.
*/
class BaseParseException : Exception {
    this(string msg, string file = __FILE__, size_t line = __LINE__) {
        super(msg, file, line);
    }
}

class ParseException : BaseParseException {
    this(string msg, string file = __FILE__, size_t line = __LINE__) {
        super(msg, file, line);
    }
}

class FatalParseException : BaseParseException {
    this(string msg, string file = __FILE__, size_t line = __LINE__) {
        super(msg, file, line);
    }
}

enum ErrorMode { IGNORE, WARNING, FATAL }

class ParseContext {
    ExecutionContext execution_context;
    RedlandWorldWithoutFinalize world;
    this(ExecutionContext _execution_context, RedlandWorld _world) {
        execution_context = _execution_context;
        world = _world;
    }
    void raise(ErrorMode handler, string str, string file = __FILE__, size_t line = __LINE__) {
        raise( handler, () => str, file, line);
    }
    void raise(ErrorMode handler, string delegate() strGen, string file = __FILE__, size_t line = __LINE__) {
        switch (handler) {
            case ErrorMode.IGNORE:
                throw new ParseException("Non-fatal parse exception", file, line); // By the sound logic should be no exception msg, but so.
            case ErrorMode.WARNING:
                immutable str = strGen();
                execution_context.logger.warning(str);
                throw new ParseException(str, file, line);
            case ErrorMode.FATAL:
                immutable str = strGen();
                execution_context.logger.error(str);
                throw new FatalParseException(str, file, line);
            default:
                assert(0);
        }
    }

    // to shorten code
    string translate(string str) {
        return execution_context.translations.gettext(str);
    }
}

interface BaseParseResult { }

class ParseResult(T): BaseParseResult {
    private T m_value;
    this(T _value) {
        m_value = _value;
    }
    alias m_value this;
    @property ref T value() { return m_value; }
}

ParseResult!T createParseResult(T)(T value) {
    return new ParseResult!T(value);
}

ParseResult!T createParseResult(T)(ref T value) {
    return new ParseResult!T(value);
}

/**
Parses a node of RDF resource (and its "subnodes").

Usually NodeParser and Predicate parser call each other (as in mutual recursion)

WARNING: Don't use this parser to parse recursive data structures,
because it may lead to infinite recursion on circular RDF.
*/
interface NodeParser { // TODO: Should it be interface
    BaseParseResult parse(ParseContext parse_context, ModelWithoutFinalize model, NodeWithoutFinalize node);
}

/**
Parses a given predicate (which may participate in several relationships)
of a given RDF node.

Usually NodeParser and Predicate parser call each other (as in mutual recursion)
*/
class PredicateParser {
    NodeWithoutFinalize predicate;
    this(NodeWithoutFinalize _predicate) {
        predicate = _predicate;
    }
    abstract BaseParseResult parse(ParseContext parse_context, ModelWithoutFinalize model, NodeWithoutFinalize node);
}

abstract class NodeParserWithError : NodeParser {
    ErrorMode on_error;
    this(ErrorMode _on_error) {
        on_error = _on_error;
    }
}

class PredicateParserWithError : PredicateParser {
    ErrorMode on_error;
    this(NodeWithoutFinalize predicate, ErrorMode _on_error) {
        super(predicate);
        on_error = _on_error;
    }
}

// TODO: after execution_context_builders.d
//mixin StructParams!("ParseContextParams", ExecutionContext, "execution_context");
//immutable ParseContextParams.WithDefaults parseContextDefaults = { execution_context: Contexts.execution_context };
//alias MyProvider = ProviderWithDefaults!(Callable!(c => ParseContext(c)), ParseContextParams, parseContextDefaults);
//auto default_parse_context = new MyProvider();