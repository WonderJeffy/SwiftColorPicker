///
//  @filename   ColorSquareView.swift
//  @package    
//  
//  @author     jeffy
//  @date       2023/5/31 
//  @abstract   
//
//  Copyright © 2023 and Confidential to jeffy All rights reserved.
//

import UIKit

public class ZYColorPickerSquareView: UIView {
    
    // MARK: - Properties
    
    /// 色调
    var hvalue: CGFloat = 0 {
        didSet {
            if hvalue > 1 {
                hvalue = 1
            }
            if hvalue < 0 {
                hvalue = 0
            }
        }
    }
    
    /// 饱和度
    var svvalue: CGPoint = .zero {
        didSet {
//            if !svvalue.equalTo(oldValue) {
//                setNeedsLayout()
//            }
        }
    }
    
    var curColor: UIColor?
    
    var colorChangedBlock: ((UIColor) -> Void)?
    
    private lazy var indicator: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 18, height: 18))
        view.backgroundColor = .clear
        // 阴影
        view.layer.shadowColor = UIColor(red: 0.13, green: 0.25, blue: 0.33, alpha: 0.2).cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 1)
        view.layer.shadowOpacity = 1.0
        view.layer.shadowRadius = 6
        view.layer.cornerRadius = 9
        
        let circleView = UIView(frame: view.bounds)
        circleView.layer.cornerRadius = 9
        circleView.layer.masksToBounds = true
        circleView.layer.borderColor = UIColor.white.cgColor
        circleView.layer.borderWidth = 2
        view.addSubview(circleView)
        
        return view
    }()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        addSubview(indicator)
        hvalue = 0
    }
    
    // MARK: - Private Methods
    
    public func updateContent() {
        let t_start = CFAbsoluteTimeGetCurrent()
        
        let image = createSaturationBrightnessSquareContentImageWithHue(Float(hvalue) * 360)
        let t_end = CFAbsoluteTimeGetCurrent()
        NSLog("++++ 耗时: %f", t_end - t_start);
        layer.contents = image
        curColor = UIColor(hue: hvalue, saturation: svvalue.x, brightness: svvalue.y, alpha: 1.0)
        if let colorChangedBlock = colorChangedBlock {
            colorChangedBlock(curColor!)
        }

    }
    
    private func indcatorView(with touch: UITouch?) {
        guard let touch = touch else { return }
        var p = touch.location(in: self)
        let w = bounds.width
        let h = bounds.height
        if p.x < 0 {
            p.x = 0
        }
        if p.x > w {
            p.x = w
        }
        if p.y < 0 {
            p.y = 0
        }
        if p.y > h {
            p.y = h
        }
        svvalue = CGPoint(x: p.x / w, y: 1.0 - p.y / h)
        
        let x = svvalue.x * bounds.width
        let y = bounds.height - svvalue.y * bounds.height
        indicator.center = CGPoint(x: x, y: y)
        curColor = UIColor(hue: hvalue, saturation: svvalue.x, brightness: svvalue.y, alpha: 1.0)
        if let colorChangedBlock = colorChangedBlock {
            colorChangedBlock(curColor!)
        }
    }
    
    // MARK: - Touch Handling
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        indcatorView(with: touches.first)
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        indcatorView(with: touches.first)
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        indcatorView(with: touches.first)
    }
    
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        indcatorView(with: touches.first)
    }
    
    // MARK: - Layout
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        let x = svvalue.x * bounds.width
        let y = bounds.height - svvalue.y * bounds.height
        indicator.center = CGPoint(x: x, y: y)
        updateContent()
    }
}
