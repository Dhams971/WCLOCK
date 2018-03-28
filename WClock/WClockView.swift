//
//  WClock.swift
//  WClock
//
//  Created by Dharmendra.Solanki on 28/03/18.
//  Copyright © 2018 Dharmendra.Solanki. All rights reserved.
//

import UIKit

@IBDesignable
open class WClockView: UIView {
    
    typealias Coordinate = CGPoint
    
    var backgroundImage: UIImage?
    
    var hourHandLayer: CALayer?
    var minuteHandLayer: CALayer?
    var secondHandLayer: CALayer?
    var screwShapeLayer: CAShapeLayer?
    
    @IBInspectable var backColor: UIColor?
    @IBInspectable var innerCircleColor: UIColor?
    @IBInspectable var tickColor: UIColor?
    @IBInspectable var hourHandColor: UIColor?
    @IBInspectable var minuteHandColor: UIColor?
    @IBInspectable var secondHandColor: UIColor?
    
    let Radians: CGFloat = 6.28 // 360 Degree = 6.28 Radians
    
    let centerXY: CGFloat = 0.5
    let outerCircleRadius: CGFloat = 0.45
    let innerCircleRadius: CGFloat = 0.30
    
    let hourHandHeight: CGFloat = 0.25
    let hourHandWidth: CGFloat  = 0.012
    
    let minuteHandHeight: CGFloat = 0.30
    let minuteHandWidth: CGFloat  = 0.008
    
    let secondHandHeight: CGFloat = 0.35
    let secondHandWidth: CGFloat  = 0.006
    
    var hourHandAngle: CGFloat = 0.0
    var minuteHandAngle: CGFloat = 0.0
    var secondHandAngle: CGFloat = 0.0
    
    var timer: Timer?
    
    var timeZone: TimeZone? {
        didSet {
            initialHandPositions()
        }
    }
    
    // Init Methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        timeZone = TimeZone(abbreviation: "IST")!
        initDefaults()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open func initDefaults() {
        backColor = UIColor.clear
        tickColor = UIColor.black
        
        hourHandColor = UIColor.black
        minuteHandColor = UIColor.black
        secondHandColor = UIColor.black
    }
    
    open func initialHandPositions() {
        let curDate = Date()
        var calender = Calendar.current
        calender.timeZone = timeZone ?? TimeZone(abbreviation: "IST")!
        
        let components = calender.dateComponents([.hour, .minute, .second], from: curDate)
        
        hourHandAngle = 0.52333333 * CGFloat(components.hour!) + 0.00872222
            * CGFloat(components.minute!) // 0.52333333 = Radians/12, 0.00872222 = 0.5233333/60
        minuteHandAngle = 0.10466667 * CGFloat(components.minute!) + 0.0017444445
            * CGFloat(components.second!) // 0.10466667 = Radians/60, 0.0017444445 = 0.10466667/60
        secondHandAngle = 0.10466667 * CGFloat(components.second!)
        
        hourHandLayer!.transform = CATransform3DMakeRotation(hourHandAngle, 0, 0.0, 1.0)
        minuteHandLayer!.transform = CATransform3DMakeRotation(minuteHandAngle, 0, 0.0, 1.0)
        secondHandLayer!.transform = CATransform3DMakeRotation(secondHandAngle, 0, 0.0, 1.0)
    }
    
    override open func setNeedsDisplay() {
        hourHandLayer?.removeFromSuperlayer()
        minuteHandLayer?.removeFromSuperlayer()
        secondHandLayer?.removeFromSuperlayer()
        screwShapeLayer?.removeFromSuperlayer()
        
        hourHandLayer   = nil
        minuteHandLayer = nil
        secondHandLayer = nil
        screwShapeLayer = nil
        timer?.invalidate()
        
        super.setNeedsDisplay()
    }
    
}

// MARK:- Draw
extension WClockView {
    
