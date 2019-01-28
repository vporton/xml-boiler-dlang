module options;

import std.container.rbtree;

// TODO: Identifier casing
enum WorklowKind { TRANSFORMATION, VALIDATION }

// TODO: Identifier casing
enum RecursiveDownload { NONE, DEPTH_FIRST, BREADTH_FIRST }

// TODO: Identifier casing
class RecursiveRetrievalPriorityOrderElement { SOURCES, TARGETS, WORKFLOW_TARGETS }

// probably somehow slow
class RecursiveRetrievalPriority : RedBlackTree!RecursiveRetrievalPriorityOrderElement { }

// TODO

