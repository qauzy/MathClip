//
//  ContentView.swift
//  MathClip
//
//  Created by gauss on 2023/4/21.
//
//

import SwiftUI
import AppKit
import LaTeX

extension Image {
    init?(base64String: String) {
        guard let data = Data(base64Encoded: base64String) else {
            return nil
        }
        guard let uiImage = NSImage(data: data) else {
            return nil
        }
        self = Image(nsImage: uiImage)
    }
}

struct ContentView: View {
    @ObservedObject var updater: AppDelegate
    @State private var remoteImage: NSImage? = nil //该属性拥有@State标记，所以当该属性的值发生变化时，和改属性绑定的图像视图，将立即显示新的图像内容
    let placeholderOne = NSImage(named: "icons8-text-16.png") //占位图

    @State private var showPopover = false
    @State private var image: NSImage?
    let placeholder = NSImage(named: "AccentColor")
    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 100){

                Button(action: {
                    updater.popover.close()
                    updater.capturePic4Txt()}) {
                    Text("截屏(Ctrl + Command + M)")
                    Image(systemName:"rectangle.dashed.and.paperclip")
                        
                }.padding([.top, .trailing], 18).padding(.horizontal,30)
                Button(action: {
                    NSApplication.shared.terminate(self)
                }) {
                    Text("退出")
                    Image(systemName:"pip.exit")
                }.padding([.top, .trailing], 18).padding(.leading,30)
            }

            Divider()
            VStack(spacing: 10) {
                Image(base64String: updater.clip)
                Divider()
                LaTeXView(formula: updater.result)
                Divider()
                HStack(spacing: 5) {
                    TextEditor(text: $updater.result)
                            .lineSpacing(1)// 行距
                            .disableAutocorrection(true)
                            .font(.title)
                            //背景
                            .textFieldStyle(PlainTextFieldStyle())
                            .background(Color.red) //<< here red
                            //frame
                            .frame(maxHeight: 200)
                            .foregroundColor(.blue)
                            .padding()
                    Button(action: {
                        // Closure will be called once user taps your button
                        let pasteBoard = NSPasteboard.general
                            pasteBoard.clearContents()
                        pasteBoard.setString(updater.result, forType: NSPasteboard.PasteboardType.string)
                    }) {
                        // 按钮样式
                        Text("复制")
                        Image(systemName:"list.clipboard.fill")
                    }
                }


            }

        }
    }

    func showWindow() {
        NSApp.unhide(nil)
    }


    func hideStatusBar() {
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        appDelegate.statusItem.isVisible = false
    }
}


//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
