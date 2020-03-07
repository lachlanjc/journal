//
//  ContentView.swift
//  Journal
//
//  Created by Lachlan Campbell on 3/7/20.
//  Copyright © 2020 Lachlan Campbell. All rights reserved.
//

import SwiftUI
import UIKit
import PencilKit

private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .none
    return dateFormatter
}()

struct ContentView: View {
    @State private var dates = [Date]()

    var body: some View {
        NavigationView {
            MasterView(dates: $dates)
                .navigationBarTitle(Text("Journal"))
                .navigationBarItems(
                    leading: EditButton(),
                    trailing: Button(
                        action: {
                            withAnimation { self.dates.insert(Date(), at: 0) }
                        }
                    ) {
                        Image(systemName: "square.and.pencil")
                    }
                )
            DetailView()
        }.navigationViewStyle(DoubleColumnNavigationViewStyle())
    }
}

struct MasterView: View {
    @Binding var dates: [Date]

    var body: some View {
        List {
            ForEach(dates, id: \.self) { date in
                NavigationLink(
                    destination: DetailView(selectedDate: date)
                ) {
                    Text("\(date, formatter: dateFormatter)")
                }
            }.onDelete { indices in
                indices.forEach { self.dates.remove(at: $0) }
            }
        }
    }
}

struct DetailView: View {
    var selectedDate: Date?
    @State var color = UIColor.black
    @State var clear = false
    
    var body: some View {
        NavigationView {
            VStack {
                PKCanvas(color: $color, clear: $clear)
                HStack {
                    Button("Red") { self.color = UIColor.systemRed }.accentColor(.red)
                    Button("Orange") { self.color = UIColor.systemOrange }.accentColor(.orange)
                    Button("Green") { self.color = UIColor.systemGreen }.accentColor(.green)
                    Button("Blue") { self.color = UIColor.systemBlue }.accentColor(.blue)
                    Button("Black") { self.color = UIColor.black }.accentColor(.primary)
                    Spacer()
                    Button("Clear Canvas") { self.clear.toggle() }
                }.padding()
            }
            .navigationBarTitle(
                selectedDate != nil
                    ? Text("\(selectedDate!, formatter: dateFormatter)")
                    : Text("No date selected")
            ).navigationBarItems(trailing: HStack {
                Button(action: {
                }) {
                    Image(systemName: "square.and.arrow.up")
                }.padding(0)
            })
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct PKCanvas: UIViewRepresentable {
    class Coordinator: NSObject, PKCanvasViewDelegate {
        var pkCanvas: PKCanvas

        init(_ pkCanvas: PKCanvas) {
            self.pkCanvas = pkCanvas
        }
    }

    @Binding var color: UIColor
    @Binding var clear: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> PKCanvasView {
        let canvas = PKCanvasView()
        canvas.tool = PKInkingTool(.pen, color: color, width: 10)

        canvas.delegate = context.coordinator
        return canvas
    }

    func updateUIView(_ canvasView: PKCanvasView, context: Context) {
        if (clear != context.coordinator.pkCanvas.clear) {
            canvasView.drawing = PKDrawing()
        }
        canvasView.tool = PKInkingTool(.pen, color: color, width: 10)
    }
}
