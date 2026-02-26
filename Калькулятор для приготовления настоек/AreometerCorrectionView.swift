import SwiftUI

struct AreometerCorrectionView: View {
    @State private var temperature: String = ""
    @State private var measuredStrength: String = ""
    @State private var realStrength: Double = 0.0
    @State private var showingSaveAlert = false
    @State private var showingDonation = false
    @State private var calculationName = ""
    @AppStorage("savedCalculations") private var savedCalculationsData: Data = Data()
    @State private var isKeyboardVisible = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 20) {
                        // Иконка
                        Image(systemName: "thermometer")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                            .padding(.top, 20)
                        
                        Text("Калибровка ареометра")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        // Форма ввода
                        VStack(spacing: 16) {
                            InputGroup(title: "Условия измерения") {
                                VStack(spacing: 12) {
                                    InputField(title: "Температура спирта", value: $temperature, unit: "°C")
                                    InputField(title: "Показание ареометра", value: $measuredStrength, unit: "°")
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
                        if realStrength > 0 {
                            ResultCard(
                                title: "РЕАЛЬНАЯ КРЕПОСТЬ:",
                                value: String(format: "%.2f°", realStrength),
                                onSave: { showingSaveAlert = true }
                            )
                            .padding(.horizontal)
                        }
                        
                        VStack(spacing: 8) {
                            Text("Ареометры калибруются при 20°C")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.bottom, 20)
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
        // Заменяем запятые на точки для корректного парсинга
        let tempString = temperature.replacingOccurrences(of: ",", with: ".")
        let measuredString = measuredStrength.replacingOccurrences(of: ",", with: ".")
        
        guard let temp = Double(tempString),
              let measured = Double(measuredString) else {
            return
        }
        
        // Температурная коррекция по таблицам Фертмана
        let tempDiff = temp - 20.0
        
        // Коэффициент коррекции зависит от крепости
        let correctionFactor: Double
        if measured < 40 {
            correctionFactor = 0.3
        } else if measured < 60 {
            correctionFactor = 0.35
        } else {
            correctionFactor = 0.4
        }
        
        let correction = tempDiff * correctionFactor
        realStrength = measured + correction
        
        // Ограничиваем результат в разумных пределах
        if realStrength < 0 {
            realStrength = 0
        } else if realStrength > 100 {
            realStrength = 100
        }
    }
    
    private func saveCalculation() {
        let inputs = "Температура: \(temperature)°C, Показание: \(measuredStrength)°"
        let result = String(format: "Реальная крепость: %.2f°", realStrength)
        
        let calculation = CalculationResult(
            name: calculationName.isEmpty ? "Коррекция ареометра" : calculationName,
            type: "Коррекция ареометра",
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

#Preview {
    AreometerCorrectionView()
}
