import SwiftUI

struct ContentView: View {
    @EnvironmentObject var themeSettings: ThemeSettings
    
    var body: some View {
        TabView {
            MixingCalculatorView()
                .tabItem {
                    Label("Смешение", systemImage: "flask")
                }
            
            DilutionCalculatorView()
                .tabItem {
                    Label("Разбавление", systemImage: "drop")
                }
            
            AreometerCorrectionView()
                .tabItem {
                    Label("Ареометр", systemImage: "thermometer")
                }
            
            SettingsView()
                .tabItem {
                    Label("Настройки", systemImage: "gear")
                }
        }
    }
}

struct SettingsView: View {
    @EnvironmentObject var themeSettings: ThemeSettings
    @AppStorage("savedCalculations") private var savedCalculationsData: Data = Data()
    @State private var savedCalculations: [CalculationResult] = []
    @State private var showingDeleteAlert = false
    
    var body: some View {
        NavigationView {
            List {
                Section("Тема оформления") {
                    Picker("Тема", selection: $themeSettings.theme) {
                        Text("Системная").tag(ThemeMode.system)
                        Text("Светлая").tag(ThemeMode.light)
                        Text("Тёмная").tag(ThemeMode.dark)
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Сохранённые расчёты") {
                    if savedCalculations.isEmpty {
                        Text("Нет сохранённых расчётов")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(savedCalculations) { calculation in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(calculation.name)
                                    .font(.headline)
                                Text(calculation.type)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text(calculation.result)
                                    .font(.body)
                                Text(calculation.date, style: .date)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                        .onDelete(perform: deleteCalculation)
                        
                        Button(role: .destructive) {
                            showingDeleteAlert = true
                        } label: {
                            Text("Удалить все расчёты")
                        }
                    }
                }
                
                Section("О приложении") {
                    HStack {
                        Text("Версия")
                        Spacer()
                        Text("1.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Настройки")
            .onAppear(perform: loadCalculations)
            .alert("Удалить все расчёты?", isPresented: $showingDeleteAlert) {
                Button("Отмена", role: .cancel) { }
                Button("Удалить", role: .destructive) {
                    deleteAllCalculations()
                }
            } message: {
                Text("Это действие нельзя отменить")
            }
        }
    }
    
    private func loadCalculations() {
        if let decoded = try? JSONDecoder().decode([CalculationResult].self, from: savedCalculationsData) {
            savedCalculations = decoded.sorted { $0.date > $1.date }
        }
    }
    
    private func deleteCalculation(at offsets: IndexSet) {
        savedCalculations.remove(atOffsets: offsets)
        saveCalculations()
    }
    
    private func deleteAllCalculations() {
        savedCalculations.removeAll()
        saveCalculations()
    }
    
    private func saveCalculations() {
        if let encoded = try? JSONEncoder().encode(savedCalculations) {
            savedCalculationsData = encoded
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(ThemeSettings())
}
