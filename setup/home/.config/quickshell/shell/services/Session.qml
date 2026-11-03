pragma Singleton
// On-demand session: "Save session" in the power menu remembers the open apps; the next login asks whether
// to reopen them. Window rules put them back on their tags. Not now keeps the session, Restore uses it up.
// Test with: qs -c shell ipc call session save
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string stateFile: Quickshell.env("HOME") + "/.local/state/shell/session.json"
    property var saved: null        // { time: ms since epoch, apps: [{ id, name }] }

    function entryFor(appId) {
        return DesktopEntries.byId(appId) ?? DesktopEntries.heuristicLookup(appId);
    }

    function notify(summary, body) {
        Quickshell.execDetached(["notify-send", "-a", "Session", "-i", "document-save", summary, body ?? ""]);
    }

    function describe() {
        if (!saved?.apps?.length) return "";
        const when = new Date(saved.time);
        const day = when.toDateString() === new Date().toDateString() ? "today" : Qt.formatDate(when, "MMM d");
        const time = Qt.formatTime(when, Settings.get("clock24h") ? "HH:mm" : "h:mm AP");
        return saved.apps.map(a => a.name).join(" · ") + "\nsaved " + day + " " + time;
    }

    function save() { saver.running = true; }

    function offer() {
        offerProc.command = ["sh", "-c",
            'm="$XDG_RUNTIME_DIR/shell-session-offered"; [ -e "$m" ] && exit 0; : > "$m"; [ -n "$1" ] || exit 0\n' +
            'notify-send -a Session -i document-save -u critical -A restore=Restore -A later="Not now" "Restore your session?" "$1"',
            "sh", describe()];
        offerProc.running = true;
    }

    // apps come from one window list, so an app with several windows reopens once
    Process {
        id: saver
        command: ["mmsg", "get", "all-clients"]
        stdout: StdioCollector {
            onStreamFinished: {
                let clients = [];
                try { clients = JSON.parse(this.text).clients ?? []; } catch (e) {}
                const apps = [];
                for (const c of clients) {
                    // no tags or a scratchpad: the dropdown terminal, which starts by itself
                    if (!c.tags?.length || c.is_scratchpad || c.appid.startsWith("dev.claude.")) continue;
                    const e = root.entryFor(c.appid);
                    if (e && !apps.some(a => a.id === e.id)) apps.push({ id: e.id, name: e.name });
                }
                if (!apps.length) { root.notify("Nothing to save", "No apps are open."); return; }
                root.saved = { time: Date.now(), apps: apps };
                store.setText(JSON.stringify(root.saved));
                root.notify("Session saved", apps.map(a => a.name).join(" · "));
            }
        }
    }

    // apps that are already open (autostarted ones) aren't opened twice
    Process {
        id: restorer
        command: ["mmsg", "get", "all-clients"]
        stdout: StdioCollector {
            onStreamFinished: {
                let clients = [];
                try { clients = JSON.parse(this.text).clients ?? []; } catch (e) {}
                const running = clients.map(c => root.entryFor(c.appid)?.id);
                for (const a of root.saved?.apps ?? []) {
                    if (!running.includes(a.id)) DesktopEntries.byId(a.id)?.execute();
                }
                root.saved = null;
                Quickshell.execDetached(["rm", "-f", root.stateFile]);
            }
        }
    }

    Process {
        id: offerProc
        stdout: StdioCollector {
            onStreamFinished: if (this.text.trim() === "restore") restorer.running = true
        }
    }

    FileView {
        id: store
        path: root.stateFile
        onLoaded: {
            try { root.saved = JSON.parse(store.text()); } catch (e) {}
            offerTimer.start();
        }
        onLoadFailed: offerTimer.start()
    }

    // give the notification server and the app list a moment after login
    Timer { id: offerTimer; interval: 3000; onTriggered: root.offer() }

    IpcHandler {
        target: "session"
        function save(): void { root.save(); }
    }
}
