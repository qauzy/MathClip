//
// Created by gauss on 2023/4/22.
//

import Cocoa
import SwiftUI
@main
struct MathClipApp: App {
    @State var currentNumber: String = "1"

    @NSApplicationDelegateAdaptor(AppDelegate.self)
    private var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
