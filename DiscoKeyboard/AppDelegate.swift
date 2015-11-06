
//
// Brennan Hoeting 2015
// Oxford, OH
//

import Cocoa
import IOKit
import AVFoundation

@NSApplicationMain
class AppDelegate: NSObject, AVCaptureAudioDataOutputSampleBufferDelegate, NSApplicationDelegate {
    
    let session = AVCaptureSession()
    var peak: Float = 0
    let queue = dispatch_queue_create("AudioCapture", nil)
    
    // TODO: move this audio shit to another class
    override init() {
        super.init()
        do {
            try session.addInput(AVCaptureDeviceInput(
                device: AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeAudio)))
        } catch is NSError {
            
        }
        let dataOutput = AVCaptureAudioDataOutput()
        dataOutput.audioSettings = nil
        dataOutput.setSampleBufferDelegate(self, queue: queue)
        session.addOutput(dataOutput)
        session.startRunning()
    }
    
    @IBOutlet weak var statusMenu: NSMenu!
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1)
    
    @IBAction func menuClicked(sender: NSMenuItem) {
        //Backlight.sharedBacklight.flashOnce(self, interval: Backlight.MediumFlashingInterval)
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
            Backlight.sharedBacklight.startFlashing(self, interval: Backlight.MediumFlashingInterval)
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
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        // Get the sample buffer
        var lengthAtOffset: Int = 0
        var totalLength: Int = 0
        var bufPointer: UnsafeMutablePointer<Int8> = nil
        CMBlockBufferGetDataPointer(
            CMSampleBufferGetDataBuffer(sampleBuffer)!,
            0, &lengthAtOffset, &totalLength, &bufPointer
        )
        
        // The number of elements contiguous in the buffer start (it's always 512)
        let count = Int(lengthAtOffset) / (sizeof(Float) / sizeof(Int8))
        
        // Get a collection of floats from the buffer
        let samples = UnsafeMutableBufferPointer(
            start: UnsafeMutablePointer<Float>(bufPointer), count: count);
        
        // Get the highest amplitude from the sample set
        var amplitude:Float = 0.0;
        for sample in samples {
            amplitude = max(abs(sample), amplitude)
        }
        
        if amplitude > 0.035 {
            print(amplitude)
            //Backlight.sharedBacklight.flashOnce(self, interval: Backlight.FastFlashingInterval)
        }
    }
}

