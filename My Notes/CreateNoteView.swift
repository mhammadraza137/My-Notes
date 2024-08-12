//
//  CreateNoteView.swift
//  My Notes
//
//  Created by Septem Systems on 8/11/24.
//

import SwiftUI

struct CreateNoteView: View {
    @State var createNoteText: String = ""
    @State var showError: Bool = false
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        VStack{
            HStack{
                TextField("Write Note...", text: $createNoteText)
                    .padding(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
                    .clipped()
                    .border(Color.gray, width: 1)
                    .cornerRadius(4)
                Button(action: postNote, label: { Text("Add")})
            }.padding(8)
            if showError && createNoteText.isEmpty{
                HStack(){
                    Text("Text cannot be empty")
                        .padding(.top, 5)
                        .foregroundColor(.red)
                        .font(.caption)
                    Spacer()
                }.padding(.leading,8)
                    
            }
        }
    }
    func postNote() {
        if createNoteText.isEmpty{
            showError = true
        }
        else
        {
            showError = false
            let params = ["note": createNoteText] as [String: Any]
            let url = URL(string: "http://localhost:3000/notes")!
            let session = URLSession.shared
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
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
                        print(json)
                    }
                }
                catch{
                    print(error)
                }
                
            })
            task.resume()
            createNoteText = ""
            presentationMode.wrappedValue.dismiss()
        }
    }
}

struct CreateNoteView_Previews: PreviewProvider {
    static var previews: some View {
        CreateNoteView()
    }
}
