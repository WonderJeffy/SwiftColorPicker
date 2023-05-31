import UIKit

public class ZYInputCanvasCustomColorView: UIView {
    
    var squareView: ZYColorPickerSquareView!
    var colorBar: UIImageView!
    var indicator: UIView!
    var indicatorMoving = false
    var colorChangedBlock: ((UIColor) -> Void)?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        let width = frame.size.width
        
        let line = UIView(frame: CGRect(x: 0, y: 40, width: width, height: 10))
        addSubview(line)
        
        let squareView = ZYColorPickerSquareView(frame: CGRect(x: 20, y: 80, width: width - 40, height: 103))
        squareView.layer.cornerRadius = 6
        squareView.layer.masksToBounds = true
        squareView.colorChangedBlock = { [weak self] color in
            line.backgroundColor = color
            self?.colorChangedBlock?(color)
        }
        
        self.squareView = squareView
        addSubview(self.squareView)
        
        colorBar = UIImageView(frame: CGRect(x: 20, y: 200, width: width - 40, height: 8))
        colorBar.layer.cornerRadius = 4
        colorBar.layer.masksToBounds = true
        var hsv: [Float] = [0.0, 1.0, 1.0]
        let image = createHSVBarContentImage(barComponentIndex: .hue, hsv: &hsv)
        colorBar.image = UIImage(cgImage: image!)
        addSubview(colorBar)
        
        indicator = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 16))
        indicator.backgroundColor = .clear
        // Shadow
        indicator.layer.shadowColor = UIColor(red: 0.13, green: 0.25, blue: 0.33, alpha: 0.2).cgColor
        indicator.layer.shadowOffset = CGSize(width: 0, height: 1)
        indicator.layer.shadowOpacity = 1.0
        indicator.layer.shadowRadius = 6
        indicator.layer.cornerRadius = 8
        let circleView = UIView(frame: indicator.bounds)
        circleView.backgroundColor = .white
        circleView.layer.cornerRadius = 8
        circleView.layer.masksToBounds = true
        indicator.addSubview(circleView)
        addSubview(indicator)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let p = touch.location(in: self)
            if colorBar.frame.contains(p) || indicator.frame.contains(p) {
                indicatorMoving = true
                indcatorView(with: touch)
            }
        }
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if indicatorMoving, let touch = touches.first {
            indcatorView(with: touch)
        }
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        indicatorMoving = false
    }
    
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        indicatorMoving = false
    }
    
    func indcatorView(with touch: UITouch) {
        let p = touch.location(in: colorBar)
        let hvalue = p.x / colorBar.frame.width
        squareView.hvalue = hvalue
        __setHvalue(hvalue)
    }
    
    // MARK: - Public
    
    func setColorChangedBlock(_ block: ((UIColor) -> Void)?) {
        colorChangedBlock = block
        squareView.colorChangedBlock = block
    }
    
    public func setColor(_ color: UIColor) {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        var h: CGFloat = 0, s: CGFloat = 0, v: CGFloat = 0
        (h, s, v) = RGBToHSV(r, g, b)
        squareView.svvalue = CGPoint(x: s, y: v)
        squareView.hvalue = h
        __setHvalue(h)
    }
    
    // MARK: - Private
    
    private func __setHvalue(_ hvalue: CGFloat) {
        var hvalue = hvalue
        if hvalue > 1 {
            hvalue = 1
        }
        if hvalue < 0 {
            hvalue = 0
        }
        let x = hvalue * colorBar.frame.width
        indicator.center = CGPoint(x: colorBar.frame.minX + x, y: colorBar.frame.midY)
        squareView.updateContent()
    }
    
}

