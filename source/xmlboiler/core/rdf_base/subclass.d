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

class SubclassRelation : Connectivity!URI.HandleObject {
    RedlandWorldWithoutFinalize world;
    ExecutionContext context;
    Node relation;
    this(RedlandWorldWithoutFinalize _world,
         ExecutionContext _context,
         MyAdjacencyList graph=MyAdjacencyList(),
         Node _relation=Node.fromURIString(world, "http://www.w3.org/2000/01/rdf-schema#subClassOf"))
    {
        super();
        world = _world;
        context = _context;
        relation = _relation;
        add_graph( graph);
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
         MyAdjacencyList graph=MyAdjacencyList(),
         Node _relation=Node.fromURIString(world, "http://www.w3.org/2000/01/rdf-schema#subClassOf"))
    {
        node_class = _node_class; // need to set before super()
        super(_world, _context, _graph, _relation);
    }
    bool check_types(ModelWithoutFinalize graph, NodeWithoutFinalize src, NodeWithoutFinalize dst) {
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

Provider!(SubclassRelation, RedlandWorldWithoutFinalize, ExecutionContext, AdjacencyList, Node) subclassRelationProvider;
mixin StructParams!("SubclassRelationParams", RedlandWorldWithoutFinalize, "world",
                                              ExecutionContext, "context",
                                              MyAdjacencyList, "graph",
                                              Node, "relation");

immutable SubclassRelationParams.Func subclassRelationProviderDefaults = {
    world: () => rdfWorldProvider(),
    context: () => Nullable!ExecutionContext(), // FIXME: Contexts.execution_context,
    graph: () => basic_subclasses_graph,
};
alias SubclassRelationProviderWithDefaults = ProviderWithDefaults!(Callable!(
    (RedlandWorldWithoutFinalize world, ExecutionContext context, AdjacencyList graph, RDFNode t)
        => SubclassRelation(world, context, grap, t)),
    SubclassRelationProvidersParams,
    globalProviderDefaults);
static this() {
    subclassRelationProvider = new SubclassRelationProviderWithDefaults();
}

immutable SubclassRelationForTypeProvidersParams.Func subclassRelationForTypeProviderDefaults = {
    world: () => rdfWorldProvider(),
    context: () => null, // FIXME: Contexts.execution_context,
    graph: () => basic_subclasses_graph,
};
alias SubclassRelationForTypeProviderWithDefaults = ProviderWithDefaults!(Callable!(
    (RedlandWorldWithoutFinalize world, ExecutionContext context, AdjacencyList graph, Node t)
        => SubclassRelationForType(world, context, grap, t)),
    SubclassRelationForTypeProvidersParams,
    globalProviderDefaults);
static this() {
    subclassRelationProvider = new SubclassRelationForTypeProviderWithDefaults();
}
