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
    
    private let triviaQuestions = [
        "Name the nine planets,Mercury,Venus,Earth,Mars,Jupiter,Saturn,Uranus,Neptune,Pluto",
        "Name the 10 largest cities in the US,New York City,Los Angeles,Chicago,Houston,Phoenix,San Antonio,Philadelphia,San Diego,Dallas,Fort Worth",
        "Name the 7 dwarves,Doc,Grumpy,Happy,Sleepy,Bashful,Sneezy,Dopey",
        "Name the 13 original American colonies,New Hampshire,Massachusetts,Rhode Island,Connecticut,New York,New Jersey,Pennsylvania,Delaware,Maryland,Virginia,North Carolina,South Carolina,Georgia",
        "Name the 12 months of the year,January,February,March,April,May,June,July,August,September,October,November,December",
        "Name the 7 continents of the world,Asia,Africa,North America,South America,Antarctica,Europe,Australia",
        "Name the 5 Great Lakes,Superior,Michigan,Huron,Erie,Ontario",
        "Name the 4 seasons,spring,summer,fall,winter",
        "Name the 5 oceans,Pacific Ocean,Atlantic Ocean,Indian Ocean,Southern Ocean,Arctic Ocean",
        "Name the 7 colors of the rainbow,red,orange,yellow,green,blue,indigo,violet",
        "Name Santa's reindeer,Dasher,Dancer,Prancer,Vixen,Comet,Cupid,Donner,Blitzen,Rudolph",
        "Name the 7 deadly sins,Pride,Greed,Lust,Envy,Gluttony,Anger,Sloth"
    ]
    
    func startChallenge() {
        // Select a random trivia question
        guard let question = triviaQuestions.randomElement()?.components(separatedBy: ",") else { return }
        prompt = question[0]
        validAnswers = Array(question.dropFirst()).map { $0.lowercased() }
        recognizedAnswers = []
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
                }
            }
        }
        
        // Start speech recognition with a slight delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.speechRecognizer.stop()
            self.speechRecognizer.transcript = ""
            self.speechRecognizer.start()
            
            // Observe transcript changes
            self.speechRecognizer.$transcript
                .sink { [weak self] transcript in
                    // print("Transcript received: \(transcript)") // Debugging log
                    self?.processTranscript(transcript)
                }
                .store(in: &self.cancellables)
        }
    }
    
    private func processTranscript(_ transcript: String) {
        guard !isChallengeComplete else { return }
        
        // Process only non-empty transcripts
        guard !transcript.isEmpty else {
            // print("Empty transcript received") // Debugging log
            return
        }
        
        // Split transcript into words
        let spokenWords = transcript.lowercased().components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
        // print("Spoken words: \(spokenWords)") // Debugging log
        
        // Check the last one or two words for a match
        let lastOneWord = spokenWords.last ?? ""
        let lastTwoWords = spokenWords.count >= 2 ? spokenWords.suffix(2).joined(separator: " ") : ""
        
        // First try two-word answers, then single-word answers
        if !lastTwoWords.isEmpty && validAnswers.contains(lastTwoWords) && !recognizedAnswers.contains(lastTwoWords) {
            // print("Recognized two-word answer: \(lastTwoWords)") // Debugging log
            DispatchQueue.main.async {
                self.recognizedAnswers.append(lastTwoWords)
                if self.recognizedAnswers.count == self.validAnswers.count {
                    self.prompt = "Congratulations!"
                    self.isChallengeComplete = true
                    self.timer?.invalidate()
                    self.speechRecognizer.stop()
                }
            }
            // Clear transcript to prevent re-processing
            DispatchQueue.main.async {
                self.speechRecognizer.transcript = ""
                // print("Transcript cleared") // Debugging log
            }
        } else if !lastOneWord.isEmpty && validAnswers.contains(lastOneWord) && !recognizedAnswers.contains(lastOneWord) {
            // print("Recognized single-word answer: \(lastOneWord)") // Debugging log
            DispatchQueue.main.async {
                self.recognizedAnswers.append(lastOneWord)
                if self.recognizedAnswers.count == self.validAnswers.count {
                    self.prompt = "Congratulations!"
                    self.isChallengeComplete = true
                    self.timer?.invalidate()
                    self.speechRecognizer.stop()
                }
            }
            // Clear transcript to prevent re-processing
            DispatchQueue.main.async {
                self.speechRecognizer.transcript = ""
                //print("Transcript cleared") // Debugging log
            }
        } /* else {
            print("No match for last words: \(lastTwoWords.isEmpty ? lastOneWord : lastTwoWords)") // Debugging log
        }*/
    }
}

struct TriviaView_Previews: PreviewProvider {
    static var previews: some View {
        TriviaView()
    }
}
