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

module xmlboiler.core.options;

import std.typecons;
import std.container.rbtree;
import std.experimental.logger;
import rdf.redland.model;
import xmlboiler.core.base;
import xmlboiler.core.execution_context;
import xmlboiler.core.packages.base;

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

struct InstalledSoftwareOptions {
    Nullable!BasePackageManaging packageManager; // null means not to use package_manager
    bool usePath = true;
}

enum WeightFormula { inverseOfSum, sumOfInverses }

class BaseAlgorithmOptions {
    ExecutionContext executionContext;
    Logger errorLogger; // may be stderr
    //BaseCommandRunner commandRunner; // TODO
    //MyOpener urlOpener; // TODO
    //WorklowKind kind;
    RecursiveDownloadOptions recursivePptions;
    InstalledSoftwareOptions installedSoftOptions;
    WeightFormula weightFormula;
}

enum NotInTargetNamespace {
    ignore,
    remove, // TODO: Not implemented
    error
}

struct BaseAutomaticWorkflowElementOptions {
    BaseAlgorithmOptions algorithmOptions;
    NotInTargetNamespace notInTarget;
    alias algorithmOptions this;
}

/* Validation */

enum ValidationOrderType { depthFirst, breadthFirst }

struct ValidationAutomaticWorkflowElementOptions {
    BaseAutomaticWorkflowElementOptions base;
    ValidationOrderType validationOrder;
    bool unknownNamespacesIsInvalid;
    alias base this;
}

/* Transformation */

/// For `chain` command.
struct ChainOptions {
    BaseAutomaticWorkflowElementOptions elementOptions;
    Nullable!URI universalPrecedence; // TODO: Find a better name for this option
    RedBlackTree!URI targetNamespaces;
    alias elementOptions this;
}

/// For `script` command.
struct ScriptOptions {
    BaseAutomaticWorkflowElementOptions elementOptions;
    URI scriptURL;
    alias elementOptions this;
}

/// For `script` command.
struct TransformOptions {
    BaseAutomaticWorkflowElementOptions elementOptions;
    URI transformURL;
    alias elementOptions this;
}

/// For `pipe` command.
struct PipelineOptions {
    BaseAutomaticWorkflowElementOptions elementOptions;
    alias elementOptions this;
}
