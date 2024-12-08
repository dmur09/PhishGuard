// PhishingIdentifier uses machine learning to detect whether input text is a phishing attempt
// Ewan created a new dataset by sampling from the phishing dataset from https://huggingface.co/datasets/ealvaradob/phishing-dataset/tree/main and SMS spam dataset from https://www.kaggle.com/datasets/uciml/sms-spam-collection-dataset?resource=download
// The initial identifier is from Dr. Cibrian's lesson implementing machine learning into Swift, Ewan added code here and there to conform it to our app
// References: Dr. Cirbian's lesson on implementing machine learning into Swift

import Foundation
import SwiftUI
import CoreML
import NaturalLanguage

// Phishing Identifier class utilizes a machine learning model from CreateML to give a prediciton and confidence percentage
class PhishingIdentifier: ObservableObject {
    @Published var prediction = "" // prediction as a string
    @Published var confidence = 0.0 // confidence percentage in decimal
    var model: MLModel
    var phishingPredictor: NLModel

    init() {
        do {
            let config = MLModelConfiguration()
            self.model = try PhishingClassifier(configuration: config).model // PhishingClassifier is a machine learning model trained with a data that Ewan sampled from Phishing and Spam datasets
            self.phishingPredictor = try NLModel(mlModel: model) // use the machine learning model
        } catch {
            print("Error loading model: \(error)") // error handling
            self.model = MLModel()
            self.phishingPredictor = NLModel() // use the machine learning model
        }
    }

    func predict(_ text: String) { // function to predict whether the input text is phishing or not
        DispatchQueue.main.async {
            self.prediction = self.phishingPredictor.predictedLabel(for: text) ?? "" // output predicted label
            let predictionSet = self.phishingPredictor.predictedLabelHypotheses(for: text, maximumCount: 1)
            self.confidence = predictionSet[self.prediction] ?? 0.0 // confidence percentage as a decimal
        }
    }
}
