//
//  ViewController.swift
//  Wordimize
//
//  Created by Stivan Mersho on 2020-04-02.
//  Copyright © 2020 Stivan Mersho. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    var allWords = [String]()
    var usedWords = [String]()
    var wrongAnswer: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadFromFile()
        startGame()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(startGame))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
    }
    
    func loadFromFile() {
        // Try to locate the file
        if let fileUrl = Bundle.main.url(forResource: "start", withExtension: "txt") {
            
            // if we found the file, try to load file content inside the array
            if let startWord = try? String(contentsOf: fileUrl) {
                allWords = startWord.components(separatedBy: "\n")
            }
            
        }
        
    }
    
    @objc func startGame() {
        title = allWords.randomElement()
        navigationController?.navigationBar.prefersLargeTitles = true
        usedWords.removeAll()
        tableView.reloadData()
    }
    
    
    /* Locate where the cell should be added (identifier in storyboard cell).
     The method returns an reusable cell to use for the word. */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        
        // Change cell label to the name of the added word
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    
    @objc func promptForAnswer(){
        // Show an alert
        let alertAnswer = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        // Add input to the alert
        alertAnswer.addTextField()
        
        // Add a button
        let submitAction = UIAlertAction(title: "Submit", style: .default) {
            [weak self, weak alertAnswer] _ in
            
            // Try to read the input from the textfield.
            // Use guard to make sure our condition is met, otherwise exit from the scope
            guard let answer = alertAnswer?.textFields?[0].text else {return}
            if (self?.isLetterOk(word: answer))! {
                self?.submit(word: answer)
            } else {
                self!.showMessage(title: "Word is too short", message: "Word must be longer than 2 letters!")
            }
        }
        
        alertAnswer.addAction(submitAction)
        present(alertAnswer, animated: true)
    }
    
    /*
     Function for checking the inputs from the input.
     Check 3 different requirements before adding the word the the list
     */
    func submit(word: String){
        // save the world in lowercase
        let lowerAnswer = word.lowercased()
        // If the user made 5 misstakes with adding new answers, give the user a new word
        if wrongAnswer > 5 {
            showMessage(title: "Woops!", message: "The word was a bit too difficult for you, we will give you a new word!")
            startGame()
        } else {
            if isWordPossible(word: lowerAnswer){
                if isWordUnique(word: lowerAnswer){
                    if isActualWord(word: lowerAnswer) {
                        usedWords.insert(word, at: 0)
                        let indexPath = IndexPath(row: 0, section: 0)
                        tableView.insertRows(at: [indexPath], with: .automatic)
                        return
                    } else {
                        wrongAnswer += 1
                        showMessage(title: "Word not recognized!", message: "You can't make up your own words, you know!")
                    }
                } else {
                    wrongAnswer += 1
                    showMessage(title: "Word already used!", message: "You can't the same word twice, be more original!")
                }
            } else {
                wrongAnswer += 1
                showMessage(title: "Word not possible!", message: "You can't spell that from \(title!.lowercased())")
            }
        }
        
    }
    
    // Check if word (input) from has already been added to the list
    func isWordUnique(word: String) -> Bool {
        return !usedWords.contains(word)
    }
    
    // Check if the word is an actual word from the dictionary
    func isActualWord(word: String) -> Bool {
        let checker = UITextChecker()
        
        // UTF-16 is used here due to compability issues
        let range = NSRange(location: 0, length: word.utf16.count)
        
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        //if the location isn't present it's not an word = NSNotFound
        return misspelledRange.location == NSNotFound
    }
    
    // Check if the word is possbile based on the letters that's available
    func isWordPossible(word: String) -> Bool{
        guard var tempWord = title?.lowercased() else {return false}
        
        for letter in word {
            if let position = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: position)
            } else {
                return false
            }
        }
        return true
    }
    
    func isLetterOk(word: String) -> Bool{
        var isOK: Bool
        if word.count > 2 {
            isOK = true
        } else {
            isOK = false
        }
        return isOK
    }
    
    func showMessage(title: String, message: String){
        let messageAlert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        messageAlert.addAction(UIAlertAction(title: "OK", style: .default))
        
        present(messageAlert, animated: true)
    }
}

