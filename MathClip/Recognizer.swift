//
// Created by gauss on 2023/4/24.
//

import Foundation

protocol Recognizer {
    func recognize(picBase64: String, progress: ((Double) -> Void)?) throws -> String
}
