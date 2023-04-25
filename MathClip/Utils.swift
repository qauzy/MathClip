//
// Created by gauss on 2023/4/23.
//

import Foundation
class Utils {
    static func capturePic() -> String? {
        let destinationPath = "/tmp/\(UUID().uuidString).png"
        let task = Process()
        task.launchPath = "/usr/sbin/screencapture"
        task.arguments = ["-i", "-r", destinationPath]
        task.launch()
        task.waitUntilExit()
        var notDir = ObjCBool(false)
        return FileManager.default.fileExists(atPath: destinationPath, isDirectory: &notDir)
                ? destinationPath
                : nil
    }
}