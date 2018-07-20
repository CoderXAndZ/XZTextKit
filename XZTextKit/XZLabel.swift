//
//  XZLabel.swift
//  XZTextKit
//
//  Created by admin on 2018/7/17.
//  Copyright © 2018年 XZ. All rights reserved.
//

import UIKit

@objc
public protocol XZLabelDelegate: NSObjectProtocol {
    /// 选中链接文本
    ///
    /// - parameter label: label
    /// - parameter text:  选中的文本
    @objc optional func labelDidSelectedLinkText(label: XZLabel, text: String)
}

public class XZLabel: UILabel {

    public var linkTextColor = UIColor.blue
    public var selectedBgColor = UIColor.lightGray
    public weak var delegate: XZLabelDelegate?
    
    
    private lazy var linkRanges = [NSRange]()
    private var selectedRange: NSRange?
    
    // 3.1、接管文本 MARK: - 构造函数
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        prepareTextSystem()
    }
    
    // 7.1 MARK: --- 交互
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // 1.获取用户点击的位置
        guard let location = touches.first?.location(in: self) else {
            return
        }
        
        print("点我了 \(location)")
        
        // 2.获取当前点中字符的索引
        let idx = layoutManager.glyphIndex(for: location, in: textContainer)
        
        // 3. 39 -- 06：06
        
    }
    
    // 3.2 禁止我们用xib使用
    required public init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
        // 都用，
        super.init(coder: aDecoder)
        
        prepareTextSystem()
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        // 2、指定绘制文本的区域:不做排他路径，直接等于 bounds.size
        textContainer.size = bounds.size
        
    }
    
    // 1、MARK: - TextKit 的核心对象
    // 属性文本存储
    private lazy var textStorage = NSTextStorage()
    // 负责文本'字形'布局
    private lazy var layoutManager = NSLayoutManager()
    // 设定文本绘制的范围 textContainer通常放在layoutSubViews
    private lazy var textContainer = NSTextContainer()
    
    // 5.0
    /**
     1、使用 TextKit 接管 UILabel 的底层实现 - '绘制' textStorage 的文本内容
     2、使用正则表达式过滤 URL，设置 URL 的特殊显示
     3、交互
     */
    
    // 5.1 绘制文本 drawText drawRect
    public override func drawText(in rect: CGRect) {
        // 在一定区域绘制
//        super.drawText(in: rect) 调用这个就达不到接管的效果了
        // 这个时候textStorage已经有内容了
        let range = NSRange(location: 0, length: textStorage.length)
        
        // iOS中绘制工作是类似于油画似的，后绘制的内容，会把之前绘制的内容覆盖！尽量避免使用带透明色的颜色，会严重影响性能！
        // 6.2 绘制背景 --- 不能放在绘制字形下面
        layoutManager.drawBackground(forGlyphRange: range, at: CGPoint())
        
        // 5.1 绘制字形
        // layoutManager负责绘制  Glyphs意思是字形 at: CGPoint() 从原点开始绘制
        layoutManager.drawGlyphs(forGlyphRange: range, at: CGPoint())
        // 运行之后，发现位置变了，置顶显示了 -- UILabel默认不能实现垂直顶部对齐，使用TextKit可以。
    }
}

// 4.0 MARK: - 设置 TextKit 核心对象
private extension XZLabel {
   
    /// 4.1准备文本系统
    func prepareTextSystem() {
        // 7.0
        // 0.开启用户交互
        isUserInteractionEnabled = true
        
        // 4.1
        // 1.准备文本内容
        prepareTextContent()
        // 2.设置对象的关系
        textStorage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(textContainer)
    }
    
    // 4.2准备文本内容 -- 使用textStorage接管label的内容
    func prepareTextContent() {
        
        if let attributedText = attributedText {
            textStorage.setAttributedString(attributedText)
        }else if let text = text {
            textStorage.setAttributedString(NSAttributedString(string: text))
        }else {
            textStorage.setAttributedString(NSAttributedString(string: ""))
        }
        
        // 6.1 遍历范围数组，设置 URL 文字的属性
        print(urlRanges)
        
        for r in urlRanges ?? [] {
            textStorage.addAttributes(
                [
                    NSAttributedStringKey.foregroundColor: UIColor.red,
                    NSAttributedStringKey.backgroundColor: UIColor.init(white: 0.9, alpha: 1)
                ], range: r)
        }
    }
    
}

// MARK: -- 6.0 正则表达式函数
private extension XZLabel {
    
    /// 返回 textStorage 中的 URL range数组
    var urlRanges: [NSRange]? {
        // 1.正则表达式
        let patten = "[a-zA-Z]*://[a-zA-Z0-9/\\.]*"
        
        guard let regx = try? NSRegularExpression(pattern: patten, options: []) else {
            return nil;
        }
        
        // 2.多重匹配
        let matches = regx.matches(in: textStorage.string, options: [], range: NSRange(location: 0, length: textStorage.length))
        // 3.遍历数组，生成 range 的数组
        var ranges = [NSRange]()
        
        for m in matches {
            ranges.append(m.range(at: 0))
        }
        return ranges
    }
    
}
