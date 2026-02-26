import SwiftUI

struct DilutionCalculatorView: View {
    @State private var initialVolume: String = ""
    @State private var initialStrength: String = ""
    @State private var targetStrength: String = ""
    @State private var waterNeeded: Double = 0.0
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
                        Image(systemName: "drop.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                            .padding(.top, 20)
                        
                        Text("Разбавление спирта водой")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        // Форма ввода
                        VStack(spacing: 16) {
                            InputGroup(title: "Начальные параметры") {
                                VStack(spacing: 12) {
                                    InputField(title: "Объём спирта", value: $initialVolume, unit: "литров")
                                    InputField(title: "Крепость спирта", value: $initialStrength, unit: "°")
                                }
                            }
                            
                            InputGroup(title: "Желаемый результат") {
                                InputField(title: "Требуемая крепость", value: $targetStrength, unit: "°")
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
                        if waterNeeded > 0 {
                            ResultCard(
                                title: "НЕОБХОДИМО ДОЛИТЬ ВОДЫ:",
                                value: String(format: "%.2f литров", waterNeeded),
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
        // Заменяем запятые на точки для корректного парсинга
        let v1String = initialVolume.replacingOccurrences(of: ",", with: ".")
        let c1String = initialStrength.replacingOccurrences(of: ",", with: ".")
        let c2String = targetStrength.replacingOccurrences(of: ",", with: ".")
        
        guard let v1 = Double(v1String),
              let c1 = Double(c1String),
              let c2 = Double(c2String),
              c2 > 0 else {
            return
        }
        
        // Формула: V_воды = V1 × (C1 - C2) / C2
        waterNeeded = v1 * (c1 - c2) / c2
        
        // Проверка на отрицательные значения
        if waterNeeded < 0 {
            waterNeeded = 0
        }
    }
    
    private func saveCalculation() {
        let inputs = "Исходный объём: \(initialVolume)л × \(initialStrength)°, Целевая крепость: \(targetStrength)°"
        let result = String(format: "Добавить воды: %.2f л", waterNeeded)
        
        let calculation = CalculationResult(
            name: calculationName.isEmpty ? "Разбавление спирта" : calculationName,
            type: "Разбавление",
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
    DilutionCalculatorView()
}
