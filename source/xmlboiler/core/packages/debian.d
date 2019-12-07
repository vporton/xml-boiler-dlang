import std.exception;
import std.regex;
import std.process;
import xmlboiler.core.rdf_recursive_descent.base;


class DebianPackageManaging(BasePackageManaging) {
    static string determine_package_version(string package_name) {
        enforce(!package_name.contains(' ')); // FIXME: Check also for no special chars.

        auto pipes = pipeProcess("dpkg " ~ package_name, Redirect.stdout);
        auto m = matchFirst(pipes.stdout, RegExp("^Version: (.*)"));
        if (!m) return null;
        string version_ = m.front;
        // https://www.debian.org/doc/debian-policy/#s-f-version
        version_ = matchFirst(version_, r"^([0-9]+:)?(.*)(-[a-zA-Z0-9+.~]+)?$")[2];
        return version_;
    }

    //alias VersionClass = deb_pkg_tools.version.Version; // FIXME
}