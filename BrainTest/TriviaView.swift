import SwiftUI
import Speech
import AVFoundation
import Combine

// MARK: - Trivia View
struct TriviaView: View {
    @StateObject private var viewModel = TriviaViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "house.fill")
                        // Text("Home")
                    }
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.3))
                    .cornerRadius(15)
                }
                Spacer()
                
                NavigationLink(destination: TriviaGraphView()) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.3))
                        .cornerRadius(15)
                }
            }
            .padding(.horizontal)
            
            Text("Trivia Challenge")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.white)
            
            Text(viewModel.prompt)
                .font(.headline)
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
            
            Text("\(String(format: "%.1f", max(viewModel.timeRemaining, 0.0)))s")
                .font(.title2)
                .foregroundColor(.white)
                .padding()
            
            VStack(spacing: 5) {
                ForEach(viewModel.recognizedAnswers, id: \.self) { answer in
                    Text(answer)
                        .font(.title3)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            
            Spacer()
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
            viewModel.startChallenge()
        }
        .onDisappear {
            viewModel.stopChallenge()
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Trivia View Model
class TriviaViewModel: ObservableObject {
    @Published var prompt = ""
    @Published var timeRemaining = 60.0
    @Published var recognizedAnswers: [String] = []
    @Published var isChallengeComplete = false
    
    private var validAnswers: [String] = []
    private var speechRecognizer = SpeechRecognizer()
    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()
    private var currentCategory: String = ""
    private var processedWords: Set<String> = []
    
    private let triviaQuestions = [
        ("9 planets", "Name the nine planets,Mercury,Venus,Earth,Mars,Jupiter,Saturn,Uranus,Neptune,Pluto"),
        ("10 US cities", "Name the 10 largest cities in the US,New York,Los Angeles,Chicago,Houston,Phoenix,San Antonio,Philadelphia,San Diego,Dallas,Fort Worth"),
        ("7 dwarves", "Name the 7 dwarves,Doc,Grumpy,Happy,Sleepy,Bashful,Sneezy,Dopey"),
        ("13 colonies", "Name the 13 original American colonies,New Hampshire,Massachusetts,Rhode Island,Connecticut,New York,New Jersey,Pennsylvania,Delaware,Maryland,Virginia,North Carolina,South Carolina,Georgia"),
        ("12 months", "Name the 12 months of the year,January,February,March,April,May,June,July,August,September,October,November,December"),
        ("7 continents", "Name the 7 continents of the world,Asia,Africa,North America,South America,Antarctica,Europe,Australia"),
        ("5 great lakes", "Name the 5 Great Lakes,Superior,Michigan,Huron,Erie,Ontario"),
        ("4 seasons", "Name the 4 seasons,spring,summer,fall,winter"),
        ("5 oceans", "Name the 5 oceans,Pacific,Atlantic,Indian,Southern,Arctic"),
        ("7 colors", "Name the 7 colors of the rainbow,red,orange,yellow,green,blue,indigo,violet"),
        ("9 reindeer", "Name Santa's reindeer,Dasher,Dancer,Prancer,Vixen,Comet,Cupid,Donner,Blitzen,Rudolph"),
        ("7 sins", "Name the 7 deadly sins,Pride,Greed,Lust,Envy,Gluttony,Anger,Sloth")
    ]
    
    func startChallenge() {
        // Reset speech recognizer and cancellables
        speechRecognizer.stop()
        speechRecognizer = SpeechRecognizer()
        cancellables.removeAll()
        
        // Select a random trivia question
        guard let (category, questionString) = triviaQuestions.randomElement() else { return }
        let question = questionString.components(separatedBy: ",")
        prompt = question[0]
        validAnswers = Array(question.dropFirst()).map { $0.lowercased() }
        currentCategory = category
        recognizedAnswers = []
        processedWords = []
        timeRemaining = 60.0
        isChallengeComplete = false
        
        // Start timer
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 0.1
                }
                if self.timeRemaining <= 0 && !self.isChallengeComplete {
                    self.prompt = "Time's up!"
                    self.isChallengeComplete = true
                    self.timer?.invalidate()
                    self.speechRecognizer.stop()
                    self.saveToCSV()
                }
            }
        }
        
        // Start speech recognition with a slight delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.speechRecognizer.start()
            
            // Observe transcript changes
            self.speechRecognizer.$transcript
                .sink { [weak self] transcript in
                    self?.processTranscript(transcript)
                }
                .store(in: &self.cancellables)
        }
    }
    
    func stopChallenge() {
        timer?.invalidate()
        speechRecognizer.stop()
        cancellables.removeAll()
    }
    
    private func processTranscript(_ transcript: String) {
        guard !isChallengeComplete else { return }
        
        // Process only non-empty transcripts
        guard !transcript.isEmpty else { return }
        
        // Split transcript into words
        let spokenWords = transcript.lowercased().components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
        
        // Check the last one or two words for a match
        let lastOneWord = spokenWords.last ?? ""
        let lastTwoWords = spokenWords.count >= 2 ? spokenWords.suffix(2).joined(separator: " ") : ""
        
        var matchedAnswer: String?
        
        // First try two-word answers, then single-word answers
        if !lastTwoWords.isEmpty && validAnswers.contains(lastTwoWords) && !recognizedAnswers.contains(lastTwoWords) && !processedWords.contains(lastTwoWords) {
            matchedAnswer = lastTwoWords
        } else if !lastOneWord.isEmpty && validAnswers.contains(lastOneWord) && !recognizedAnswers.contains(lastOneWord) && !processedWords.contains(lastOneWord) {
            matchedAnswer = lastOneWord
        }
        
        if let answer = matchedAnswer {
            DispatchQueue.main.async {
                self.recognizedAnswers.append(answer)
                self.processedWords.insert(answer)
                if self.recognizedAnswers.count == self.validAnswers.count {
                    self.prompt = "Congratulations!"
                    self.isChallengeComplete = true
                    self.timer?.invalidate()
                    self.speechRecognizer.stop()
                    self.saveToCSV()
                }
                // Clear transcript to prevent re-processing
                self.speechRecognizer.transcript = ""
            }
        }
    }
    
    private func saveToCSV() {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent("stats.csv")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let timestamp = dateFormatter.string(from: Date())
        let score = String(recognizedAnswers.count)
        let csvLine = "\(timestamp),Trivia,\(currentCategory),\(score)\n"
        
        do {
            if !fileManager.fileExists(atPath: fileURL.path) {
                // Create file with header if it doesn't exist
                let header = "Timestamp,Test,Category,Score\n"
                try header.write(to: fileURL, atomically: true, encoding: .utf8)
            }
            
            // Append the new score
            if let fileHandle = try? FileHandle(forWritingTo: fileURL) {
                defer { fileHandle.closeFile() }
                fileHandle.seekToEndOfFile()
                if let data = csvLine.data(using: .utf8) {
                    fileHandle.write(data)
                }
            }
        } catch {
            print("Error writing to CSV: \(error)")
        }
    }
}

struct TriviaView_Previews: PreviewProvider {
    static var previews: some View {
        TriviaView()
    }
}
