module xmlboiler.options;

import std.container.rbtree;
import rdf.redland.model;
import xmlboiler.base;

enum WorklowKind { transformation, validation }

enum RecursiveDownload { none, depthFirst, breadthFirst }

enum RecursiveRetrievalPriorityOrderElement { sources, targets, workflowTargets }

// probably somehow slow
alias RecursiveRetrievalPriority = RedBlackTree!RecursiveRetrievalPriorityOrderElement;

alias Downloader = Model delegate(URI);

struct RecursiveDownloadOptions {
    Downloader[][] downloaders;
    RedBlackTree!URI initialAssets; // downloaded before the main loop
    RecursiveDownload recursiveDownload;
    RecursiveRetrievalPriority retrievalPriority;
}

//struct InstalledSoftwareOptions {
//    Nullable!BasePackageManaging packageManager; // isNull means not to use package_manager
//    bool usePath = true;
//}

// TODO

