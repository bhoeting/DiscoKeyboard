import Cocoa
import IOKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var statusMenu: NSMenu!
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1)
    
    @IBAction func menuClicked(sender: NSMenuItem) {
        if sender.state == NSOnState {
            sender.title = "Start"
            sender.state = NSOffState
            Backlight.sharedBacklight.stopFlashing()
            
            // This needs to be delayed so the brightness gets reset after the timer is removed
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(
                Backlight.MediumFlashingInterval * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                Backlight.sharedBacklight.set(Backlight.MaxBrightness)
            }
        } else {
            sender.title = "Stop"
            sender.state = NSOnState
            Backlight.sharedBacklight.startFlashing(
                self, interval: Backlight.MediumFlashingInterval, selector: #selector(AppDelegate.toggle))
        }
    }
    
    @IBAction func quitMenuItemClicked(sender: NSMenuItem) {
        NSApplication.sharedApplication().terminate(self)
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

