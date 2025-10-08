import SwiftUI
import Charts

// MARK: - Trivia Graph View
struct TriviaGraphView: View {
    @State private var data: [(date: Date, score: Int)] = []
    @State private var selectedCategory: String = "9 planets"
    @State private var availableCategories: [String] = []
    @Environment(\.dismiss) private var dismiss
    
    var minScore: Int {
        data.map { $0.score }.min() ?? 0
    }
    
    var maxScore: Int {
        data.map { $0.score }.max() ?? 1
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.blue, Color.purple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 10) {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            // Text("Back")
                        }
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.3))
                        .cornerRadius(15)
                    }
                    
                    Spacer()
                    
                    Picker("Select Category", selection: $selectedCategory) {
                        // Text("All").tag("All")
                        ForEach(availableCategories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                    .pickerStyle(.menu)
                    .font(.system(size: 16))
                    .padding(.horizontal)
                    .background(Color.white.opacity(0.3))
                    .cornerRadius(10)
                    .disabled(availableCategories.isEmpty && data.isEmpty)
                }
                .padding(.horizontal)
                .padding(.top)
                
                Text("Trivia History")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.bottom, 10)
                
                if data.isEmpty {
                    Text(selectedCategory == "All" ? "No data available" : "No data available for category \(selectedCategory)")
                        .font(.system(size: 18))
                        .foregroundColor(.white.opacity(0.8))
                        .padding()
                } else {
                    Chart {
                        ForEach(data.indices, id: \.self) { index in
                            LineMark(
                                x: .value("Time", data[index].date),
                                y: .value("Answers", data[index].score)
                            )
                            .foregroundStyle(.yellow)
                        }
                    }
                    .chartYScale(domain: (minScore - 1)...(maxScore + 1))
                    .chartXAxis {
                        AxisMarks { value in
                            AxisValueLabel(centered: false, anchor: .top) {
                                if let date = value.as(Date.self) {
                                    let calendar = Calendar.current
                                    let components = calendar.dateComponents([.hour, .minute, .month, .day], from: date)
                                    VStack(alignment: .leading, spacing: 0) {
                                        Text(String(format: "%02d:%02d", components.hour ?? 0, components.minute ?? 0))
                                            .font(.caption)
                                        Text(String(format: "%02d/%02d", components.month ?? 0, components.day ?? 0))
                                            .font(.caption)
                                    }
                                }
                            }
                        }
                    }
                    .chartYAxis {
                        AxisMarks(position: .leading) {
                            AxisValueLabel()
                        }
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal)
                    .padding(.bottom, 20) // Move X-axis labels downward
                    .frame(maxHeight: .infinity) // Expand graph vertically
                }
                
                Spacer()
            }
            .padding(.top)
        }
        .navigationBarHidden(true)
        .onAppear {
            loadData()
        }
        .onChange(of: selectedCategory) { _ in
            loadData()
        }
    }
    
    private func loadData() {
        let fileManager = FileManager.default
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let fileURL = documentsDirectory.appendingPathComponent("stats.csv")
        
        do {
            let content = try String(contentsOf: fileURL, encoding: .utf8)
            let lines = content.components(separatedBy: .newlines).filter { !$0.isEmpty }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            
            var tempData: [(Date, Int)] = []
            var categoriesSet = Set<String>()
            
            for line in lines.dropFirst() { // Skip header
                let parts = line.components(separatedBy: ",")
                if parts.count >= 4 && parts[1].trimmingCharacters(in: .whitespaces) == "Trivia" {
                    let category = parts[2].trimmingCharacters(in: .whitespaces)
                    if !category.isEmpty {
                        categoriesSet.insert(category)
                    }
                    if selectedCategory == "All" || category == selectedCategory {
                        if let date = dateFormatter.date(from: parts[0]),
                           let score = Int(parts[3]) {
                            tempData.append((date, score))
                        }
                    }
                }
            }
            
            availableCategories = categoriesSet.sorted()
            if selectedCategory != "All" && !availableCategories.contains(selectedCategory) && !availableCategories.isEmpty {
                selectedCategory = availableCategories.first!
            }
            data = tempData.sorted { $0.0 < $1.0 }
        } catch {
            print("Error loading stats.csv: \(error)")
            availableCategories = []
            data = []
        }
    }
}

// MARK: - Preview
struct TriviaGraphView_Previews: PreviewProvider {
    static var previews: some View {
        TriviaGraphView()
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
