import std.typecons;
import struct_params;
import pure_dependency.providers;
import anansi.adjacencylist;
import rdf.redland.world;
import rdf.redland.uri;
import rdf.redland.node;
import rdf.redland.statement;
import rdf.redland.model;
import xmlboiler.core.data : Global;
import xmlboiler.core.graph.relation : BinaryRelation;
import xmlboiler.core.graph.connect : Connectivity;
import xmlboiler.core.execution_context_builders;
import xmlboiler.core.data;

alias MyAdjacencyList = AdjacencyList!();

class SubclassRelation : Connectivity!(URI.HandleObject) {
    RedlandWorldWithoutFinalize world;
    ExecutionContext context;
    Node relation;
    this(RedlandWorldWithoutFinalize _world,
         ExecutionContext _context,
         Node _relation,
         MyAdjacencyList graph=MyAdjacencyList())
    {
        super();
        world = _world;
        context = _context;
        relation = _relation;
        add_graph( graph);
    }
    this(RedlandWorldWithoutFinalize _world,
         ExecutionContext _context,
         MyAdjacencyList graph=MyAdjacencyList())
    {
        this(_world, _context, Node.fromURIString(_world, "http://www.w3.org/2000/01/rdf-schema#subClassOf"), _graph);
    }

    bool add_graph(ModelWithoutFinalize graph) {
        auto result = BinaryRelation();
        bool were_errors = false;
        foreach (st; graph.find( new Statement( null, relation, null))) {
            auto subject = st.subject;
            auto object = st.object;
            if (object.isResource) {
                if (check_types( graph, subject, object))
                    result.add_edge( subject, object);
            } else {
                were_errors = true;
                immutable msg = context.translations.gettext("Node %s should be an IRI.").format(object);
                context.logger.warning( msg);
            }
        }
        add_relation( result);
        return !were_errors;
    }
    bool check_types(ModelWithoutFinalize graph, NodeWithoutFinalize src, NodeWithoutFinalize dst) {
        return True;
    }
}

class SubclassRelationForType : SubclassRelation {
    Node node_class;
    this(NodeWithoutFinalize _node_class,
         RedlandWorldWithoutFinalize _world,
         ExecutionContext _context,
         Node _relation,
         MyAdjacencyList graph=MyAdjacencyList())
    {
        node_class = _node_class; // need to set before super()
        super(_world, _context, _graph, _relation);
    }
    this(NodeWithoutFinalize _node_class,
         RedlandWorldWithoutFinalize _world,
         ExecutionContext _context,
         MyAdjacencyList graph=MyAdjacencyList())
    {
        this(_node_class, _world, _context, Node.fromURIString(_world, "http://www.w3.org/2000/01/rdf-schema#subClassOf"), _graph);
    }
    override bool check_types(ModelWithoutFinalize graph, NodeWithoutFinalize src, NodeWithoutFinalize dst) {
        src_ok = graph.contains(src, Node.fromURIString(world, "http://www.w3.org/1999/02/22-rdf-syntax-ns#type"), node_class);
        dst_ok = graph.contains(dst, Node.fromURIString(world, "http://www.w3.org/1999/02/22-rdf-syntax-ns#type"), node_class);
        if (src_ok ^ dst_ok) {
            immutable msg = context.translations.gettext("Both operands should be of type %s").format(node_class);
            context.logger.warning(msg);
        }
        return src_ok && dst_ok;
    }
}

shared basic_subclasses_graph = new ThreadSafeCallableSingleton!(
    () => globalProvider().load_rdf("core/data/subclasses.ttl"))();

Provider!(SubclassRelation, RedlandWorldWithoutFinalize, ExecutionContext, Node, AdjacencyList) subclassRelationProvider;
mixin StructParams!("SubclassRelationProvidersParams", RedlandWorldWithoutFinalize, "world",
                                                       ExecutionContext, "context",
                                                       Node, "relation",
                                                       MyAdjacencyList, "graph");

immutable SubclassRelationProvidersParams.Func subclassRelationProviderDefaults = {
    world: () => rdfWorldProvider(),
    context: () => executionContextProvider(),
    graph: () => MyAdjacencyList(),
};
alias SubclassRelationProviderWithDefaults = ProviderWithDefaults!(Callable!(
    (RedlandWorldWithoutFinalize world, ExecutionContext context, Node t, MyAdjacencyList graph)
        => new SubclassRelation(world, context, t.dup, graph)),
    SubclassRelationProvidersParams,
    globalProviderDefaults);
static this() {
    subclassRelationProvider = new SubclassRelationProviderWithDefaults();
}

Provider!(SubclassRelationForTypeProvidersParams, Node, RedlandWorldWithoutFinalize, ExecutionContext, Node, AdjacencyList) subclassRelationForTypeProvider;
mixin StructParams!("SubclassRelationForTypeProvidersParams",
                    NodeWithoutFinalize, "node_class",
                    RedlandWorldWithoutFinalize, "world",
                    ExecutionContext, "context",
                    MyAdjacencyList, "graph",
                    Node, "relation");

immutable SubclassRelationForTypeProvidersParams.Func subclassRelationForTypeProviderDefaults = {
    world: () => rdfWorldProvider(),
    context: () => executionContextProvider(),
    graph: () => MyAdjacencyList(),
};
alias SubclassRelationForTypeProviderWithDefaults = ProviderWithDefaults!(Callable!(
    (NodeWithoutFinalize node_class, RedlandWorldWithoutFinalize world, ExecutionContext context, Node t, MyAdjacencyList graph)
        => new SubclassRelationForType(node_class, world, context, t.dup, graph)),
    SubclassRelationForTypeProvidersParams,
    globalProviderDefaults);
static this() {
    subclassRelationForTypeProvider = new SubclassRelationForTypeProviderWithDefaults();
}