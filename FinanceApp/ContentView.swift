import SwiftUI

// MARK: - Models
enum ExpenseCategory: String, CaseIterable, Identifiable, Codable {
    case groceries = "Groceries"
    case foodDining = "Food & Dining"
    case housing = "Rent & Housing"
    case transport = "Transport"
    case utilities = "Utilities"
    case shopping = "Shopping"
    case entertainment = "Entertainment"
    case health = "Health & Medical"
    case travel = "Travel"
    case education = "Education"
    case investments = "Investments"
    case other = "Other"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .groceries: return "cart.fill"
        case .foodDining: return "fork.knife"
        case .housing: return "house.fill"
        case .transport: return "car.fill"
        case .utilities: return "bolt.fill"
        case .shopping: return "bag.fill"
        case .entertainment: return "tv.fill"
        case .health: return "heart.fill"
        case .travel: return "airplane"
        case .education: return "book.fill"
        case .investments: return "chart.line.uptrend.xyaxis"
        case .other: return "ellipsis.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .groceries: return Color(hex: "15803D")
        case .foodDining: return Color(hex: "EA580C")
        case .housing: return Color(hex: "2563EB")
        case .transport: return Color(hex: "0891B2")
        case .utilities: return Color(hex: "D97706")
        case .shopping: return Color(hex: "DB2777")
        case .entertainment: return Color(hex: "7C3AED")
        case .health: return Color(hex: "DC2626")
        case .travel: return Color(hex: "0D9488")
        case .education: return Color(hex: "4F46E5")
        case .investments: return Color(hex: "16A34A")
        case .other: return Color(hex: "64748B")
        }
    }
}

enum PaymentMethod: String, CaseIterable, Identifiable, Codable {
    case card = "Card"
    case cash = "Cash"
    case bank = "Bank Transfer"
    case upi = "Digital / Wallet"
    var id: String { rawValue }
}

struct ExpenseItem: Identifiable, Codable {
    var id = UUID()
    var title: String
    var amount: Double
    var category: ExpenseCategory
    var paymentMethod: PaymentMethod
    var date: Date
    var note: String
}

// MARK: - App State & ViewModel
class FinanceStore: ObservableObject {
    @Published var monthlySalary: Double = 5200.0
    @Published var currency: String = "₨" // Supports ₨, Rs., PKR, $, €, £
    @Published var expenses: [ExpenseItem] = [
        ExpenseItem(title: "Weekly Groceries", amount: 420.0, category: .groceries, paymentMethod: .card, date: Date(), note: "Restocking essentials"),
        ExpenseItem(title: "Cinema & Netflix", amount: 54.90, category: .entertainment, paymentMethod: .card, date: Date(), note: "Weekend movies"),
        ExpenseItem(title: "Electricity & Gas", amount: 180.0, category: .utilities, paymentMethod: .bank, date: Date(), note: "Monthly utility bills")
    ]
    
    var totalExpenses: Double {
        expenses.reduce(0) { $0 + $1.amount }
    }
    
    var remainingBalance: Double {
        monthlySalary - totalExpenses
    }
    
    var safeDailySpend: Double {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: Date()) ?? 1..<31
        let day = calendar.component(.day, from: Date())
        let daysLeft = max(1, range.count - day + 1)
        return max(0, remainingBalance / Double(daysLeft))
    }
}

// MARK: - Main ContentView
struct ContentView: View {
    @StateObject private var store = FinanceStore()
    @State private var selectedTab = 0
    @State private var showAddExpense = false
    @State private var showSalarySheet = false

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                DashboardView(store: store, onAddExpense: { showAddExpense = true }, onEditSalary: { showSalarySheet = true })
                    .navigationTitle("Financial Overview")
            }
            .tabItem {
                Label("Overview", systemImage: "chart.pie.fill")
            }
            .tag(0)

            NavigationStack {
                ExpenseListView(store: store, onAddExpense: { showAddExpense = true })
                    .navigationTitle("Expenses")
            }
            .tabItem {
                Label("Expenses", systemImage: "list.bullet.rectangle.portrait.fill")
            }
            .tag(1)
        }
        .tint(Color(hex: "2E6B2D"))
        .sheet(isPresented: $showAddExpense) {
            AddExpenseSheet(store: store)
        }
        .sheet(isPresented: $showSalarySheet) {
            SalaryConfigSheet(store: store)
        }
    }
}

