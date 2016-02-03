//
//  VueItineraireTableViewController.swift
//  tpg offline
//
//  Created by Alice on 16/01/2016.
//  Copyright © 2016 dacostafaro. All rights reserved.
//

import UIKit
import SwiftyJSON
import ChameleonFramework
import FontAwesomeKit
import SCLAlertView

class VueItineraireTableViewController: UITableViewController {
    
    var compteur = 0
    var listeBackgroundColor = [String:UIColor]()
    var listeColor = [String:UIColor]()
    var listeHeures = [NSDate]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dataCouleurs = NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("couleursLignes", ofType: "json")!)
        let couleurs = JSON(data: dataCouleurs!)
        for i in 0 ..< couleurs["colors"].count {
            listeBackgroundColor[couleurs["colors"][i]["lineCode"].string!] = UIColor(hexString: couleurs["colors"][i]["background"].string)
            listeColor[couleurs["colors"][i]["lineCode"].string!] = UIColor(hexString: couleurs["colors"][i]["text"].string)
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: FAKIonIcons.iosClockOutlineIconWithSize(20).imageWithSize(CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.Done, target: self, action: "rappel:")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return ItineraireEnCours.json["connections"][compteur]["sections"].count
    }
        
    func labelToImage(label: UILabel!) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(label.bounds.size, false, 0)
        label.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("itineraireCell", forIndexPath: indexPath) as! ItineraireTableViewCell
        
        var couleurTexte = UIColor.whiteColor()
        
        if ItineraireEnCours.json["connections"][compteur]["sections"][indexPath.row]["walk"].type == .Null {
            
            cell.ligneLabel.text = "Ligne " + ItineraireEnCours.json["connections"][compteur]["sections"][indexPath.row]["journey"]["name"].stringValue.characters.split(" ").map(String.init)[1]
            var icone = FAKIonIcons.androidTrainIconWithSize(21)
            switch ItineraireEnCours.json["connections"][compteur]["sections"][indexPath.row]["journey"]["categoryCode"].intValue {
            case 6:
                icone = FAKIonIcons.androidBusIconWithSize(21)
            
            case 4:
                icone = FAKIonIcons.androidBoatIconWithSize(21)
                
            case 9:
                icone = FAKIonIcons.androidSubwayIconWithSize(21)
                
            default:
                cell.backgroundColor = UIColor(red:0.93, green:0, blue:0.01, alpha:1)
                cell.ligneLabel.text = ItineraireEnCours.json["connections"][compteur]["sections"][indexPath.row]["journey"]["name"].stringValue
            }
            
            icone.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor())
            cell.iconeImageView.image = icone.imageWithSize(CGSize(width: 21, height: 21))
            let attributedString = NSMutableAttributedString(attributedString: icone.attributedString())
            attributedString.appendAttributedString(NSAttributedString(string: " " + ItineraireEnCours.json["connections"][compteur]["sections"][indexPath.row]["journey"]["to"].stringValue))
            cell.directionLabel.attributedText = attributedString

            if ItineraireEnCours.json["connections"][compteur]["sections"][indexPath.row]["journey"]["operator"].stringValue == "TPG" {
                cell.backgroundColor = listeBackgroundColor[ItineraireEnCours.json["connections"][compteur]["sections"][indexPath.row]["journey"]["name"].stringValue.characters.split(" ").map(String.init)[1]]
                couleurTexte = listeColor[ItineraireEnCours.json["connections"][compteur]["sections"][indexPath.row]["journey"]["name"].stringValue.characters.split(" ").map(String.init)[1]]!
                
                let labelPictoLigne = UILabel(frame: CGRect(x: 0, y: 0, width: 42, height: 24))
                labelPictoLigne.text = ItineraireEnCours.json["connections"][compteur]["sections"][indexPath.row]["journey"]["name"].stringValue.characters.split(" ").map(String.init)[1]
                labelPictoLigne.textAlignment = .Center
                labelPictoLigne.textColor = listeColor[ItineraireEnCours.json["connections"][compteur]["sections"][indexPath.row]["journey"]["name"].stringValue.characters.split(" ").map(String.init)[1]]!
                labelPictoLigne.layer.cornerRadius = labelPictoLigne.layer.bounds.height / 2
                labelPictoLigne.layer.borderColor = listeColor[ItineraireEnCours.json["connections"][compteur]["sections"][indexPath.row]["journey"]["name"].stringValue.characters.split(" ").map(String.init)[1]]!.CGColor
                labelPictoLigne.layer.borderWidth = 1
                let image = labelToImage(labelPictoLigne)
                for x in cell.iconeImageView.constraints {
                    if x.identifier == "iconeImageViewHeight" {
                        x.constant = 24
                    }
                }
                cell.iconeImageView.image = image
            }
            
            
            cell.ligneLabel.textColor = couleurTexte
            cell.directionLabel.textColor = couleurTexte
            cell.departLabel.textColor = couleurTexte
            cell.heureDepartLabel.textColor = couleurTexte
            cell.arriveeLabel.textColor = couleurTexte
            cell.heureArriveeLabel.textColor = couleurTexte
        }
        else {
            let icone = FAKIonIcons.androidWalkIconWithSize(42)
            icone.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor())
            cell.iconeImageView.image = icone.imageWithSize(CGSize(width: 42, height: 42))
            cell.ligneLabel.text = "Marche"
            cell.directionLabel.text = ItineraireEnCours.json["connections"][compteur]["sections"][indexPath.row]["walk"]["duration"].stringValue.characters.split(":").map(String.init)[1] + " minute(s)"
        }
        
        var icone = FAKIonIcons.logOutIconWithSize(21)
        icone.addAttribute(NSForegroundColorAttributeName, value: couleurTexte)
        var attributedString = NSMutableAttributedString(attributedString: icone.attributedString())
        attributedString.appendAttributedString(NSAttributedString(string: " " + ItineraireEnCours.json["connections"][compteur]["sections"][indexPath.row]["departure"]["station"]["name"].stringValue))
        cell.departLabel.attributedText = attributedString

        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        var timestamp = ItineraireEnCours.json["connections"][compteur]["sections"][indexPath.row]["departure"]["departureTimestamp"].intValue
        cell.heureDepartLabel.text = dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: Double(timestamp)))
        
        timestamp = ItineraireEnCours.json["connections"][compteur]["sections"][indexPath.row]["arrival"]["arrivalTimestamp"].intValue
        cell.heureArriveeLabel.text = dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: Double(timestamp)))
        
        icone = FAKIonIcons.logInIconWithSize(21)
        icone.addAttribute(NSForegroundColorAttributeName, value: couleurTexte)
        attributedString = NSMutableAttributedString(attributedString: icone.attributedString())
        attributedString.appendAttributedString(NSAttributedString(string: " " + ItineraireEnCours.json["connections"][compteur]["sections"][indexPath.row]["arrival"]["station"]["name"].stringValue))
        cell.arriveeLabel.attributedText = attributedString
        
        
        return cell
    }
    func rappel(sender: AnyObject!) {
        let alerte = SCLAlertView()
        alerte.addButton("5 min avant le premier départ") { 
            self.scheduleNotification(self.listeHeures[0], ligne: ItineraireEnCours.json["connections"][self.compteur]["sections"][0]["journey"]["name"].stringValue.characters.split(" ").map(String.init)[1], direction: ItineraireEnCours.json["connections"][self.compteur]["sections"][0]["journey"]["to"].stringValue)
            alerte.hideView()
            SCLAlertView().showSuccess("Vous serez notifié", subTitle: "Vous recevrez une notification 5 minutes avant le premier départ", closeButtonTitle: "OK", duration: 10)
        }
        alerte.addButton("5 min avant tout les départs") { 
            for (_, subJson) in ItineraireEnCours.json["connections"][self.compteur]["sections"] {
                if subJson["walk"].type == .Null {
                    self.scheduleNotification(self.listeHeures[0], ligne: subJson["journey"]["name"].stringValue.characters.split(" ").map(String.init)[1], direction: subJson["journey"]["to"].stringValue)
                }
            }
            alerte.hideView()
            SCLAlertView().showSuccess("Vous serez notifié", subTitle: "Vous recevrez une notification 5 minutes avant tout les départs", closeButtonTitle: "OK", duration: 10)
        }
        let icone = FAKIonIcons.iosClockIconWithSize(20)
        icone.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor())
        
        alerte.showNotice("Rappel", subTitle: "Combien de temps avant le départ du premier / de tout des départ(s) voulez vous être rappelé ?", closeButtonTitle: "Annuler", circleIconImage: icone.imageWithSize(CGSize(width: 20, height: 20)))
    }
    func scheduleNotification(time: NSDate, ligne: String, direction: String) {
        let now: NSDateComponents = NSCalendar.currentCalendar().components([.Hour, .Minute, .Second], fromDate: time)
        
        let cal = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let date = cal.dateBySettingHour(now.hour, minute: now.minute - 5, second: now.second, ofDate: time, options: NSCalendarOptions())
        let reminder = UILocalNotification()
        reminder.fireDate = date

        reminder.alertBody = "Le tpg de la ligne " + ligne + " en direction de " + direction + " va partir dans 5 minutes"
        reminder.soundName = "Sound.aif"
        
        UIApplication.sharedApplication().scheduleLocalNotification(reminder)
        
        print("Firing at \(now.hour):\(now.minute-5):\(now.second)")
    }
}