// Our own shell. Run with: qs -c shell
import QtQuick
import Quickshell
import "bar"
import "launcher"
import "notifications"
import "osd"
import "control"
import "lock"
import "wallpaper"
import "dashboard"
import "tools"
import "security"
import "dock"
import "services"

ShellRoot {
    // singletons load lazily; start the ones that must run from login
    Component.onCompleted: [Idle.coffee, Clipboard.entries, BatteryAlerts.pct, Portal.state, Session.saved]

    Background {}

    // one bar per screen; the model changes with the bar's position because a layer surface
    // can't move to another edge once it's mapped, so the bars are recreated instead
    Variants {
        model: Settings.loaded ? Quickshell.screens.map(s => ({ screen: s, position: Settings.get("barPosition") })) : []
        Bar {}
    }

    Launcher {}
    AppGrid {}
    ClipboardPanel {}
    PowerMenu {}
    Variants {
        model: [Settings.get("barPosition")]
        Popups {}
    }
    Center {}
    Osd {}
    ControlCenter {}
    Lock {}
    Dashboard {}
    Cheatsheet {}
    TaskManager {}
    SettingsPanel {}
    // registering the polkit agent blocks ~0.1 s; do it right after the first frame
    LazyLoader { activeAsync: true; PolkitDialog {} }
    Dock {}
}
