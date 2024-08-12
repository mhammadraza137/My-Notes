//
//  ContentView.swift
//  My Notes
//
//  Created by Septem Systems on 8/10/24.
//

import SwiftUI

struct Home: View {
    
    @State var notes = [Note]()
    @State var showAddSheet = false
    @State var showDeleteAlert: Bool = false
    @State var deleteNote: Note?
    @State var isEditMode: EditMode = .inactive
    @State var updateNote = ""
    @State var updateNoteId = ""
    var deleteNoteAlert: Alert{
        Alert(title: Text("Are you sure you want to delete note?"), primaryButton: .destructive(Text("Delete"),action: deleteNotes), secondaryButton: .cancel())
    }
    
    var body: some View {
        NavigationStack{
            List(notes){ note in
                if isEditMode == .inactive {
                    Text(note.note)
                        .padding()
                        .onLongPressGesture {
                            deleteNote = note
                            self.showDeleteAlert.toggle()
                        }
                } else{
                    HStack{
                        Image(systemName: "pencil.circle.fill")
                            .foregroundColor(.blue)
                        Text(note.note)
                            .padding()
                    }
                    .onTapGesture {
                        updateNote = note.note
                        updateNoteId = note._id
                        self.showAddSheet.toggle()
                    }
                }
                
            }
            .onAppear(perform: {
                fetchNotes()
            })
            .alert(isPresented: $showDeleteAlert, content: {
                deleteNoteAlert
            })
            .sheet(isPresented: $showAddSheet,onDismiss: fetchNotes, content: {
                if isEditMode == .inactive {
                    CreateNoteView()
                } else {
                    UpdateNoteView(updateNoteText: $updateNote, noteId: $updateNoteId)
                }
                
            })
            .navigationTitle("Notes")
            .toolbar{
                ToolbarItem(placement: .navigationBarTrailing){
                    Button(action: {
                        self.showAddSheet.toggle()
                    },label: {Text("Add")})
                }
                ToolbarItem(placement: .navigationBarLeading){
                    Button(action: {
                        if isEditMode == .inactive {
                            isEditMode = .active
                        } else{
                            isEditMode = .inactive
                        }
                    },
                           label: {
                        if isEditMode == .inactive{
                            Text("Edit")
                        } else{
                            Text("Done")
                        }
                        
                    })
                }
            }
        }
    }
    func deleteNotes()-> Void {
        print("hiiiiii")
        guard let deleteNoteId = deleteNote?._id else {return}
        let url = URL(string: "http://localhost:3000/notes/\(deleteNoteId)")!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        let task = URLSession.shared.dataTask(with: request){data, res, err in
            guard err == nil else {return}
            guard let data = data else {return}
            print(String(data:data,encoding: .utf8) as Any)
        }
        task.resume()
        fetchNotes()
    }
    func fetchNotes() -> Void {
        let url = URL(string: "http://localhost:3000/notes")!
        let task = URLSession.shared.dataTask(with: url){ data, res, err in
            guard let data = data else {return}
            do{
                let notes = try JSONDecoder().decode([Note].self, from: data)
                self.notes = notes
                print(notes)
            }
            catch{
                print(error)
            }
            
        }
        task.resume()
        if isEditMode == .active {
            isEditMode = .inactive
        }
    }
}

struct Note: Identifiable, Codable{
    var id: String {_id}
    var _id: String
    var note: String
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
