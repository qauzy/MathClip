//
// Created by gauss on 2023/4/24.
//

import Foundation


import Alamofire
import Async
import Foundation

class NetRecognizer: Recognizer {
    func recognize(picBase64: String, progress: ((Double) -> Void)? = nil) throws -> String {
        progress?(0)


        var error: NSError?

        var rtn: String?
        let group = AsyncGroup()
        group.enter()

        let urlRequest = try! URLRequest(url: URL(string: "http://119.96.231.9:8502/pix/")!, method: HTTPMethod.post)
        let encodedURLRequest = try? URLEncoding.default.encode(urlRequest, with: ["file": picBase64])
        let data = encodedURLRequest?.httpBody!
//
        
        let parameters: [String: String] = [
            "file": picBase64,
        ]

        // 下面三种方法都是等价的
        let rq = AF.request("http://119.96.231.9:8502/pix/", method: .post, parameters: parameters)

        rq.uploadProgress(queue: .global(qos: .background)) { p in
            progress?(0.2 + (0.6 * p.fractionCompleted))
        }
            rq.responseString(
                                queue: .global(qos: .background),
                                encoding: .utf8) { response in

                let statuscode = response.response?.statusCode
                let result = response.value

               if statuscode == 200 {
                let ocrresponse = BaiduOcrResponse(json: result)
                if ocrresponse.error_code > 0 {
                    if let errordiscription = ocrresponse.error_msg {
                        error = NSError(domain: errordiscription, code: 0, userInfo: nil)
                    }
                } else {
                    rtn = ocrresponse.words_result.map { $0.words.trimmingCharacters(in: .whitespaces) }.joined(separator: "\n")
                }
            } else {
                let oauth = BaiduOauthError(json: result)
                if let errordiscription = oauth.error_description {
                    error = NSError(domain: errordiscription, code: 0, userInfo: nil)
                }
            }
            group.leave()
                    
            }
//        rq.responseString(
//                queue: .global(qos: .background),
//                encoding: .utf8) { response in
//            guard let statuscode = response.response?.statusCode, let result = response.result.value else {
//                group.leave()
//                return
//            }
//

//        }

        group.wait(seconds: 15)
        progress?(1)
        guard let final = rtn else {
            throw error ?? NSError(domain: "Ocr failed", code: 0, userInfo: nil)
        }

        return final
    }
}
