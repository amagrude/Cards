//
//  DetailViewController.swift
//  Cards
//
//  Created by Paolo Cuscela on 23/10/17.
//

import UIKit

internal class DetailViewController: UIViewController {
    
    var blurView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight ))
    var detailViewController: UIViewController?
    var scrollView = UIScrollView()
    var originalFrame = CGRect.zero
    var snap = UIView()
    var card: Card!
    var delegate: CardDelegate?
    var closeButton = UIButton(type: UIButtonType.custom) as UIButton
    var isFullscreen: Bool = false
    
    //MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.snap = UIScreen.main.snapshotView(afterScreenUpdates: true)
        self.view.addSubview(blurView)
        self.view.addSubview(scrollView)
        if let detail = detailViewController?.view {
            
            scrollView.addSubview(detail)
            detail.autoresizingMask = .flexibleWidth
            detail.alpha = 0
        }
        
        blurView.frame = self.view.bounds
        
        scrollView.layer.backgroundColor = detailViewController?.view.backgroundColor?.cgColor ?? UIColor.white.cgColor
        scrollView.layer.cornerRadius = 0
        
        scrollView.delegate = self
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        
        let buttonImage = UIImage(named: "close-button")
        closeButton.setBackgroundImage(buttonImage, for: .normal)
        closeButton.addTarget(self, action: #selector(closeButtonAction), for: .touchUpInside)
        self.view.addSubview(closeButton)
    }

    override func viewWillAppear(_ animated: Bool) {
        scrollView.addSubview(card.backgroundIV)
        self.delegate?.cardWillShowDetailView?(card: self.card)
        self.delegate?.cardWillShow!(detailView: self.detailViewController, for: self.card)
    }

    override func viewDidAppear(_ animated: Bool) {
        self.view.insertSubview(snap, belowSubview: blurView)
        originalFrame = scrollView.frame
        
        if let detail = detailViewController?.view {
            
            detail.alpha = 1
            detail.frame = CGRect(x: 0,
                                  y: card.backgroundIV.bounds.maxY,
                                  width: scrollView.frame.width,
                                  height: detail.frame.height)
             
            scrollView.contentSize = CGSize(width: scrollView.bounds.width, height: detail.frame.maxY)
        }
        
        self.delegate?.cardDidShowDetailView?(card: self.card)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.delegate?.cardWillCloseDetailView?(card: self.card)
        self.delegate?.cardWillClose?(detailView: self.detailViewController, for: self.card)
        snap.removeFromSuperview()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.delegate?.cardDidCloseDetailView?(card: self.card)
        self.delegate?.cardDidClose?(detailView: self.detailViewController, for: self.card)
    }
    
    //MARK: - Layout & Animations for the content ( rect = Scrollview + card + detail )
    
    func layout(_ rect: CGRect, isPresenting: Bool, isAnimating: Bool = true, transform: CGAffineTransform = CGAffineTransform.identity){
        
        let buttonWidth = CGFloat(30)
        let buttonHeight = CGFloat(30)

        guard isPresenting else {
            scrollView.frame = rect.applying(transform)
            closeButton.frame = CGRect(x: rect.minX + rect.width - buttonWidth/2 - CGFloat(8),
                                       y: rect.minY + buttonHeight/2 + CGFloat(4),
                                       width: buttonWidth/2,
                                       height: buttonHeight/2).applying(transform)
            closeButton.alpha = CGFloat(0.0)
            card.backgroundIV.frame = scrollView.bounds
            card.layout(animating: isAnimating)
            return
        }
        
        if (!isPresenting && !isAnimating) {
            closeButton.isHidden = true
        }
        
        scrollView.frame.size = CGSize(width: LayoutHelper.XScreen(100), height: LayoutHelper.YScreen(100))
        scrollView.center = blurView.center
        scrollView.frame.origin.y = 0
        scrollView.frame = scrollView.frame.applying(transform)
        
        card.backgroundIV.frame.origin = scrollView.bounds.origin
        card.backgroundIV.frame.size = CGSize( width: scrollView.bounds.width,
                                            height: card.backgroundIV.bounds.height)
        card.layout(animating: isAnimating)
    
        if #available(iOS 11.0, *) {
            closeButton.frame = CGRect(x: self.view.frame.width - CGFloat(50),
                                       y: CGFloat(40)/2 + self.view.safeAreaInsets.top,
                                       width: buttonWidth,
                                       height: buttonHeight)
        } else {
            // Fallback on earlier versions
            closeButton.frame = CGRect(x: self.view.frame.width - CGFloat(50),
                                       y: CGFloat(40),
                                       width: buttonWidth,
                                       height: buttonHeight)
        }
        closeButton.alpha = CGFloat(1.0)
        closeButton.isHidden = false
    }
    
    @objc func closeButtonAction(sender: Any!)
    {
        scrollView.contentOffset.y = 0
        dismiss(animated: true, completion: nil)
    }
}


//MARK: - ScrollView Behaviour

extension DetailViewController: UIScrollViewDelegate {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let y = scrollView.contentOffset.y
        let origin = originalFrame.origin.y
        let currentOrigin = originalFrame.origin.y
        
        if (y<0  || currentOrigin > origin) {
            scrollView.frame.origin.y -= y/2
            scrollView.contentOffset.y = 0
        }
        
        card.delegate?.cardDetailIsScrolling?(card: card)
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let origin = originalFrame.origin.y
        let currentOrigin = scrollView.frame.origin.y
        let max = 4.0
        let min = 2.0
        var speed = Double(-velocity.y)
        
        if speed > max { speed = max }
        if speed < min { speed = min }
        
        //self.bounceIntensity = CGFloat(speed-1)
        speed = (max/speed*min)/10
        
        // Check to see if we should dismiss this viewcontroller
        guard (currentOrigin - origin) < 60 else {
            dismiss(animated: true, completion: nil)
            return
        }
        
        UIView.animate(withDuration: speed) { scrollView.frame.origin.y = self.originalFrame.origin.y }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        UIView.animate(withDuration: 0.1) { scrollView.frame.origin.y = self.originalFrame.origin.y }
    }
    
}


