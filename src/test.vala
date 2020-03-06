try {
    string[] command = {"/home/darko/bin/pcmanfm-bookmarks"};
    string[] env = Environ.get ();
    Pid child_pid;

    int stdin;
    int stdout;
    int stderr;

    Process.spawn_async_with_pipes ("/",
        command,
        env,
        SpawnFlags.SEARCH_PATH | SpawnFlags.DO_NOT_REAP_CHILD,
        null,
        out child_pid,
        out stdin,
        out stdout,
        out stderr);

    FileStream stream = FileStream.fdopen (stdout, "r");

    var sb = new StringBuilder();
    string? line = null;
    while ((line = stream.read_line ()) != null) {
        sb.append(line);
    }

    var xml = sb.str;
    print(xml);
    
    /* Make sure we close the process using it's pid */
    ChildWatch.add (child_pid, (pid, status) => {
        Process.close_pid (pid);
    });
} catch (SpawnError e) {
    /* Do something w the Error */
}
return 0;
