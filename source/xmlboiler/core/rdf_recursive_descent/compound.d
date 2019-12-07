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
import std.array;
import std.format;
import rdf.redland.model;
import rdf.redland.node;
import rdf.redland.node_iterator;
import xmlboiler.core.rdf_recursive_descent.base;


class PostProcessNodeParser : NodeParser {
    private BaseParseResult delegate(const BaseParseResult) f;
    private NodeParser child;
    this(NodeParser _child, BaseParseResult delegate(const BaseParseResult) _f) {
        child = _child;
        f = _f;
    }
    override BaseParseResult parse(ParseContext parse_context, ModelWithoutFinalize model, NodeWithoutFinalize node) {
        return f(child.parse(parse_context, model, node));
    }
}

class PostProcessPredicateParser : PredicateParser {
    private BaseParseResult delegate(const BaseParseResult) f;
    PredicateParser child;
    this(PredicateParser _child, NodeWithoutFinalize _predicate, BaseParseResult delegate(const BaseParseResult) _f) {
        super(predicate);
        child = _child;
        f = _f;
    }
    override BaseParseResult parse(ParseContext parse_context, ModelWithoutFinalize model, NodeWithoutFinalize node) {
        return f(child.parse(parse_context, model, node));
    }
}

class CheckedNodeParser : NodeParserWithError {
    private bool delegate(const BaseParseResult) f;
    private NodeParser child;
    private string error_msg;
    this(NodeParser _child, bool delegate(const BaseParseResult) _f, ErrorMode _on_error, string _error_msg) {
        super(on_error);
        child = _child;
        f = _f;
        error_msg = _error_msg;
    }
    BaseParseResult parse(ParseContext parse_context, ModelWithoutFinalize model, NodeWithoutFinalize node) {
        auto v = child.parse(parse_context, model, node);
        if (!f(v)) parse_context.raise(on_error, error_msg);
        return v;
    }
}

class CheckedPredicateParser : PredicateParserWithError {
    private bool delegate(const BaseParseResult) f;
    private PredicateParser child;
    private string error_msg;
    this(PredicateParser _child, NodeWithoutFinalize predicate, bool delegate(const BaseParseResult) _f, ErrorMode _on_error, string _error_msg) {
        super(predicate, on_error);
        child = _child;
        f = _f;
        error_msg = _error_msg;
    }
    override BaseParseResult parse(ParseContext parse_context, ModelWithoutFinalize model, NodeWithoutFinalize node) {
        auto v = child.parse(parse_context, model, node);
        if (!f(v)) parse_context.raise(on_error, error_msg);
        return v;
    }
}

class Choice : NodeParserWithError {
    private NodeParser[] choices;
    this(NodeParser[] _choices, ErrorMode on_error=ErrorMode.IGNORE) {
        super(on_error);
        choices = _choices;
    }
    BaseParseResult parse(ParseContext parse_context, ModelWithoutFinalize model, NodeWithoutFinalize node) {
        foreach(p; choices) {
            try {
                return p.parse(parse_context, model, node);
            }
            catch(ParseException) { }
        }
        string s() {
            return parse_context.translate("No variant for node %s.").format(node);
        }
        parse_context.raise(on_error, s);
        assert(0);
    }
}

class ZeroOrMorePredicate : PredicateParser {
    private NodeParser child;
    this(NodeWithoutFinalize _predicate, NodeParser _child) {
        super(predicate);
        child = _child;
    }
    override ParseResult!(BaseParseResult[]) parse(ParseContext parse_context, ModelWithoutFinalize model, NodeWithoutFinalize node) {
        auto iter = model.getTargets(node, predicate);
        auto result = map!(elt => child.parse(parse_context, model, elt))(cast(NodeIteratorWithoutFinalize) iter);
        return new ParseResult!(BaseParseResult[])(result.array); // TODO: Use a range.
    }
}

class OneOrMorePredicate : PredicateParserWithError {
    private NodeParser child;
    this(NodeWithoutFinalize _predicate, NodeParser _child, ErrorMode _on_error) {
        super( _predicate, _on_error);
        child = _child;
    }
    override ParseResult!(BaseParseResult[]) parse(ParseContext parse_context, ModelWithoutFinalize model, NodeWithoutFinalize node) {
        auto parent = new ZeroOrMorePredicate(predicate, child);
        auto value = parent.parse(parse_context, model, node);
        if (value.value.length == 0) {
            string s() {
                return parse_context.translate("Must have at least one predicate %s for node %s.").format(predicate, node);
            }
            parse_context.raise(on_error, s);
        }
        return value;
    }
}

class OnePredicate : PredicateParserWithError {
    private NodeParser child;
    this(NodeWithoutFinalize _predicate, NodeParser _child, ErrorMode _on_error) {
        super( predicate, on_error);
        child = _child;
    }
    override BaseParseResult parse(ParseContext parse_context, ModelWithoutFinalize model, NodeWithoutFinalize node) {
        auto v = model.getTargets(node, predicate).array;
        if (v.length != 1) {
            string s() {
                return parse_context.translate("Exactly one predicate %s required for node %s.").format(predicate, node);
            }
            parse_context.raise(on_error, s);
        }
        return child.parse(parse_context, model, v[0]);
    }
}

class ZeroOnePredicate : PredicateParserWithError {
    private NodeParser child;
    BaseParseResult default_;
    this(NodeWithoutFinalize _predicate, NodeParser _child, ErrorMode _on_error, BaseParseResult default_value=null) {
        super(_predicate, _on_error);
        child = _child;
        default_ = default_value;
    }
    override BaseParseResult parse(ParseContext parse_context, ModelWithoutFinalize model, NodeWithoutFinalize node) {
        auto v = model.getTargets( node, predicate).array;
        if (!v) return default_;
        if (v.length > 1) {
            string s() {
                return parse_context.translate("Cannot be more than one predicate %s for node %s.").format(predicate, node);
            }
            parse_context.raise(on_error, s);
        }
        return child.parse( parse_context, model, v[0]);
    }
}