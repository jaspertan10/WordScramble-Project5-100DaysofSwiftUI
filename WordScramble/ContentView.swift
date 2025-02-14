//
//  ContentView.swift
//  WordScramble
//
//  Created by Jasper Tan on 11/14/24.
//

import SwiftUI

struct ContentView: View {

    @State private var usedWords: [String] = []
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var score = 0
    
    //Alerts
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var alertTitle: String = ""
    
    var body: some View {
        
        NavigationStack {
            
            VStack {
                Text(rootWord)
                    .font(.largeTitle).bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 40)
                    .padding(.leading, 20)


                
                List {
        
                    Section("Word history") {
                        TextField("Enter your word", text: $newWord)
                            .textInputAutocapitalization(.never)
                            .onSubmit(addNewWord)
                    }
                    
                    
                    Section {
                        ForEach(usedWords, id: \.self) { word in
                            HStack {
                                Image(systemName: "\(word.count).circle")
                                Text(word)
                            }
                            .accessibilityElement()
                            .accessibilityLabel("\(word)")
                            .accessibilityHint("\(word.count) letters")
                        }
                    }
                    
                }
                .navigationTitle("WordScramble")
                .navigationBarTitleDisplayMode(.inline)
                .onAppear {
                    startGame()
                }
                .alert(alertTitle, isPresented: $showAlert) {
                    Button("OK") {}
                } message: {
                    Text(alertMessage)
                }
                .toolbar {
                    Button("New Word") {
                        withAnimation {
                            startGame()
                        }
                    }
                }
                
                Text("Current Score: \(score)")
                    .font(.title3)
                    .padding(.top, 20)
                
            }
            .preferredColorScheme(.dark)
            
            
        }
    }
    
    func errorMessage(errorTitle: String, errorMessage: String) {
        alertMessage = errorMessage
        alertTitle = errorTitle
        showAlert = true
    }
    
    func isOriginal(_ word: String) -> Bool {
        return !usedWords.contains(word)
    }
    
    func isPossible(_ word: String) -> Bool {
        
        var tempWord = rootWord
        
        for letter in word {
            if let index = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: index)
            } else {
                return false
            }
        }
        
        return true
    }
    
    func isReal(_ word: String) -> Bool {
        
        // Create instance of UITextChecker
        let checker = UITextChecker()
        
        // Create an Obj-C string range using length of our characters in utf16 format
        let range = NSRange(location: 0, length: word.utf16.count)
        
        // Check where the any mispellings are in a word
        let mispelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        // If no mispellings found, return True, i.e. isReal word
        return mispelledRange.location == NSNotFound
    }
    
    func startGame() {
        
        /*
        1. Find start.txt in our bundle
        2. Load it into a string
        3. Split that string into array of strings, with each element being one word
        4. Pick one random word from there to be assigned to rootWord, or use a sensible default if the array is empty.
         */
        
        var wordArray: [String]
        
        if let wordFile = Bundle.main.url(forResource: "start", withExtension: "txt") {
            //Able to find file
            if let wordString = try? String(contentsOf: wordFile, encoding: .ascii) {
                //store words in array
                wordArray = wordString.components(separatedBy: "\n")
                
                if let randomWord = wordArray.randomElement() {
                    rootWord = randomWord
                    usedWords.removeAll()
                    score = 0
                    return
                }
            }
        }
        
        fatalError("Could not load start.txt from bundle.")
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count > 0 else {
            return
        }
        
        guard answer.count >= 3 else {
            errorMessage(errorTitle: "Word too short", errorMessage: "Enter words longer than 3 characters")
            return
        }
        
        guard answer != rootWord else {
            errorMessage(errorTitle: "Word identical to root word", errorMessage: "Enter a unique word")
            return
        }
        
        guard isOriginal(answer) else {
            errorMessage(errorTitle: "Word not original", errorMessage: "Enter a new word")
            return
        }
        
        guard isPossible(answer) else {
            errorMessage(errorTitle: "Word not possible", errorMessage: "You can't spell that word from \(rootWord)")
            return
        }
        
        guard isReal(answer) else {
            errorMessage(errorTitle: "Word not real", errorMessage: "Enter a real word")
            return
        }
        
        score += answer.count
    
        
        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        newWord = ""
    }
}

#Preview {
    ContentView()
}
