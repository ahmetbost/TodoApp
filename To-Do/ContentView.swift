//
//  ContentView.swift
//  To-Do
//
//  Created by Ahmet Bostancıoğlu on 30.04.2025.
//

import SwiftUI

struct ContentView: View {

    struct Todo: Codable, Identifiable {
        var id = UUID()
        var text: String
        
        init(_ text: String) {
            self.text = text
        }
    }
    
    @State private var newTodoText = String()
    @AppStorage("todos") private var todosData: Data = Data()
    @FocusState private var isFocused: Bool
    
    var todos: [Todo] {
        get {
            
            do {
                return try JSONDecoder().decode([Todo].self, from: todosData)
            } catch {
                print("Decode error: \(error)")
                return []
            }
            
        } set {
            do {
                todosData = try JSONEncoder().encode(newValue)
            } catch {
                print("Encode error: \(error)")
                todosData = Data()
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                List {
                    ForEach(todos) { todo in
                        Text(todo.text)
                    }
                    .onDelete(perform: delete)
                    .onMove(perform: move)
                }
                .listStyle(.plain)
                .padding(.bottom, 85)

                
                Section {
                    HStack {
                        TextField("New Task", text: $newTodoText)
                            .textFieldStyle(RoundedTextFieldStyle())
                            .onSubmit {
                                save()
                            }
                            .focused($isFocused)
                        
                        
                        Button {
                            save()
                        } label: {
                            Image(systemName: "plus")
                                .padding()
                                .background(.green)
                                .foregroundStyle(.white)
                                .clipShape(.circle)
                                .overlay (
                                    Circle()
                                        .strokeBorder(.black, lineWidth: 1)
                                )
                        }
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
            }
            .navigationTitle("to-dooo!")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button("Done") {
                            isFocused = false
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                        EditButton()
                }
            }
            .scrollDismissesKeyboard(.immediately)
        }
    }
    
    func save() {
        guard !newTodoText.isEmpty else { return }
        
        var currentTodos = todos
        let newTodo = Todo(newTodoText)
        currentTodos.append(newTodo)
        
        if let encoded = try? JSONEncoder().encode(currentTodos) {
            todosData = encoded
        }
        
        newTodoText = ""
    }
    
    func delete(at offsets: IndexSet) {
        var currentTodos = todos
        currentTodos.remove(atOffsets: offsets)
        todosData = (try? JSONEncoder().encode(currentTodos)) ?? Data()
    }
    
    func move(from source: IndexSet, to destination: Int) {
        var currentTodos = todos
        currentTodos.move(fromOffsets: source, toOffset: destination)
        todosData = (try? JSONEncoder().encode(currentTodos)) ?? Data()
    }
    
}

struct RoundedTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.vertical, 15)
            .padding(.horizontal, 24)
            .background(.white)
            .clipShape(Capsule(style: .continuous))
            .overlay(
                Capsule()
                    .strokeBorder(lineWidth: 1)
            )
    }
}

#Preview {
    ContentView()
}