// MARK: - Dashboard View (High Density Theme)
struct DashboardView: View {
    @ObservedObject var store: FinanceStore
    var onAddExpense: () -> Void
    var onEditSalary: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Main High Density Hero Card
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("REMAINING BALANCE")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(Color(hex: "B1F4A6"))
                            Text("\(store.currency)\(String(format: "%.2f", store.remainingBalance))")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                        Spacer()
                        Button(action: onEditSalary) {
                            Image(systemName: "pencil.circle.fill")
                                .font(.title2)
                                .foregroundColor(Color(hex: "B1F4A6"))
                        }
                    }

                    Divider().background(Color.white.opacity(0.2))

                    HStack {
                        VStack(alignment: .leading) {
                            Text("TOTAL SALARY").font(.caption2).foregroundColor(.white.opacity(0.7))
                            Text("\(store.currency)\(String(format: "%.2f", store.monthlySalary))")
                                .font(.subheadline).fontWeight(.semibold).foregroundColor(.white)
                        }
                        Spacer()
                        VStack(alignment: .leading) {
                            Text("EXPENSES").font(.caption2).foregroundColor(.white.opacity(0.7))
                            Text("\(store.currency)\(String(format: "%.2f", store.totalExpenses))")
                                .font(.subheadline).fontWeight(.semibold).foregroundColor(Color(hex: "FFB4AB"))
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text("SAFE DAILY").font(.caption2).foregroundColor(.white.opacity(0.7))
                            Text("\(store.currency)\(String(format: "%.0f", store.safeDailySpend))/d")
                                .font(.subheadline).fontWeight(.semibold).foregroundColor(Color(hex: "B1F4A6"))
                        }
                    }
                }
                .padding(20)
                .background(Color(hex: "111F0E"))
                .cornerRadius(24)
                .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color(hex: "2E6B2D"), lineWidth: 1))

                // Quick Add Action
                Button(action: onAddExpense) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add New Expense")
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "2E6B2D"))
                    .foregroundColor(.white)
                    .cornerRadius(16)
                }

                // Recent Items
                VStack(alignment: .leading, spacing: 10) {
                    Text("Recent Transactions")
                        .font(.headline)
                        .padding(.horizontal, 4)

                    ForEach(store.expenses.prefix(5)) { item in
                        HStack(spacing: 12) {
                            Image(systemName: item.category.icon)
                                .foregroundColor(item.category.color)
                                .frame(width: 36, height: 36)
                                .background(item.category.color.opacity(0.15))
                                .clipShape(Circle())

                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.title).font(.subheadline).fontWeight(.semibold)
                                Text(item.category.rawValue).font(.caption).foregroundColor(.secondary)
                            }
                            Spacer()
                            Text("-\(store.currency)\(String(format: "%.2f", item.amount))")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(Color(hex: "DC2626"))
                        }
                        .padding(12)
                        .background(Color(.systemBackground))
                        .cornerRadius(14)
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(.systemGray5), lineWidth: 1))
                    }
                }
            }
            .padding()
        }
        .background(Color(hex: "FBFDF8").ignoresSafeArea())
    }
}

// MARK: - Expense List View
struct ExpenseListView: View {
    @ObservedObject var store: FinanceStore
    var onAddExpense: () -> Void

    var body: some View {
        List {
            ForEach(store.expenses) { item in
                HStack {
                    Image(systemName: item.category.icon)
                        .foregroundColor(item.category.color)
                    VStack(alignment: .leading) {
                        Text(item.title).font(.headline)
                        Text("\(item.category.rawValue) • \(item.paymentMethod.rawValue)").font(.caption).foregroundColor(.secondary)
                    }
                    Spacer()
                    Text("-\(store.currency)\(String(format: "%.2f", item.amount))")
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: "DC2626"))
                }
            }
            .onDelete { indexSet in
                store.expenses.remove(atOffsets: indexSet)
            }
        }
        .toolbar {
            Button(action: onAddExpense) {
                Image(systemName: "plus")
            }
        }
    }
}

// MARK: - Sheets (Add Expense & Salary Settings)
struct AddExpenseSheet: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var store: FinanceStore
    @State private var title = ""
    @State private var amount = ""
    @State private var category = ExpenseCategory.groceries
    @State private var payment = PaymentMethod.card

    var body: some View {
        NavigationStack {
            Form {
                TextField("Title (e.g. Groceries)", text: $title)
                TextField("Amount (\(store.currency))", text: $amount)
                    .keyboardType(.decimalPad)
                Picker("Category", selection: $category) {
                    ForEach(ExpenseCategory.allCases) { cat in
                        Text(cat.rawValue).tag(cat)
                    }
                }
                Picker("Payment Method", selection: $payment) {
                    ForEach(PaymentMethod.allCases) { method in
                        Text(method.rawValue).tag(method)
                    }
                }
            }
            .navigationTitle("New Expense")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let val = Double(amount), !title.isEmpty {
                            store.expenses.insert(ExpenseItem(title: title, amount: val, category: category, paymentMethod: payment, date: Date(), note: ""), at: 0)
                            dismiss()
                        }
                    }
                }
            }
        }
    }
}

struct SalaryConfigSheet: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var store: FinanceStore
    @State private var salaryText = ""
    @State private var selectedCurrency = "₨"
    let currencies = ["₨", "Rs.", "PKR", "$", "€", "£", "₹", "AED", "SAR"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Monthly Base Salary") {
                    TextField("Salary", text: $salaryText)
                        .keyboardType(.decimalPad)
                }
                Section("Currency Symbol") {
                    Picker("Currency", selection: $selectedCurrency) {
                        ForEach(currencies, id: \.self) { c in
                            Text(c).tag(c)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .onAppear {
                salaryText = String(format: "%.0f", store.monthlySalary)
                selectedCurrency = store.currency
            }
            .navigationTitle("Salary & Currency")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let val = Double(salaryText) {
                            store.monthlySalary = val
                            store.currency = selectedCurrency
                            dismiss()
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Color Hex Extension
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let b = Double(rgbValue & 0x0000FF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}
