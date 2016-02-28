import Foundation

class Backlight {
   
    // Flags
    private var isOn = false;
    private var isFlashing = false;
    private var numberOfToggles = 0;
    private var isFlashingOnce = false;
    
    // Hardware thing
    private var connect: mach_port_t = 0;
    
    // Timer for flashing
    private var timer:NSTimer = NSTimer()
    
    // Shared instance
    static var sharedBacklight = Backlight()
    
    // Flashing intervals
    static let FastFlashingInterval = 0.02;
    static let MediumFlashingInterval = 0.06;
    static let SlowFlashingInterval = 0.1;
    
    // Brightness levels
    static let MinBrightness:UInt64 = 0x0;
    static let MaxBrightness:UInt64 = 0xfff;
    
    init() {
        // Get the AppleLMUController (thing that accesses the light hardware)
        let serviceObject = IOServiceGetMatchingService(kIOMasterPortDefault,
            IOServiceMatching("AppleLMUController"))
        assert(serviceObject != 0, "Failed to get service object")
        
        // Open the AppleLMUController
        let status = IOServiceOpen(serviceObject, mach_task_self_, 0, &connect)
        assert(status == KERN_SUCCESS, "Failed to open IO service")
        
        // Start with the backlight off
        off();
    }
    
    func startFlashing(target: AnyObject, interval: Float64) {
        self.timer = NSTimer.scheduledTimerWithTimeInterval(
            interval, target: target, selector: "toggle", userInfo: nil, repeats: true)
        
        // We need to add the timer to the mainRunLoop so it doesn't stop flashing when the menu is accessed
        NSRunLoop.mainRunLoop().addTimer(self.timer, forMode: NSRunLoopCommonModes)
        self.isFlashing = true
    }
    
    func stopFlashing() {
        self.isFlashing = false
        self.timer.invalidate()
    }
    
    func toggleFlashing(target: AnyObject, interval: Float64) {
        if self.isFlashing {
            self.timer.invalidate()
        } else {
            self.timer = NSTimer.scheduledTimerWithTimeInterval(
                interval, target: target, selector: "toggle", userInfo: nil, repeats: true)
            
            NSRunLoop.mainRunLoop().addTimer(self.timer, forMode: NSRunLoopCommonModes)
        }
        
        self.isFlashing = !self.isFlashing
    }
    
    func flashOnce(target: AnyObject, interval: Float64) {
        self.isFlashingOnce = true
        self.numberOfToggles = 0
        self.timer = NSTimer.scheduledTimerWithTimeInterval(
            interval, target: target, selector: "toggle", userInfo: nil, repeats: true)
    }
    
    func toggle() {
        if self.isOn {
            self.off();
        } else {
            self.on();
        }
        
        if ++self.numberOfToggles >= 3 && isFlashingOnce {
            self.timer.invalidate()
            isFlashingOnce = false
        }
    }
    
    func on() {
        set(Backlight.MaxBrightness);
        isOn = true;
    }
    
    func off() {
        set(Backlight.MinBrightness);
        isOn = false;
    }
    
    func set(brightness: UInt64) {
        var output: UInt64 = 0
        var outputCount: UInt32 = 1
        let setBrightnessMethodId:UInt32 = 2
        let input: [UInt64] = [0, brightness]
        
        let status = IOConnectCallMethod(connect, setBrightnessMethodId, input, UInt32(input.count),
            nil, 0, &output, &outputCount, nil, nil)
        
        assert(status == KERN_SUCCESS, "Failed to set brightness; status: \(status)")
    }
    
}


