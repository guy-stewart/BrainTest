import SwiftUI
import Speech
import AVFoundation

// MARK: - Short Term Memory View
struct ShortTermMemoryView: View {
    @StateObject private var speechRecognizer = SpeechRecognizer()
    @State private var words: [String] = []
    @State private var displayedWords: [String] = []
    @State private var isShowingWords = false
    @State private var isRecallActive = false
    @State private var message = "Click 'Get Words' to start"
    @Environment(\.dismiss) private var dismiss
    
    private let commonObjects = [
        "apple", "ball", "book", "chair", "table", "pen", "cup", "phone", "car", "house",
        "tree", "dog", "cat", "bird", "fish", "shoe", "shirt", "hat", "clock", "door",
        "window", "lamp", "bed", "pillow", "blanket", "spoon", "fork", "knife", "plate", "bowl",
        "bottle", "glass", "mirror", "bag", "wallet", "key", "watch", "ring", "box", "basket",
        "flower", "plant", "tree", "grass", "cloud", "sun", "moon", "star", "sky", "river",
        "mountain", "beach", "sand", "stone", "rock", "shell", "wave", "boat", "carpet", "rug",
        "picture", "frame", "brush", "comb", "towel", "soap", "shampoo", "toothbrush", "toothpaste", "mirror",
        "desk", "computer", "keyboard", "mouse", "screen", "printer", "paper", "pencil", "eraser", "ruler",
        "scissors", "glue", "tape", "stapler", "calendar", "clock", "radio", "television", "camera", "light",
        "fan", "heater", "oven", "stove", "fridge", "microwave", "toaster", "kettle", "pot", "pan"
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "house.fill")
                        Text("Home")
                    }
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.3))
                    .cornerRadius(15)
                }
                Spacer()
            }
            .padding(.horizontal)
            
            Text("Short Term Memory Challenge")
                .font(.title)
                .foregroundColor(.white)
            
            Text(message)
                .font(.headline)
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
            
            ForEach(displayedWords, id: \.self) { word in
                Text(word)
                    .font(.title2)
                    .padding(5)
                    .cornerRadius(8)
            }
            
            Spacer()
            
            HStack(spacing: 20) {
                Button(action: {
                    if isRecallActive {
                        displayedWords = words
                        isShowingWords = true
                    } else {
                        startRecall()
                    }
                }) {
                    Text(isRecallActive ? "Show Words" : "Recall")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Button(action: {
                    generateNewWords()
                }) {
                    Text("Get Words")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal)
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color.blue, Color.purple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
        .onAppear {
            speechRecognizer.requestPermissions()
            if !words.isEmpty {
                displayedWords = []
                isShowingWords = false
                isRecallActive = true
                message = "Say the words you remember"
                speechRecognizer.start()
            }
        }
        .onChange(of: speechRecognizer.transcript) { newTranscript in
            if isRecallActive {
                processTranscript(newTranscript)
            }
        }
        .navigationBarHidden(true)
    }
    
    private func generateNewWords() {
        words = commonObjects.shuffled().prefix(5).map { $0 }
        displayedWords = words
        isShowingWords = true
        isRecallActive = false
        message = "Remember these words.\nClick Recall when ready."
        speechRecognizer.stop()
    }
    
    private func startRecall() {
        displayedWords = []
        isShowingWords = false
        isRecallActive = true
        message = "Say the words you remember"
        speechRecognizer.start()
    }
    
    private func processTranscript(_ transcript: String) {
        let spokenWords = transcript.lowercased().components(separatedBy: .whitespacesAndNewlines)
        var newlyRecognizedWords: [String] = []
        
        for word in spokenWords {
            if words.contains(word) && !displayedWords.contains(word) {
                newlyRecognizedWords.append(word)
            }
        }
        
        displayedWords.append(contentsOf: newlyRecognizedWords)
        
        if Set(displayedWords).isSuperset(of: Set(words)) {
            message = "Congratulations!"
            isRecallActive = false
            speechRecognizer.stop()
        }
    }
}
