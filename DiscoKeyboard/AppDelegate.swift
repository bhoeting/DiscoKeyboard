
//
// Brennan Hoeting 2015
// Oxford, OH
//

import Cocoa
import IOKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var statusMenu: NSMenu!
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1)
    
    @IBAction func menuClicked(sender: NSMenuItem) {
        Backlight.sharedBacklight.toggleFlashing(self, interval: Backlight.MediumFlashingInterval)
        if sender.title == "Start" {
            sender.title = "Stop"
        } else {
            sender.title = "Start"
        }
    }
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        let icon = NSImage(named: "StatusIcon")!
        icon.template = true
        statusItem.image = icon
        statusItem.menu = statusMenu
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        Backlight.sharedBacklight.set(Backlight.MaxBrightness)
    }
    
    // This method is called by the Backlight.toggleFlashing method
    func toggle() {
        Backlight.sharedBacklight.toggle()
    }
}