    override open func draw(_ rect: CGRect) {
        // Drawing code
        if backgroundImage == nil {
            // Begin image context
            UIGraphicsBeginImageContextWithOptions(rect.size, true, UIScreen.main.scale)
            
            if let curContext = UIGraphicsGetCurrentContext() {
                // Scale current graphics context
                curContext.scaleBy(x: rect.size.width, y: rect.size.height)
                curContext.setFillColor(UIColor.white.cgColor)
                curContext.fill(rect)
                
                // Draw background image
                drawBackground(in: curContext)
                
                // Draw Ticks
                drawTicks(in: curContext)
                
                // Save context as image
                backgroundImage = UIGraphicsGetImageFromCurrentImageContext()
            }
            // End image context
            UIGraphicsEndImageContext()
        }
        backgroundImage?.draw(in: rect)
        
        if secondHandLayer == nil {
            drawSecondHand(in: rect)
            drawMinuteHand(in: rect)
            drawHourHand(in: rect)
            drawScrew(in: rect)
        }
        
        initialHandPositions()
        rotateSecondHandWithAnimation()
    }
    
    func drawBackground(in context: CGContext) {
        let outerCircleXY = centerXY - outerCircleRadius
        context.addEllipse(in: CGRect(x: outerCircleXY,
                                      y: outerCircleXY,
                                      width: outerCircleRadius * 2,
                                      height: outerCircleRadius * 2))
        context.setFillColor(backColor!.cgColor)
        context.setShadow(offset: CGSize(width: 0.4,
                                         height: 0.4),
                          blur: 0.3,
                          color: UIColor.lightGray.cgColor)
        context.fillPath()
        
        let innerCircleXY = centerXY - innerCircleRadius
        context.addEllipse(in: CGRect(x: innerCircleXY,
                                      y: innerCircleXY,
                                      width: innerCircleRadius * 2,
                                      height: innerCircleRadius * 2))
        context.setFillColor(innerCircleColor!.cgColor)
        context.fillPath()
    }
    
    func drawTicks(in context: CGContext) {
        let numberOfTicks = 60
        
        context.saveGState()
        rotate(context: context, from: Coordinate(x: centerXY, y: centerXY), with: (225/180.0) * .pi)
        
        // Context area is CGPoint(0.0,0.0) to CGPoint(1.0,1.0)
        for i in 0..<numberOfTicks {
            if i % 5 == 0 {
                context.move(to: Coordinate(x: 0.76, y: 0.76))
            } else {
                context.move(to: Coordinate(x: 0.78, y: 0.78))
            }
            
            context.addLine(to: Coordinate(x: 0.80, y: 0.80))
            context.setLineWidth(0.005)
            context.setAllowsAntialiasing(true)
            context.setStrokeColor(tickColor!.cgColor)
            context.strokePath()
            
            // rotate context 6 degrees from center
            rotate(context: context, from: Coordinate(x: centerXY, y: centerXY), with: 0.10466667)
        }
        context.restoreGState()
    }
    
    func drawHourHand(in rect: CGRect) {
        let hourHandShapeLayer = CAShapeLayer.initLayerWithDefaults()
        let handPath = UIBezierPath()
        
        handPath.move(to: points(x: CGFloat(centerXY - hourHandWidth), y: centerXY, in: rect))
        handPath.addLine(to: points(x: centerXY + hourHandWidth, y: centerXY, in: rect))
        handPath.addLine(to: points(x: centerXY, y: centerXY - hourHandHeight, in: rect))
        handPath.close()
        
        hourHandShapeLayer.path = handPath.cgPath
        hourHandShapeLayer.fillColor = hourHandColor!.cgColor
        hourHandShapeLayer.strokeColor = hourHandColor!.cgColor
        hourHandShapeLayer.lineWidth = 1.2
        
        hourHandLayer = CALayer()
        hourHandLayer?.frame = self.bounds
        hourHandLayer?.addSublayer(hourHandShapeLayer)
        layer.addSublayer(hourHandLayer!)
    }
    
    func drawMinuteHand(in rect: CGRect) {
        let minuteHandShapeLayer = CAShapeLayer.initLayerWithDefaults()
        let handPath = UIBezierPath()
        
        handPath.move(to: points(x: CGFloat(centerXY - minuteHandWidth), y: centerXY, in: rect))
        handPath.addLine(to: points(x: centerXY + minuteHandWidth, y: centerXY, in: rect))
        handPath.addLine(to: points(x: centerXY, y: centerXY - minuteHandHeight, in: rect))
        handPath.close()
        
        minuteHandShapeLayer.path = handPath.cgPath
        minuteHandShapeLayer.fillColor = minuteHandColor!.cgColor
        minuteHandShapeLayer.strokeColor = minuteHandColor!.cgColor
        minuteHandShapeLayer.lineWidth = 1.2
        
        minuteHandLayer = CALayer()
        minuteHandLayer?.frame = self.bounds
        minuteHandLayer?.addSublayer(minuteHandShapeLayer)
        layer.addSublayer(minuteHandLayer!)
    }
    
