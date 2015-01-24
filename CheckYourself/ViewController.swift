//
//  ViewController.swift
//  CheckYourself
//
//  Created by Gabriel Triggs on 1/24/15.
//  Copyright (c) 2015 Gabriel Triggs. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    var currentBloodAlcoholContent: Double = 0.0 {
        didSet {
            BACLabel.text = String(format: "%01.3f", currentBloodAlcoholContent)
            updateTime()
            if (currentBloodAlcoholContent < 0.001) {
                //set timestamp to nil
                var defaults = NSUserDefaults.standardUserDefaults()
                defaults.setObject(nil, forKey: "timestamp")
                countdownLabel.text? = "Too late."
            }
        }
    }
    
    var timer: NSTimer!


    @IBOutlet weak var BACLabel: UILabel!
    @IBOutlet weak var countdownLabel: UILabel!
    
    @IBAction func pressDrinkButton(sender: AnyObject) {
        var defaults = NSUserDefaults.standardUserDefaults()
        
        
        let timestamp = defaults.objectForKey("timestamp") as? NSDate
            
        if timestamp == nil {
            defaults.setObject(NSDate(), forKey: "timestamp")
        }
        
        let count = defaults.integerForKey("count")
        defaults.setInteger(count + 1, forKey: "count")
        
        updateBAC()
    }
    
    @IBAction func reset(sender: AnyObject) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(nil, forKey: "timestamp")
        defaults.setInteger(0, forKey: "count")
        BACLabel.text? = "0.000"
        countdownLabel.text? = "Too late."
    }
    
    override func viewDidAppear(animated: Bool) {
        timer = NSTimer(timeInterval: 10.0, target: self, selector: "updateBAC", userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func calculateBAC(#standardDrinks: Int, sex: String, bodyWeight_kg: Double, drinkingPeriod_hrs: Double) -> Double {
        // 0.806 * SD * 1.2
        // ---------------- - (MR * DP)
        //     BW * Wt
        //
        // where
        //  SD = number of standard drinks (10 g ethanol each)
        //  BW = body water constant (men -> 0.58, women -> 0.49)
        //  Wt = body weight (kg)
        //  MR = metabolism constant (men -> 0.015, women -> 0.017)
        //  DP = drinking period (hrs)
        //
        // pulled from wikipedia page on BAC
        
        var BAC = 0.806 * Double(standardDrinks) * 1.2
        BAC /= sex.caseInsensitiveCompare("f") == NSComparisonResult.OrderedSame ? 0.49 : 0.58
        BAC /= bodyWeight_kg
        var n = (sex.caseInsensitiveCompare("f") == NSComparisonResult.OrderedSame ? 0.017 : 0.015) * drinkingPeriod_hrs
        BAC -= n
        
        // don't let BAC go negative (or below displayable value)
        if BAC < 0.001 {
            BAC = 0
        }
        
        return BAC
    }
    
    func updateBAC() {
        var defaults = NSUserDefaults.standardUserDefaults()
        let count = defaults.integerForKey("count")
        if count == 0 {
            return
        }
        let sex = defaults.objectForKey("sex") as String!
        let weight = defaults.doubleForKey("weight")
        
        let now = NSDate()
        let timestamp = defaults.objectForKey("timestamp") as NSDate!
        let hours = Double(now.timeIntervalSinceDate(timestamp)) / 3600.0

        var BAC = calculateBAC(standardDrinks: count, sex: sex, bodyWeight_kg: weight, drinkingPeriod_hrs: hours)
        currentBloodAlcoholContent = BAC
    }
    
    func updateTime() {
        if currentBloodAlcoholContent != 0 {
            let numHours = currentBloodAlcoholContent / 0.015
            NSLog("%@", "\(numHours)")
            let hourStr = String(format: "%02.0f", numHours)
            NSLog("%@", hourStr)
            let minStr = String(format: "%02.0f", (numHours % 1) * 60)
            countdownLabel.text? = "\(hourStr):\(minStr)"
        } else {
            countdownLabel.text? = "Too late."
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        var defaults = NSUserDefaults.standardUserDefaults()
        if defaults.objectForKey("sex") == nil {
            defaults.setObject("m", forKey: "sex")
        }
        if defaults.objectForKey("weight") == nil {
            defaults.setDouble(80, forKey: "weight")
        }
        let count = defaults.integerForKey("count")
        updateBAC()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

