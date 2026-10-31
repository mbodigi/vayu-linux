pragma Singleton
// Captive portal (hotel/airport Wi-Fi login): NetworkManager's connectivity check reports "portal",
// we open the login page in Brave on tag 5 straight away (LibreWolf's HTTPS-only mode can
// block the plain http page the portal needs) and show a notification that can reopen it.
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string state: "unknown"   // none | portal | limited | full | unknown
    readonly property bool portal: state === "portal"
    // plain http so the portal can redirect it
    readonly property string loginUrl: "http://neverssl.com"

    function openLogin() {
        Quickshell.execDetached(["brave-browser", "--new-window", root.loginUrl]);
        Quickshell.execDetached(["mmsg", "dispatch", "view,5"]);
    }

    function notify() {
        Quickshell.execDetached(["sh", "-c",
            'a=$(notify-send -a "Wi-Fi" -i network-wireless -u critical -A default=Reopen -A open=Reopen ' +
            '"Wi-Fi login required" "The login page is open in Brave on tag 5. Click to open it again.")\n' +
            '[ -n "$a" ] && brave-browser --new-window "$1" && mmsg dispatch view,5', "sh", root.loginUrl]);
    }

    onPortalChanged: if (portal) { openLogin(); notify(); }

    // state at startup
    Process {
        command: ["nmcli", "-t", "-f", "CONNECTIVITY", "general"]
        running: true
        stdout: SplitParser { onRead: line => root.state = line.trim() }
    }

    // "Connectivity is now 'portal'" etc.
    Process {
        id: monitor
        command: ["setpriv", "--pdeathsig", "TERM", "--", "env", "LC_ALL=C", "nmcli", "monitor"]
        running: true
        stdout: SplitParser {
            onRead: line => {
                const m = line.match(/Connectivity is now '(\w+)'/);
                if (m) root.state = m[1];
            }
        }
        onRunningChanged: if (!running) restartMonitor.start()
    }
    Timer { id: restartMonitor; interval: 2000; onTriggered: monitor.running = true }

    // while the login page is up, re-check often so we notice the login within seconds
    // (NetworkManager alone re-checks every 5 minutes; NextDNS switches back on "full")
    Timer {
        interval: 15000
        repeat: true
        running: root.portal
        onTriggered: Quickshell.execDetached(["nmcli", "networking", "connectivity", "check"])
    }

    IpcHandler {
        target: "portal"
        function login(): void { root.openLogin(); }
        function status(): string { return root.state; }
    }
}
