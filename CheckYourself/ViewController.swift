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

    @IBOutlet weak var beerButton: UIButton!
    @IBOutlet weak var liquorButton: UIButton!
    @IBOutlet weak var wineButton: UIButton!
    @IBOutlet weak var BACButton: UIButton!
    @IBOutlet weak var statsButton: UIButton!
    @IBOutlet weak var listButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    
    @IBAction func pressBACButton(sender: AnyObject) {
        logButtonPress(sender)
    }
    
    @IBAction func pressBeerButton(sender: AnyObject) {
        logButtonPress(sender)
        insertDrinkRecord(beverage: "beer")
    }
    
    @IBAction func pressClearButton(sender: AnyObject) {
        logButtonPress(sender)
        promptToClearDrinkEntries()
    }
    
    @IBAction func pressLiquorButton(sender: AnyObject) {
        logButtonPress(sender)
        insertDrinkRecord(beverage: "liquor")
    }
    
    @IBAction func pressListButton(sender: AnyObject) {
        logButtonPress(sender)
        dumpDrinkLog()
    }
    
    @IBAction func pressStatsButton(sender: AnyObject) {
        logButtonPress(sender)
    }
    
    @IBAction func pressWineButton(sender: AnyObject) {
        logButtonPress(sender)
        insertDrinkRecord(beverage: "wine")
    }
    
    func clearDrinkEntries() {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        let fetchRequest = NSFetchRequest(entityName: "Drink")
        fetchRequest.includesPropertyValues = false
        var error: NSError?
        let fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as [NSManagedObject]?
        
        if let results = fetchedResults {
            for drinkRecord in results {
                managedContext.deleteObject(drinkRecord)
            }
            
            var error: NSError?
            if !managedContext.save(&error) {
                NSLog("%@", "Unable to delete records - \(error?.userInfo).")
            } else {
                NSLog("%@", "Deleted all drink entries.")
            }
        }
    }
    
    func dumpDrinkLog() {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        let fetchRequest = NSFetchRequest(entityName: "Drink")
        var error: NSError?
        let fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as [NSManagedObject]?
        
        if let results = fetchedResults {
            let timestampFormatter = NSDateFormatter()
            timestampFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
            timestampFormatter.timeStyle = NSDateFormatterStyle.MediumStyle
            
            var timestamp: String!
            var beverage: String!
            for drinkRecord in results {
                timestamp = timestampFormatter.stringFromDate(drinkRecord.valueForKey("timestamp") as NSDate)
                beverage = drinkRecord.valueForKey("beverage") as String?
                NSLog("%@", "\(beverage): \(timestamp)")
            }
        } else {
            NSLog("%@", "Error reading drink records - \(error?.userInfo)")
        }
    }
    
    func insertDrinkRecord(#beverage: String) {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        let entity = NSEntityDescription.entityForName("Drink", inManagedObjectContext: managedContext)
        let drink = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        
        drink.setValue(beverage, forKey: "beverage")
        let timestamp = NSDate()
        drink.setValue(timestamp, forKey: "timestamp")
        
        var error: NSError?
        if !managedContext.save(&error) {
            NSLog("%@", "Could not save \(error) - \(error?.userInfo).")
        } else {
            NSLog("%@", "Inserted \(beverage) entry.")
        }
    }
    
    func logButtonPress(sender: AnyObject) {
        let button = sender as UIButton
        let buttonTitleLabel = button.titleLabel as UILabel!
        let buttonTitleLabelText = buttonTitleLabel.text as String!
        
        NSLog("%@", "User pressed \(buttonTitleLabelText) button.")
    }
    
    func promptToClearDrinkEntries() {
        var alert = UIAlertController(title: "Are you sure?", message: "All drink records will be deleted.", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Delete Records", style: .Default, handler: { action in
            self.clearDrinkEntries()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { action in
            NSLog("%@", "Canceled deletion.")
        }))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

