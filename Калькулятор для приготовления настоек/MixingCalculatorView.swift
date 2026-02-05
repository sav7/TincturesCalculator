import SwiftUI

struct MixingCalculatorView: View {
    @State private var volume1: String = ""
    @State private var strength1: String = ""
    @State private var volume2: String = ""
    @State private var strength2: String = ""
    @State private var resultStrength: Double = 0.0
    @State private var showingSaveAlert = false
    @State private var calculationName = ""
    @AppStorage("savedCalculations") private var savedCalculationsData: Data = Data()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Иконка
                    Image(systemName: "flask.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                        .padding(.top, 20)
                    
                    Text("Калькулятор смешивания алкоголя")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    // Форма ввода
                    VStack(spacing: 16) {
                        InputGroup(title: "Первый спирт") {
                            HStack(spacing: 12) {
                                InputField(title: "Объём", value: $volume1, unit: "литров")
                                InputField(title: "Крепость", value: $strength1, unit: "°")
                            }
                        }
                        
                        InputGroup(title: "Второй спирт") {
                            HStack(spacing: 12) {
                                InputField(title: "Объём", value: $volume2, unit: "литров")
                                InputField(title: "Крепость", value: $strength2, unit: "°")
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Кнопка расчёта
                    Button(action: calculate) {
                        Text("Рассчитать")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    // Результат
                    if resultStrength > 0 {
                        ResultCard(
                            title: "КРЕПОСТЬ ЖИДКОСТИ:",
                            value: String(format: "%.2f°", resultStrength),
                            onSave: { showingSaveAlert = true }
                        )
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                    
                    Text("Данные результаты актуальны и верны\nпри температуре компонентов равной 20°C")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 20)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                hideKeyboard()
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationBarTitleDisplayMode(.inline)
            .alert("Сохранить расчёт", isPresented: $showingSaveAlert) {
                TextField("Название расчёта", text: $calculationName)
                Button("Отмена", role: .cancel) {
                    calculationName = ""
                }
                Button("Сохранить") {
                    saveCalculation()
                }
            }
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
    
    private func parseDouble(_ text: String) -> Double? {
        let normalized = text.replacingOccurrences(of: ",", with: ".")
        return Double(normalized)
    }
    
    private func calculate() {
        guard let v1 = parseDouble(volume1),
              let s1 = parseDouble(strength1),
              let v2 = parseDouble(volume2),
              let s2 = parseDouble(strength2) else {
            return
        }
        
        // Формула: (V1 × C1 + V2 × C2) / (V1 + V2)
        resultStrength = (v1 * s1 + v2 * s2) / (v1 + v2)
    }
    
    private func saveCalculation() {
        let inputs = "Спирт 1: \(volume1)л × \(strength1)°, Спирт 2: \(volume2)л × \(strength2)°"
        let result = String(format: "Крепость: %.2f°", resultStrength)
        
        let calculation = CalculationResult(
            name: calculationName.isEmpty ? "Смешение спирта" : calculationName,
            type: "Смешение",
            inputs: inputs,
            result: result
        )
        
        var savedCalculations: [CalculationResult] = []
        if let decoded = try? JSONDecoder().decode([CalculationResult].self, from: savedCalculationsData) {
            savedCalculations = decoded
        }
        
        savedCalculations.append(calculation)
        
        if let encoded = try? JSONEncoder().encode(savedCalculations) {
            savedCalculationsData = encoded
        }
        
        calculationName = ""
    }
}

// Вспомогательные компоненты
struct InputGroup<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
            content
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct InputField: View {
    let title: String
    @Binding var value: String
    let unit: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack {
                TextField("0", text: $value)
                    .keyboardType(.decimalPad)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                
                Text(unit)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(width: 50, alignment: .leading)
            }
        }
    }
}

struct ResultCard: View {
    let title: String
    let value: String
    let onSave: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(value)
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.primary)
            
            Button(action: onSave) {
                Label("Сохранить расчёт", systemImage: "square.and.arrow.down")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(Color.yellow)
        .cornerRadius(12)
    }
}

#Preview {
    MixingCalculatorView()
}
