///
//  @filename   ViewController.swift
//  @package    Example
//
//  @author     jeffy
//  @date       2023/5/11
//  @abstract
//
//  Copyright © 2023 and Confidential to jeffy All rights reserved.
//

import UIKit
import SwiftColorPicker

class ViewController: UIViewController {
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let picker = ZYInputCanvasCustomColorView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
        picker.setColor(UIColor.orange)
        view.addSubview(picker)
        
        
        var btn = UIButton(type: .system)
        btn.backgroundColor = .randomPastelColor
        btn.setTitle("Google", for: .normal)
        btn.frame = CGRect(x: 180, y: 300, width: 100, height: 40)
        btn.addTarget(self, action: #selector(btnClick), for: .touchUpInside)
        view.addSubview(btn)
    }
    
    @objc func btnClick() {

        translateText(text: "greeting") { result in
            print(result ?? "failed")
        }
    }
}

extension UIColor {
    static var randomPastelColor: UIColor {
        return UIColor(
            hue: .random(in: 0 ... 1),
            saturation: 0.4,
            brightness: 0.9,
            alpha: 1.0
        )
    }
}


func translateText(text: String, completion: @escaping (String?) -> Void) {
    let urlString = "https://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl=zh-CN&dt=t&q=\(text)"
    guard let url = URL(string: urlString) else {
        completion(nil)
        return
    }
    let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
        guard let data = data, error == nil else {
            completion(nil)
            return
        }
        do {
//            let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [[[String]]]
            let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [Any]
            let json1 = json?.first as? [Any]
            let json2 = json1?.first as? [Any]
            let translatedText = json2?.first as? String
            if let result = translatedText {
                completion(result)
            } else {
                completion(nil)
            }
        } catch {
            completion(nil)
        }
    }
    task.resume()
}
