//
//  ViewController.swift
//  textFieldTryouts
//
//  Created by Ethan Haley on 4/21/15.
//  Copyright (c) 2015 Ethan Haley. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var textViewer: UITextField!
    @IBOutlet weak var infoLabel: UILabel!
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    
    let gameOver = "GAME OVER. Tap here for new game."
    //any set of letters can be used here, but I capitalize later for English
    let alphabet = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o",
        "p","q","r","s","t","u","v","w","x","y","z"]
    let prompt = "Tap here to begin"
    let nextWord = "Tap here for next word"
    let info = "Tap on the \"word\" when you know what letter isn't in it.\nThen type that letter and hit the return key."
    var puzzle = ""
    var solution = ""
    var bonusPts = 0
    var secs = 99
    var timer = NSTimer()
    var paused = true
    var score = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.greenColor()
        textViewer.text = prompt
        buildRandomWord()
        textViewer.delegate = self
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("hideWord"), name: UIApplicationDidEnterBackgroundNotification, object: nil)
       
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("unhideWord"), name: UIApplicationDidBecomeActiveNotification, object: nil)
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationDidEnterBackgroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationDidBecomeActiveNotification, object: nil)
    }
    
    // unhide word if hidden
    func unhideWord() {
        textViewer.hidden = false
    }
    
    // hide word to thwart cheaters
    func hideWord() {
        textViewer.hidden = true
    }
    
    func countdown() {
        
        if !paused {
            secs--
            timerLabel.text = "Time left:  \(secs)"
            
            if secs == 15 {
                view.backgroundColor = UIColor.magentaColor()
            }
            if secs == 0 {
                view.backgroundColor = UIColor.cyanColor()
                buildRandomWord()
                timer.invalidate()
                paused = true
                secs = 99
                score = 0
                infoLabel.text = ""
                textViewer.text = gameOver
            }
        }
    }
   
    func startPlay() {
        if secs > 15 {
            view.backgroundColor = UIColor.greenColor()
        }
        textViewer.text = puzzle
        infoLabel.text = info
        paused = false
    }
    
    func buildRandomWord() {
        let numLet = alphabet.count
        var indices = [Int](count: numLet, repeatedValue: 0)
        for i in 0..<numLet {
            indices[i] = i
        }
        for i in 0..<numLet {
            let rand = Int(arc4random()/3) % (numLet - i) + i
            let temp = indices[i]
            indices[i] = indices[rand]
            indices[rand] = temp
        }
        var word = ""
        let answerIndex = indices.removeLast()
        let answer = alphabet[answerIndex]
        bonusPts = answerIndex  // award extra pts for letters further in the alphabet, since it's easier to find answer by reciting abc's
        for index in indices {
            var letter = alphabet[index]
            if arc4random() % 2 == 1 {
                letter = letter.capitalizedString
            }
            word = word + letter
        }
        puzzle = word
        solution = answer
    }
    //If the "Begin" prompt is showing, display the puzzle and directions in its place.  start timer.
    //If GAME OVER msg is showing, replace it with Begin prompt and set up new puzzle
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if textViewer.text == prompt {
            timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("countdown"), userInfo: nil, repeats: true)
            
            startPlay()
            return false
        }
        
        if textViewer.text == gameOver {
            textViewer.text = prompt
            score = 0
            scoreLabel.text = "Score:  0"
            return false
        }
        
        if textViewer.text == nextWord {
            startPlay()
            return false
        }
        
        return true
    }
    //If the puzzle is showing, pause timer and clear puzzle from textField to allow user to enter solution
    func textFieldDidBeginEditing(textField: UITextField) {
        textViewer.text = ""
        paused = true
    }
    //Make keyboard disappear, process user's answer, display results, show "Begin" prompt in textField
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textViewer.resignFirstResponder()
        reportResultAndResetPrompt(textViewer.text!)
        
        return true
    }
    func reportResultAndResetPrompt(response: String) {
        textViewer.text = nextWord
       
        if response.capitalizedString == solution.capitalizedString                                                                                                                                                                                                                                                       {
            infoLabel.text = "CORRECT!\nYou score \(99 + bonusPts) points 👏🏿"
            score += 99
            score += bonusPts
        }
        else {
            infoLabel.text = "WRONG! \nYou lose 44 points. \nThe missing letter was \(solution)"
            score -= 44
        }
        scoreLabel.text = "Score:  \(score)"
        
        buildRandomWord()
    }
    //TODO:
   
    // persist top scores on separate screen or
}