    func drawSecondHand(in rect: CGRect) {
        let secondHandShapeLayer = CAShapeLayer.initLayerWithDefaults()
        let handPath = UIBezierPath()
        
        handPath.move(to: points(x: CGFloat(centerXY - secondHandWidth), y: centerXY, in: rect))
        handPath.addLine(to: points(x: centerXY + secondHandWidth, y: centerXY, in: rect))
        handPath.addLine(to: points(x: centerXY, y: centerXY - secondHandHeight, in: rect))
        handPath.close()
        
        secondHandShapeLayer.path = handPath.cgPath
        secondHandShapeLayer.fillColor = secondHandColor!.cgColor
        secondHandShapeLayer.strokeColor = secondHandColor!.cgColor
        secondHandShapeLayer.lineWidth = 1.2
        
        secondHandLayer = CALayer()
        secondHandLayer?.frame = self.bounds
        secondHandLayer?.addSublayer(secondHandShapeLayer)
        layer.addSublayer(secondHandLayer!)
    }
    
    func drawScrew(in rect: CGRect) {
        
        screwShapeLayer = CAShapeLayer.initLayerWithDefaults()
        screwShapeLayer?.bounds = CGRect(x: centerXY - 0.05,
                                         y: centerXY - 0.05,
                                         width: 0.1 * rect.width,
                                         height: 0.1 * rect.height)
        
        screwShapeLayer?.path = UIBezierPath.init(ovalIn: screwShapeLayer!.bounds).cgPath
        screwShapeLayer?.position = points(x: centerXY, y: centerXY, in: rect)
        screwShapeLayer?.fillColor = UIColor.darkGray.cgColor
        
        layer.addSublayer(screwShapeLayer!)
    }
    
}

// MARK:- Helpers
extension WClockView {
    
    /**
     - Important: rotates the context from center to draw ticks
     __________
     
     - Parameters:
     - context: drawing space or canvas
     - center: center(x,y) points of context
     - angle: radian value
     */
    func rotate(context: CGContext, from center: Coordinate, with angle: CGFloat) {
        context.translateBy(x: center.x, y: center.y)
        context.rotate(by: angle)
        context.translateBy(x: -center.x, y: -center.y)
    }
    
    /**
     - Parameters:
     - x: x points in rectangle area
     - y: y points in rectangle area
     - rect: rectangle area of *clockview*
     - Returns: (x,y) points in rectangle area of **clockView**
     */
    func points(x: CGFloat, y: CGFloat, in rect: CGRect) -> Coordinate {
        return Coordinate(x: x * rect.width, y: y * rect.height)
    }
    
}

// MARK:- Clock Animations
extension WClockView {
    
    func rotateSecondHandWithAnimation() {
        timer = Timer.scheduledTimer(timeInterval: 1.0,
                                     target: self,
                                     selector: #selector(rotateSecHand),
                                     userInfo: nil,
                                     repeats: true)
    }
    
    @objc func rotateSecHand() {
        hourHandAngle += 0.000029074075 // (Radians / 60*60*60)
        hourHandLayer!.transform = CATransform3DMakeRotation(hourHandAngle, 0, 0.0, 1.0)
        
        minuteHandAngle += 0.0017444445 // (Radians / 60*60)
        minuteHandLayer!.transform = CATransform3DMakeRotation(minuteHandAngle, 0, 0.0, 1.0)
        
        secondHandAngle += 0.10466667  // (Radians / 60)
        secondHandLayer!.transform = CATransform3DMakeRotation(secondHandAngle, 0, 0.0, 1.0)
    }
    
}

// Mark:- Draw Shadow
extension CAShapeLayer {
    
    class func initLayerWithDefaults() -> CAShapeLayer {
        let shapeLayer = CAShapeLayer()
        shapeLayer.shadowColor = UIColor.black.cgColor
        shapeLayer.shadowOffset = CGSize(width: -2.0, height: -2.0)
        shapeLayer.shadowOpacity = 0.2
        shapeLayer.shadowRadius = 2.0
        shapeLayer.allowsEdgeAntialiasing = true
        return shapeLayer
    }
    
}
