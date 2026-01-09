import Cocoa
import FlutterMacOS
import bitsdojo_window_macos // Add this import

class MainFlutterWindow: bitsdojo_window_macos.BitsdojoWindow { 
  // Change the parent class
    override func awakeFromNib() {
        let flutterViewController = FlutterViewController()
        let windowFrame = self.frame
        self.contentViewController = flutterViewController
        self.setFrame(windowFrame, display: true)

        // --- NEW CUSTOMIZATION CODE ---
        // 1. Make the title bar transparent so our orange bar shows through
        self.titlebarAppearsTransparent = true
        
        // 2. Hide the default window title text
        self.titleVisibility = .hidden
        
        // 3. Extend the content to the very top (under the traffic lights)
        self.styleMask.insert(.fullSizeContentView)
        
        // 4. (Optional) Remove the standard title bar shadow for a flatter look
        self.hasShadow = true 
        // ------------------------------

        RegisterGeneratedPlugins(registry: flutterViewController)

        super.awakeFromNib()
    }

    // This ensures bitsdojo_window can handle the custom window drawing correctly
    override func bitsdojo_window_configure() -> BitsdojoWindowConfiguration {
        let config = BitsdojoWindowConfiguration()
        config.titleBarStyle = .hidden
        return config
    }
}