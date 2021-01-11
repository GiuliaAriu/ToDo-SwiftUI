import SwiftUI

struct ContentView: View {
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(fetchRequest: ToDoItem.getAllToDoItems()) var toDoItems: FetchedResults<ToDoItem>
    
    //We can use a text field to get the string that the user enters
    @State private var newToDoItem = ""
    @State private var showingAlert = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: CustomHeader(name: "What's next?", color: .purple)){
                    HStack {
                        TextField("New Item", text: $newToDoItem)
                        Button(action: {
                            if newToDoItem == "" {
                                showingAlert = true
                            } else {
                                let toDoItem = ToDoItem(context: managedObjectContext)
                                toDoItem.title = newToDoItem
                                toDoItem.createdAt = Date()
                                do {
                                    try managedObjectContext.save()
                                }
                                catch {
                                    print(error)
                                }
                            }
                            newToDoItem = ""
                        }){
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.purple)
                                .imageScale(.large)
                        }
                        .alert(isPresented: $showingAlert) {
                            Alert(title: Text("Error: empty field"), message: Text("Please insert a title"), dismissButton: Alert.Button.default(Text("OK")))
                        }
                    }
                }.font(.headline)
                
                Section(header: CustomHeader(name: "What to do?", color: .purple)){
                    ForEach(toDoItems) { toDoItem in
                        if let title = toDoItem.title, let date = toDoItem.createdAt {
                            ToDoItemView(title: title, date: getFormattedDate(from: date))
                        }
                    }.onDelete(perform: { indexSet in
                        guard let first = indexSet.first else { return }
                        let deletedItem = toDoItems[first]
                        managedObjectContext.delete(deletedItem)
                        do {
                            try managedObjectContext.save()
                        }
                        catch {
                            print(error)
                        }
                    })
                }
                .font(.headline)
            }
            .navigationBarTitle("My Plans")
        }
    }
    
    private func getFormattedDate(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        dateFormatter.locale = Locale.current
        return dateFormatter.string(from: date)
    }
}

struct CustomHeader: View {
    let name: String
    let color: Color

    var body: some View {
        HStack {
           Text(name)
               .font(.headline)
               .foregroundColor(.black)
               .padding()
           
           Spacer()
       }
        .background(color.opacity(0.2))
       .listRowInsets(EdgeInsets(
                       top: 0,
                       leading: 0,
                       bottom: 0,
                       trailing: 0))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
