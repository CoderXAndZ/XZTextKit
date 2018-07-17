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
    
    /**
     1、使用 TextKit 接管 UILabel 的底层实现
     2、使用正则表达式过滤 URL
     3、交互
     */
}

// 4.0 MARK: - 设置 TextKit 核心对象
private extension XZLabel {
   
    /// 4.1准备文本系统
    func prepareTextSystem() {
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
        
    }
    
}
