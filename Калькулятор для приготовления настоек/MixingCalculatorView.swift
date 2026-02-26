import SwiftUI

struct MixingCalculatorView: View {
    @State private var volume1: String = ""
    @State private var strength1: String = ""
    @State private var volume2: String = ""
    @State private var strength2: String = ""
    @State private var resultStrength: Double = 0.0
    @State private var showingSaveAlert = false
    @State private var showingDonation = false
    @State private var calculationName = ""
    @AppStorage("savedCalculations") private var savedCalculationsData: Data = Data()
    @State private var isKeyboardVisible = false
    @State private var showWaterError = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 20) {
                        // Иконка
                        Image(systemName: "flask.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                            .padding(.top, 20)
                        
                        Text("Смешение спиртов")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        // Форма ввода
                        VStack(spacing: 16) {
                            InputGroup(title: "Спирт 1") {
                                HStack(spacing: 12) {
                                    InputField(title: "Объём спирта 1", value: $volume1, unit: "литров")
                                    InputField(title: "Крепость спирта 1", value: $strength1, unit: "°")
                                }
                            }
                            
                            InputGroup(title: "Спирт 2") {
                                HStack(spacing: 12) {
                                    InputField(title: "Объём спирта 2", value: $volume2, unit: "литров")
                                    InputField(title: "Крепость спирта 2", value: $strength2, unit: "°")
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
                        
                        // Результат или ошибка
                        if showWaterError {
                            // Пасхалка: попытка смешать с водой
                            VStack(spacing: 12) {
                                Text("Ну куда ты воду лить собрался")
                                    .font(.headline)
                                    .foregroundColor(.red)
                                    .strikethrough()
                                
                                Text("Данный расчёт можно провести в разделе «Разбавление спирта водой»")
                                    .font(.subheadline)
                                    .foregroundColor(.red)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(20)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        } else if resultStrength > 0 {
                            ResultCard(
                                title: "КРЕПОСТЬ ЖИДКОСТИ:",
                                value: String(format: "%.2f°", resultStrength),
                                onSave: { showingSaveAlert = true }
                            )
                            .padding(.horizontal)
                        }
                    }
                }
                
                // Кнопка поддержки внизу
                if !isKeyboardVisible {
                    Button(action: { showingDonation = true }) {
                        HStack {
                            Image(systemName: "heart.fill")
                                .font(.title3)
                            Text("Поддержать автора")
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.red, Color.pink]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
                        .onTapGesture {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }
                        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
                            isKeyboardVisible = true
                        }
                        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                            isKeyboardVisible = false
                        }
            .alert("Сохранить расчёт", isPresented: $showingSaveAlert) {
                TextField("Название расчёта", text: $calculationName)
                Button("Отмена", role: .cancel) {
                    calculationName = ""
                }
                Button("Сохранить") {
                    saveCalculation()
                }
            }
            .sheet(isPresented: $showingDonation) {
                DonationView()
            }
        }
    }
    
    private func calculate() {
        // Сбрасываем ошибку
        showWaterError = false
        resultStrength = 0.0
        
        // Заменяем запятые на точки для корректного парсинга
        let v1String = volume1.replacingOccurrences(of: ",", with: ".")
        let s1String = strength1.replacingOccurrences(of: ",", with: ".")
        let v2String = volume2.replacingOccurrences(of: ",", with: ".")
        let s2String = strength2.replacingOccurrences(of: ",", with: ".")
        
        guard let v1 = Double(v1String),
              let s1 = Double(s1String),
              let v2 = Double(v2String),
              let s2 = Double(s2String) else {
            return
        }
        
        // 🥚 Пасхалка: попытка смешать спирт с водой
        if s1 == 0 || s2 == 0 {
            showWaterError = true
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
