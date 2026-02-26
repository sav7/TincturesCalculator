import SwiftUI

struct DonationView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 20) {
                        // Иконка благодарности
                        Image(systemName: "heart.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.red)
                            .padding(.top, 20)
                        
                        // Заголовок
                        Text("Поддержать автора")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        // Подзаголовок
                        Text("Любой донат – автор рад")
                            .font(.title3)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        // QR-код
                        VStack(spacing: 12) {
                            Image("donation-qr")
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: 260)
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
                            
                            Text("Отсканируйте QR-код или нажмите на кнопку ниже")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        
                        // Кнопка открытия в браузере
                        Link(destination: URL(string: "https://tiny.keepz.me/khtc296w")!) {
                            HStack {
                                Image(systemName: "safari")
                                    .font(.title3)
                                Text("Открыть в браузере")
                                    .font(.headline)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.blue, Color.purple]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 10)
                        
                    }
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Готово") {
                                dismiss()
                            }
                        }
                    }
                }
            }
        }
    }
}
