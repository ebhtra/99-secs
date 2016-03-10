//
//  highScoreEditorVC.swift
//  textFieldTryouts
//
//  Created by Ethan Haley on 3/8/16.
//  Copyright © 2016 Ethan Haley. All rights reserved.
//

import UIKit

class HighScoreEditorVC: UIViewController, UITextFieldDelegate {
    
    // these 2 vars are passed from the presenting VC to this one
    var theScore: Int!
    var beaten: String!
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    @IBOutlet weak var nameEntryField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scoreLabel.text = "You scored \(theScore) points!"
        view.backgroundColor = UIColor.purpleColor()
        nameEntryField.becomeFirstResponder()
    }
    @IBAction func saveAndLeave(sender: UIButton) {
        
        ParseClient.sharedInstance.saveScoreAndName(nameEntryField.text! ?? "", score: theScore) { error in
            if let _ = error {
                let alert = UIAlertController(title: "Unable to save your high score", message: error!, preferredStyle: UIAlertControllerStyle.Alert)
                // dismiss the current VC once user dismisses the alert Controller
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {_ in self.dismissViewControllerAnimated(true, completion: nil)}))
                self.presentViewController(alert, animated: true, completion: nil)
                
            } else { // new high score was saved to parse, so delete old one
                
                ParseClient.sharedInstance.deleteFromParseTask("/", objectId: self.beaten) { result, error in
                   // if there is an error in deletion, the user does not need to know, nor does the result need to be handled by the app
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            }
        }
    }
    // MARK: - UITextField delegate methods:
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        if textField == nameEntryField {
            //store the unedited contents of textfield
            var entered: NSString = textField.text!
            
            //Allow edit to happen only if new text will be fewer than 14 chars long
            if (entered.length - range.length + (string as NSString).length) < 14 {
                entered = entered.stringByReplacingCharactersInRange(range, withString: string)
                return true
            }
            return false
        }
        return true
    }
}
