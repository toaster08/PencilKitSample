import Foundation
import SwiftUI
import PencilKit
import Vision
import CoreML

struct GameView: View {
    @SwiftUI.State private var recognizedNumber = ""
    let canvasView = CanvasView(canvas: PKCanvasView())
    @SwiftUI.State private var image: UIImage?
    
    var body: some View {
        VStack {
            Spacer()
            VStack {
                Text(self.recognizedNumber)
                ZStack(alignment: .topLeading) {
                    canvasView
                        .frame(
                            width: .infinity,
                            height: 300
                        )
                    if let image {
                        Image(uiImage: image)
                            .resizable()
                            .frame(width: 50, height: 50, alignment: .topLeading)
                            .background(.black)
                            .border(.white)
                    }
                }
                Button(action: {
                    self.recognize()
                    self.canvasView.reset()
                }, label: {
                    Text("回答する")
                })
                Button(action: {
                    self.canvasView.reset()
                }, label: {
                    Text("Reset")
                })
            }
        }
    }
    
    func recognize() {
        let model = try! VNCoreMLModel(for: MNISTClassifier.init(configuration: .init()).model)
        let request = VNCoreMLRequest(model: model) { request, error in
            guard let results = request.results as? [VNClassificationObservation] else {return}
            print("🚀results: \(results)")
            self.recognizedNumber = results.first?.identifier ?? ""
        }
        request.usesCPUOnly = true
        let inputImage = canvasView.canvas.drawing.image(from: canvasView.canvas.bounds, scale: 1)
        self.image = inputImage

        let handler = VNImageRequestHandler(cgImage: inputImage.cgImage!)
        do {
            try handler.perform([request])
        } catch {
            print(error.localizedDescription)
        }
    }
}

#Preview {
    GameView()
}


struct CanvasView: UIViewRepresentable {
  let canvas: PKCanvasView
  
  func makeUIView(context: Context) -> some UIView {
    canvas.backgroundColor = .black
    canvas.drawingPolicy = .anyInput
    
    let toolPicker = PKToolPicker()
    toolPicker.addObserver(canvas)
    toolPicker.setVisible(true, forFirstResponder: canvas)
    canvas.becomeFirstResponder()
    canvas.tool = PKInkingTool(.monoline, color: .white, width: 10)
    return canvas
  }
  
  func updateUIView(_ uiView: UIViewType, context: Context) {}
  
  func reset() {
    canvas.drawing = PKDrawing()
  }
}
