import SwiftUI
import SwiftData

struct PaymentMethodPicker: View {
    @Query(sort: \PaymentMethod.nickname) private var paymentMethods: [PaymentMethod]
    @Binding var selectedPaymentMethod: PaymentMethod?
    @Environment(\.modelContext) private var modelContext
    @State private var showAddPaymentMethod = false

    /// Only show active (non-archived) payment methods in picker
    private var activePaymentMethods: [PaymentMethod] {
        paymentMethods.filter { !$0.isArchived }
    }

    var body: some View {
        Menu {
            ForEach(activePaymentMethods) { method in
                Button {
                    selectedPaymentMethod = method
                } label: {
                    HStack {
                        Image(systemName: method.methodType.iconName)
                        Text(method.displayName)
                        if selectedPaymentMethod?.persistentModelID == method.persistentModelID {
                            Image(systemName: "checkmark")
                                .foregroundColor(Color.Catppuccin.blue)
                        }
                    }
                }
            }

            Divider()

            Button {
                showAddPaymentMethod = true
            } label: {
                Label("Add New Method", systemImage: "plus.circle.fill")
            }
        } label: {
            HStack {
                if let selected = selectedPaymentMethod {
                    Image(systemName: selected.methodType.iconName)
                        .foregroundColor(selected.methodType.color)
                    Text(selected.displayName)
                        .foregroundColor(Color.Catppuccin.text)
                } else {
                    Text("Select Payment Method")
                        .foregroundColor(Color.Catppuccin.subtext0)
                }

                Spacer()

                Image(systemName: "chevron.down")
                    .font(.caption)
                    .foregroundColor(Color.Catppuccin.subtext0)
            }
            .padding()
            .background(Color.Catppuccin.mantle)
            .cornerRadius(8)
        }
        .sheet(isPresented: $showAddPaymentMethod) {
            PaymentMethodEditSheet(paymentMethod: nil, modelContext: modelContext)
        }
    }
}
