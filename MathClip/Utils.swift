//
// Created by gauss on 2023/4/23.
//

import Foundation
class Utils {
    static func capturePic() {
//        let destinationPath = "/tmp/\(UUID().uuidString).png"
        let task = Process()
        task.launchPath = "/usr/sbin/screencapture"
        task.arguments = ["-i", "-r","-c"]
        task.launch()
        task.waitUntilExit()
        return
    }
}