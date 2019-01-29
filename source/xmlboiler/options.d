module xmlboiler.options;

import std.container.rbtree;
import rdf.redland.model;
import xmlboiler.base;

// TODO: Identifier casing
enum WorklowKind { TRANSFORMATION, VALIDATION }

// TODO: Identifier casing
enum RecursiveDownload { NONE, DEPTH_FIRST, BREADTH_FIRST }

// TODO: Identifier casing
enum RecursiveRetrievalPriorityOrderElement { SOURCES, TARGETS, WORKFLOW_TARGETS }

// probably somehow slow
alias RecursiveRetrievalPriority = RedBlackTree!RecursiveRetrievalPriorityOrderElement;

// TODO: Graph is not yet defined
alias Downloader = Model delegate(URI);

struct RecursiveDownloadOptions {
    Downloader[][] downloaders;
    RedBlackTree!URI initialAssets; // downloaded before the main loop
    RecursiveDownload recursiveDownload;
    RecursiveRetrievalPriority retrievalPriority;
}

// TODO

