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
import rdf.redland.model;
import xmlboiler.core.base;
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

// TODO

