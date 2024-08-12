//
//  UpdateNoteView.swift
//  My Notes
//
//  Created by Septem Systems on 8/12/24.
//

import SwiftUI

struct UpdateNoteView: View {
    @Binding var updateNoteText: String
    @Binding var noteId: String
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        HStack{
            TextField("Write Note...", text: $updateNoteText)
                .padding(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
                .clipped()
                .border(Color.gray, width: 1)
                .cornerRadius(4)
            Button(action: {
                updateNote()
            }, label: { Text("Update")})
        }.padding(8)
    }
    
    func updateNote() {
        let params = ["note": updateNoteText ] as [String: Any]
        let url = URL(string: "http://localhost:3000/notes/\(self.noteId)")!
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        do{
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
        }
        catch{
            print(error)
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = session.dataTask(with: request, completionHandler: {data, res, err in
            guard err == nil else {return}
            guard let data = data else {return}
            
            do{
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]
                {
                    print("update response :: \(json)")
                    presentationMode.wrappedValue.dismiss()
                }
            }
            catch{
                print(error)
            }
            
        })
        task.resume()
        
    }
}

struct UpdateNoteView_Previews: PreviewProvider {
    @State static var someUpdateText = "Some note text"
    @State static var noteId = "noteId"
    static var previews: some View {
        UpdateNoteView(updateNoteText:$someUpdateText, noteId: $noteId)
    }
}

