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

module xmlboiler.core.execution_context_builders;

import std.stdio;
import std.experimental.logger;
import mofile;
import struct_params;
import pure_dependency.providers;

public import xmlboiler.core.execution_context;

// FIXME: Don't open stderr multiple times.
mixin StructParams!("ExecutionContextParams", Logger, "logger", MoFile, "mo");
immutable ExecutionContextParams.Func executionContextDefaults =
    { logger: () => new FileLogger(stderr), mo: () => MoFile() };
alias ExecutionContextProvider =
    ProviderWithDefaults!(Callable!((Logger logger, MoFile translations) => ExecutionContext(logger, translations)),
                          ExecutionContextParams,
    executionContextDefaults);
ExecutionContextProvider executionContextProvider;
static this() { executionContextProvider = new ExecutionContextProvider; }