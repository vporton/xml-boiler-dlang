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
import std.stdio;
import std.file;
import core.stdc.stdlib;
import struct_params;
import pure_dependency.providers;
import rdf.redland.world;
import rdf.redland.storage;
import rdf.redland.model;
import rdf.redland.uri;

// Ugh, messy code.
private RedlandWorldWithoutFinalize createWorld() {
    static RedlandWorldWithoutFinalize world2;
    if (world2.handle) {
        return world2;
    } else {
        RedlandWorld world = RedlandWorld.createAndOpen();
        world2 = world;
        return world2;
    }
}
Provider!RedlandWorldWithoutFinalize rdfWorldProvider;
static this() {
    rdfWorldProvider = new Callable!createWorld();
}

struct Global {
    RedlandWorldWithoutFinalize world; // TODO: Make it constant.
    this(RedlandWorldWithoutFinalize _world) {
        world = _world;
    }
    // TODO: Wrong encoding on Windows: https://forum.dlang.org/thread/gg9h3f$9uo$1@digitalmars.com
    string get_filename(string filename) {
        if (to!string(getenv("XMLBOILER_PATH")) != "")
            return to!string(getenv("XMLBOILER_PATH")) ~ '/' ~ filename;
        else
            return "source/xmlboiler/" ~ filename;
    }
    File get_resource_stream(string filename) {
        return *new File(get_filename(filename), "r");
    }
    string get_resource_bytes(string filename) {
        return cast(string) filename.read;
    }
    Model load_rdf(string filename) {
        Storage storage = Storage.create(world, "memory", "main"); // TODO
        auto model = Model.create(world, storage);
        model.load(URI.fromFilename(world, filename));
        return model;
    }
}

Provider!(Global, RedlandWorldWithoutFinalize) globalProvider;
mixin StructParams!("GlobalProvidersParams", RedlandWorldWithoutFinalize, "world");
immutable GlobalProvidersParams.Func globalProviderDefaults = { world: () => rdfWorldProvider() };
alias GlobalProviderWithDefaults = ProviderWithDefaults!(Callable!((RedlandWorldWithoutFinalize world) => Global(world)),
                                                         GlobalProvidersParams,
                                                         globalProviderDefaults);
static this() {
    globalProvider = new GlobalProviderWithDefaults();
}