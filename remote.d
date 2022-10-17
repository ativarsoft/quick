import std.process : environment;
import std.stdio : write, writeln;
import std.string;
import core.memory : GC;

enum AccessPermission {
    UNKNOWN_ERROR,
    FORBIDDEN,
    GRANTED
};

struct PathInfo {
    string username;
    string path;
};

struct NodeInfo {
    string creation, modification, access;
};

void freeString(string p) @trusted
{
    GC.free(cast(void *) p.ptr);
}

void freePathInfo(ref PathInfo p) @trusted {
    GC.free(cast(void *) &p);
}

void freeNodeInfo(ref NodeInfo p) @trusted {
    GC.free(cast(void *) &p);
}

void send403() @safe @live
{
    write("Status: 404 Forbidden\r\n");
    write("Content-Type: text/html\r\n");
    write("\r\n");
    writeln("The client does not have access " ~
            "to the property.\n");
}

void send404() @safe @live
{
    write("Status: 404 Not found\r\n");
    write("Content-Type: text/html\r\n");
    write("\r\n");
    writeln("File not found.");
}

@safe @live
int parsePathInfo(scope string s, scope ref PathInfo pathinfo)
{
    ptrdiff_t index;
    index = s.indexOf('/');
    if (index < 0)
        return 1;
    //pathinfo.username = s[0..index].dup();
    return 0;
}

@safe @live
AccessPermission
verifyPermissions(scope ref string user)
{
    AccessPermission r = AccessPermission.FORBIDDEN;
    return r;
}

@safe @live
int gatherInformation(scope ref NodeInfo ni)
{
    int r = -1;
    ni.creation = "";
    ni.modification = "";
    ni.access = "";
    return r;
}

static int handle_propfind() @safe
{
    int r = -1;
    scope PathInfo pathinfo;
    scope NodeInfo ni;

    if (parsePathInfo(environment.get("PATH_INFO", ""), pathinfo))
        return 1;
    switch (verifyPermissions(pathinfo.username)) {
        case AccessPermission.GRANTED:
        r = gatherInformation(ni);
        break;

        case AccessPermission.FORBIDDEN:
        send403();
        r = 1;
        break;

        default:
        return 1;
    }
    return r;
}

static int handle_get() @safe @live
{
    send404();
    return 0;
}

static int handle_post() @safe @live
{
    send404();
    return 0;
}

extern (C) @safe @live
int init()
{
    int r = -1;
    string method =  environment.get("REQUEST_METHOD");
    switch (method) {
        case "PROPFIND":
        r = handle_propfind();
        break;

        case "GET":
        r = handle_get();
        break;

        case "POST":
        r = handle_post();
        break;

        case null:
        writeln("The REQUEST_METHOD environment variable was not found.");
        r = 1;
        break;

        default:
        r = 1;
        break;
    }
    freeString(method);
    return r;
}
