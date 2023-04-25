//
// Created by gauss on 2023/4/23.
//

import Cocoa

class EventMonitor {
    private var monitor: Any?
    private let mask: NSEvent.EventTypeMask
    private let handler: (NSEvent?) -> Void

    // mask 是要监听的事件类型
    // handler 是事件处理函数，它是一个逃逸闭包，接受一个 NSEvent? 类型作为参数，返回 Void（无返回值）
    public init(mask: NSEvent.EventTypeMask, handler: @escaping (NSEvent?) -> Void) {
        self.mask = mask
        self.handler = handler
    }

    deinit {
        stop()
    }

    public func start() {
        // 添加一个系统全局事件监听器，并返回给 monitor 存储属性
        // as! 表示将前面的可选类型当作 NSObject 进行强制解包
        monitor = NSEvent.addGlobalMonitorForEvents(matching: mask, handler: handler) as! NSObject
    }

    public func stop() {
        if monitor != nil {
            // 从系统全局事件监听器队列中删除自己的监听器
            NSEvent.removeMonitor(monitor!)
            // 解除引用，使得该事件监听器实例被销毁
            monitor = nil
        }
    }
}