//
// Created by gauss on 2023/4/22.
//
import Alamofire
import Cocoa
import SwiftUI
import HotKey
import Async

//@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate,ObservableObject {
    @Published var result:String = ""
    @Published var clip:String = ""
    let hotKey = HotKey(key: .m, modifiers: [.control, .command])
    private var eventMonitor: EventMonitor?
    private var contentView: ContentView?
    var popover: NSPopover!
    var statusItem: NSStatusItem!
    let tarMenu = NSMenu()
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the SwiftUI view that provides the window contents.
        self.contentView = ContentView(updater:self)
        // Create the popover
        let popover = NSPopover()
        popover.backgroundColor = NSColor.white   //设置popover颜色，对应extension里对popover的改写
        popover.contentSize = NSSize(width: 600, height: 800)
        popover.contentViewController = NSHostingController(rootView: contentView)
        popover.behavior = NSPopover.Behavior.semitransient

        self.popover = popover
// 设置一个事件监听器，监听鼠标在程序外部的点击事件
        self.eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown], handler: outerClickedHandler)

        // Create the status item
        self.statusItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.variableLength))
        let icon = NSImage(named: NSImage.Name("icons8-text-16"))
        icon?.isTemplate = true
        self.statusItem.image = icon

        if let button = self.statusItem.button {
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
            button.target = self
            button.action = #selector(togglePopover(_:))
        }

        let menuItem = NSMenuItem()
        menuItem.title = "退出"
        menuItem.target = self
        menuItem.action = NSSelectorFromString("quit")
        tarMenu.addItem(menuItem)
        hotKey.keyDownHandler = {
            self.capturePic4Txt()
        }

    }
    @objc
    func quit() {
        NSApplication.shared.terminate(self)
    }
    @objc
    func capturePic4Txt() {
        guard let picPath = Utils.capturePic() else {
            return
        }
        
        recognizepic(picPath: picPath)
    }

    private func recognizepic(picPath: String) {
        let picData = try? Data(contentsOf: URL(fileURLWithPath: picPath))
        if let base64 = picData?.base64EncodedString() {
            let recognizer = NetRecognizer()
            statusItem.image = nil
            statusItem.title = "0%"
            Async.background {
                do {
                    let final = try recognizer.recognize(picBase64: base64, progress: { p in
                        Async.main {
                            self.statusItem.title = "\(p * 100)%"
                        }
                    })
                    Async.main {
                        self.statusItem.image = NSImage(named: NSImage.Name("icons8-text-16"))
                        self.statusItem.title = nil
                        debugPrint("Response: \(final)")
                        self.result = final
                        self.clip = base64
                        self.showPopover()
                    }
                } catch {
                    print(error)
                    Async.main {
                        self.statusItem.image = NSImage(named: NSImage.Name("icons8-text-16"))
                        self.statusItem.title = nil
//                        self.recognizeVc.viewmodel.image.value = base64
//                        self.recognizeVc.viewmodel.recognizedText.value = error.localizedDescription
                        self.showPopover()
                    }
                }
            }
        }
    }

    @objc func togglePopover(_ sender: AnyObject?) {
//        debugPrint("===========================")
        let event = NSApp.currentEvent!
        if event.type == NSEvent.EventType.rightMouseUp {
            
            self.statusItem.menu = tarMenu
            self.statusItem.button?.performClick(nil)
            self.statusItem.menu = nil
            // Right button click
        } else {
            // Left button click
        }

        if let button = self.statusItem.button{
            if self.popover.isShown {
                self.popover.performClose(sender)
                self.eventMonitor?.stop()
            } else {

                self.popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
                self.eventMonitor?.start()
            }
        }
    }

    func outerClickedHandler(_ event: NSEvent?) {
        if self.popover.isShown {
            self.popover.performClose(event)
            self.eventMonitor?.stop()
        }
    }
    private func showPopover() {
        if let button = self.statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)

            self.eventMonitor?.start()
        }
    }
    
    func hidePopover(){
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        appDelegate.statusItem.isVisible = false
    }


}

