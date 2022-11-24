import std.process : environment;
import std.stdio : stdout, File, write, writeln;
import std.string;
import std.file : DirEntry, timeLastModified, timeLastAccessed;
import std.datetime.systime;
import core.sys.posix.sys.stat : stat_t;
import core.memory : GC;
import templatizer;

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
    p.destroy();
    GC.free(cast(void *) &p);
}

void freeNodeInfo(ref NodeInfo p) @trusted {
    p.destroy();
    GC.free(cast(void *) &p);
}

void freeFile(File *p) @trusted {
    p.destroy();
    GC.free(cast(void *) p);
}

void exit(int rc) @safe {
    () @trusted {
        import core.stdc.stdlib : exit;
        exit(rc);
    }();
}

void send403() @safe @live
{
    write("Status: 404 Forbidden\r\n");
    write("Content-Type: text/html\r\n");
    write("\r\n");
    writeln("The client does not have access " ~
            "to the property.\n");
    exit(0);
}

void send404() @safe @live
{
    write("Status: 404 Not found\r\n");
    write("Content-Type: text/html\r\n");
    write("\r\n");
    writeln("File not found.");
    exit(0);
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

void cleanupGatherInformation(DirEntry ent, SysTime modified, SysTime access) @trusted {
    /*GC.free(cast(void *) modified);
    GC.free(cast(void *) access);*/
    GC.free(cast(void *) ent);
}

@safe @live
static NodeInfo gatherInformation(string path)
{
    auto ent = DirEntry(path);
    stat_t statbuf = ent.statBuf();
    auto modified = timeLastModified(statbuf);
    auto access = timeLastAccessed(statbuf);
    NodeInfo ni;
    ni.creation = "";
    ni.modification = modified.toISOString();
    ni.access = access.toISOString;
    cleanupGatherInformation(ent, modified, access);
    return ni;
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
        ni = gatherInformation("./test.txt");
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

@safe @live
static void dumpBlock(scope File *file, scope char[] buffer)
{
    char[] bufferSlice = file.rawRead(buffer);
    () @trusted {
        stdout.rawWrite(bufferSlice);
    }();
}

@safe @live
static void tryDumpBlock(scope File *file, scope char[] buffer)
{
    try {
        dumpBlock(file, buffer);
    } finally {
        file.close();
    }
}

void freeCharArray(char[] slice) @trusted
{
    GC.free(cast(void *) slice.ptr);
}

static int handleGet(int bufferSize) @safe @live
{
    char[] buffer = new char[bufferSize];
    string path = "/test.txt";
    string base = "/mnt/nextcloud/";
    string fullpath = base ~ path;
    File *file = new File();
    try {
        file.open(fullpath.dup(), "rb");
        while (!file.eof()) {
            tryDumpBlock(file, buffer);
        }
    } catch(Exception e) {
        send404();
        //return 1;
    } finally {
        freeString(path);
        freeString(base);
        freeString(fullpath);
        freeFile(file);
        freeCharArray(buffer);
    }
    return 0;
}

static int handle_post() @safe @live
{
    send404();
    return 0;
}

extern (C) @safe @live
int init(scope tmpl_ctx_t data, scope tmpl_cb_t cb)
{
    int r = -1;
    int bufferSize = 128;
    string method =  environment.get("REQUEST_METHOD");
    switch (method) {
        case "PROPFIND":
        r = handle_propfind();
        break;

        case "GET":
        r = handleGet(bufferSize);
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

extern(C) static void quit() {}

extern(C)
templatizer_plugin templatizer_plugin_v1 = {
        &init,
        &quit
};
