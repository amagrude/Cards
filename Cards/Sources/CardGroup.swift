//
//  CardGroup.swift
//  Cards
//
//  Created by Paolo on 08/10/17.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit

@IBDesignable open class CardGroup: Card {
    
    // SB Vars
    /**
     Text of the title label.
     */
    @IBInspectable public var title: String = "Welcome to XI Cards !" {
        didSet{
            titleLbl.text = title
        }
    }
    /**
     Font size the title label.
     */
    @IBInspectable public var titleSize: CGFloat = 24
    /**
     Text of the subtitle label.
     */
    @IBInspectable public var subtitle: String = "from the editors" {
        didSet{
            subtitleLbl.text = subtitle.uppercased()
        }
    }
    /**
     Font size the subtitle label.
     */
    @IBInspectable public var subtitleSize: CGFloat = 12
    /**
     Color for the card's labels.
     */
    @IBInspectable public var subTitleTextColor: UIColor = UIColor.gray
    /**
     Padding between subtitle and title.
     */
    @IBInspectable public var padding: CGFloat = 3.0
    /**
     Style for the blur effect.
     */
    @IBInspectable public var blurEffect: UIBlurEffectStyle = .extraLight {
        didSet{
            blurV.effect = UIBlurEffect(style: blurEffect)
        }
    }
    
    //Priv Vars
    var subtitleLbl = UILabel()
    var titleLbl = UILabel()
    var blurV = UIVisualEffectView()
    
    // View Life Cycle
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    override func initialize() {
        super.initialize()
        
        backgroundIV.addSubview(blurV)
        blurV.contentView.addSubview(subtitleLbl)
        blurV.contentView.addSubview(titleLbl)
    }
    
    override open func draw(_ rect: CGRect) {
        
        //Draw
        super.draw(rect)
        
        subtitleLbl.text = subtitle.uppercased()
        subtitleLbl.textColor = subTitleTextColor
        subtitleLbl.font = UIFont.systemFont(ofSize: subtitleSize, weight: .semibold)
        subtitleLbl.adjustsFontSizeToFitWidth = true
        subtitleLbl.minimumScaleFactor = 0.1
        subtitleLbl.lineBreakMode = .byTruncatingTail
        subtitleLbl.numberOfLines = 1
        
        titleLbl.textColor = textColor
        titleLbl.text = title
        titleLbl.font = UIFont.systemFont(ofSize: titleSize, weight: .bold)
        titleLbl.adjustsFontSizeToFitWidth = true
        titleLbl.minimumScaleFactor = 0.1
        titleLbl.lineBreakMode = .byTruncatingTail
        titleLbl.numberOfLines = 1
        
        let blur = UIBlurEffect(style: blurEffect)
        blurV.effect = blur
        
        layout()
    }
    
    override func layout(animating: Bool = true) {
        super.layout(animating: animating)
        
        let width = backgroundIV.bounds.width
        
        let labelWidth = width - insets
        let subTitleHeight = subtitleLbl.frame.height
        
        subtitleLbl.frame = CGRect(x: insets,
                                   y: insets,
                                   width: labelWidth,
                                   height: subTitleHeight)
        subtitleLbl.sizeToFit()

        let titleHeight = subtitleLbl.frame.height
        titleLbl.frame = CGRect(x: insets,
                                y: subtitleLbl.frame.maxY + padding,
                                width: labelWidth,
                                height: titleHeight)
        titleLbl.sizeToFit()
        
        let blurHeight = titleLbl.frame.maxY + (padding * 3.0) + insets
        
        blurV.frame = CGRect(x: 0,
                             y: 0,
                             width: width,
                             height: blurHeight)
    }

}


