import SwiftUI
import CoreData

struct IncomeListView: View {
    @State private var incomes: [IncomeEntity] = []
    @State private var showingAddIncome = false
    @State private var showingHelp = false
    @State private var totalIncome: Double = 0
    
    var body: some View {
        NavigationView {
            VStack {
                VStack(spacing: 8) {
                    Text("Total Income")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    Text(formatCurrency(totalIncome))
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
                
                List {
                    ForEach(incomes, id: \.id) { income in
                        IncomeRowView(income: income)
                    }
                    .onDelete(perform: deleteIncomes)
                }
            }
            .navigationTitle("Income")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Help") {
                        showingHelp = true
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddIncome = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddIncome, onDismiss: {
                loadIncomes()
            }) {
                SimpleIncomeEntry()
            }
            .sheet(isPresented: $showingHelp) {
                NavigationView {
                    IncomeHelpView()
                }
            }
            .onAppear {
                loadIncomes()
            }
            .refreshable {
                loadIncomes()
            }
        }
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "Rs. "
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        
        return formatter.string(from: NSNumber(value: value)) ?? "Rs. 0.00"
    }
    
    private func loadIncomes() {
        if let currentUser = CoreDataStack.shared.fetchCurrentUser() {
            incomes = CoreDataStack.shared.fetchIncomes(for: currentUser)
            totalIncome = incomes.reduce(0) { $0 + $1.amount }
        }
    }
    
    private func deleteIncomes(offsets: IndexSet) {
        for index in offsets {
            let income = incomes[index]
            CoreDataStack.shared.deleteIncome(income)
        }
        loadIncomes()
    }
}

struct IncomeRowView: View {
    let income: IncomeEntity
    
    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(Color(hex: income.categoryColor ?? "#4CAF50").opacity(0.15))
                    .frame(width: 40, height: 40)
                
                Image(systemName: income.categoryIcon ?? "dollarsign.circle.fill")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(hex: income.categoryColor ?? "#4CAF50"))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(income.categoryName ?? "Unknown")
                    .font(.system(size: 16, weight: .semibold))
                
                if let description = income.incomeDescription, !description.isEmpty {
                    Text(description)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                HStack {
                    Text(income.date?.formatted(date: .abbreviated, time: .omitted) ?? "Unknown Date")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    
                    if income.isRecurring {
                        Text("• Recurring")
                            .font(.system(size: 12))
                            .foregroundColor(.blue)
                    }
                }
            }
            
            Spacer()
            
            Text("Rs. \(income.amount, specifier: "%.2f")")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.green)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    IncomeListView()
}
