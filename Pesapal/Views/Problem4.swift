//
//  Problem4.swift
//  Pesapal
//
//  Created by Ian on 31/01/2023.
//

import SwiftUI

struct Problem4: View {
    @EnvironmentObject private var problem4ViewModel: Problem4ViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                TextField("Enter Operators", text: $problem4ViewModel.text)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit(of: .text, problem4ViewModel.processText)
                Button(action: problem4ViewModel.processText) {
                    Text("Submit")
                }
            }
            .padding([.top, .horizontal])
            .frame(maxWidth: 500)
            
            Text(problem4ViewModel.infoString ?? "")
                .padding(.horizontal)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(problem4ViewModel.entries) { entry in
                        HStack {
                            Text(entry.text)
                            Text(entry.result)
                        }
                        .textSelection(.enabled)
                    }
                    Divider()
                    Text(problem4ViewModel.helpText)
                        .textSelection(.enabled)
                    HStack {
                        Spacer()
                    }
                }
                .padding([.horizontal, .bottom])
            }
        }
        .navigationTitle("Boolean logic interpreter")
    }
}

struct Problem4_Previews: PreviewProvider {
    static var previews: some View {
        Problem4()
            .environmentObject(Problem4ViewModel())
    }
}
