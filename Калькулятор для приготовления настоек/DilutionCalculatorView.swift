import SwiftUI

struct DilutionCalculatorView: View {

    @State private var initialVolume: String = ""
    @State private var initialStrength: String = ""
    @State private var targetStrength: String = ""
    @State private var waterNeeded: Double = 0.0
    @State private var showingSaveAlert = false
    @State private var calculationName = ""
    @AppStorage("savedCalculations") private var savedCalculationsData: Data = Data()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {

                    Image(systemName: "drop.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                        .padding(.top, 20)

                    Text("Калькулятор разбавления самогона")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    VStack(spacing: 16) {
                        InputGroup(title: "Начальные параметры") {
                            VStack(spacing: 12) {
                                InputField(
                                    title: "Начальный объём спирта",
                                    value: $initialVolume,
                                    unit: "литров"
                                )
                                InputField(
                                    title: "Крепость начального объёма",
                                    value: $initialStrength,
                                    unit: "°"
                                )
                            }
                        }

                        InputGroup(title: "Желаемый результат") {
                            InputField(
                                title: "Требуемая крепость",
                                value: $targetStrength,
                                unit: "°"
                            )
                        }
                    }
                    .padding(.horizontal)

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

                    if waterNeeded > 0 {
                        ResultCard(
                            title: "НЕОБХОДИМО ДОЛИТЬ ВОДЫ:",
                            value: String(format: "%.2f литров", waterNeeded),
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

    // MARK: - Helpers

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
        guard let v1 = parseDouble(initialVolume),
              let c1 = parseDouble(initialStrength),
              let c2 = parseDouble(targetStrength),
              c2 > 0 else {
            return
        }

        waterNeeded = v1 * (c1 - c2) / c2

        if waterNeeded < 0 {
            waterNeeded = 0
        }
    }

    private func saveCalculation() {
        let inputs =
        "Исходный объём: \(initialVolume)л × \(initialStrength)°, Целевая крепость: \(targetStrength)°"

        let result = String(format: "Добавить воды: %.2f л", waterNeeded)

        let calculation = CalculationResult(
            name: calculationName.isEmpty ? "Разбавление спирта" : calculationName,
            type: "Разбавление",
            inputs: inputs,
            result: result
        )

        var savedCalculations: [CalculationResult] = []

        if let decoded = try? JSONDecoder().decode(
            [CalculationResult].self,
            from: savedCalculationsData
        ) {
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
