import SwiftUI

struct AreometerCorrectionView: View {

    @State private var temperature: String = ""
    @State private var measuredStrength: String = ""
    @State private var realStrength: Double = 0.0
    @State private var showingSaveAlert = false
    @State private var calculationName = ""
    @AppStorage("savedCalculations") private var savedCalculationsData: Data = Data()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {

                    Image(systemName: "thermometer")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                        .padding(.top, 20)

                    Text("Калькулятор коррекции показаний ареометра")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    VStack(spacing: 16) {
                        InputGroup(title: "Условия измерения") {
                            VStack(spacing: 12) {
                                InputField(
                                    title: "Температура спирта",
                                    value: $temperature,
                                    unit: "°C"
                                )
                                InputField(
                                    title: "Показание ареометра",
                                    value: $measuredStrength,
                                    unit: "°"
                                )
                            }
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

                    if realStrength > 0 {
                        ResultCard(
                            title: "РЕАЛЬНАЯ КРЕПОСТЬ:",
                            value: String(format: "%.2f°", realStrength),
                            onSave: { showingSaveAlert = true }
                        )
                        .padding(.horizontal)
                    }

                    Spacer()

                    VStack(spacing: 8) {
                        Text("Ареометры калибруются при 20°C")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text("При других температурах необходима коррекция показаний")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.bottom, 20)
                }
            }
            // ⬇️ ВСЕ НУЖНЫЕ МОДИФИКАТОРЫ ЗДЕСЬ
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

    // MARK: - Logic

    private func calculate() {
        guard let temp = parseDouble(temperature),
              let measured = parseDouble(measuredStrength) else {
            return
        }

        let tempDiff = temp - 20.0

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

        if realStrength < 0 {
            realStrength = 0
        } else if realStrength > 100 {
            realStrength = 100
        }
    }

    private func saveCalculation() {
        let inputs =
        "Температура: \(temperature)°C, Показание: \(measuredStrength)°"

        let result =
        String(format: "Реальная крепость: %.2f°", realStrength)

        let calculation = CalculationResult(
            name: calculationName.isEmpty
                ? "Коррекция ареометра"
                : calculationName,
            type: "Коррекция ареометра",
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
    AreometerCorrectionView()
}
