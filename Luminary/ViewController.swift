//
//  ViewController.swift
//  Luminary
//
//  Created by Cai, Weiqi on 1/25/18.
//  Copyright © 2018 Cai, Weiqi. All rights reserved.
//

import ARKit
import ReplayKit
import SceneKit
import UIKit

struct FaceMesh: Codable {
    let time: String
    let frame: [String: String]
}

class ViewController: UIViewController, RPPreviewViewControllerDelegate, ARSCNViewDelegate, ARSessionDelegate {
    
    // ARKit UI
    @IBOutlet var sceneView: ARSCNView!
    
    // Recorder UI
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var colorPicker: UISegmentedControl!
    @IBOutlet var colorDisplay: UIView!
    @IBOutlet var recordButton: UIButton!
    @IBOutlet var micToggle: UISwitch!
    
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    var meterTimer: Timer!
    var soundFileURL: URL!
    var fileNameTime: Date!
    let screenRecorder = RPScreenRecorder.shared()
    private var isRecording = false
    
    // Face Tracking start point
    private var faceNode = SCNNode()
    // Node storing geometry
    private var virtualFaceNode = SCNNode()
    
    // Serial queue setting
    private let serialQueue = DispatchQueue(label: "com.test.FaceTracking.serialSceneKitQueue")

    // Json data
    var faceMeshList = [FaceMesh]()
    var prevTimestamp = NSDate().timeIntervalSince1970
    var lineCount = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recordButton.layer.cornerRadius = 32.5
        
        initBlackARScene()
    }
    
    // Set up black AR Scene and face wirefame
    func initBlackARScene() {
        // If Face Tracking can not be used, execution of instructions below this is not executed
        guard ARFaceTrackingConfiguration.isSupported else { return }
        
        // In the case of the Face Tracking application, since the situation that the screen does not touch continues, the screen lock is stopped
        UIApplication.shared.isIdleTimerDisabled = true
        
        // Delegate of ARSCNView and ARSession, setting surrounding light
        sceneView.delegate = self
        sceneView.session.delegate = self
        sceneView.automaticallyUpdatesLighting = true
        
        // Wire frame display
        sceneView.debugOptions = .showWireframe
        
        sceneView.scene.background.contents = UIColor.black
        
        // Set ARSCNFaceGeometry to virtualFaceNode
        let device = sceneView.device!
        let maskGeometry = ARSCNFaceGeometry(device: device)!
        
        // Make the color of the geometry black
        maskGeometry.firstMaterial?.diffuse.contents = UIColor.black
        maskGeometry.firstMaterial?.lightingModel = .physicallyBased
        
        virtualFaceNode.geometry = maskGeometry
        
        // Perform tracking initialization
        resetTracking()
    }
    
    // Set up Face Tracking
    // Delete all tracking reset and anchor in option and start session
    func resetTracking() {
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    @objc func updateAudioMeter(_ timer: Timer) {
        
        if let recorder = self.audioRecorder {
            if recorder.isRecording {
                let min = Int(recorder.currentTime / 60)
                let sec = Int(recorder.currentTime.truncatingRemainder(dividingBy: 60))
                let s = String(format: "%02d:%02d", min, sec)
//                statusLabel.text = s
                recorder.updateMeters()
                // if you want to draw some graphics...
                //var apc0 = recorder.averagePowerForChannel(0)
                //var peak0 = recorder.peakPowerForChannel(0)
            }
        }
    }
    
    @IBAction func recordButtonTapped() {
        print("tapped", self.recordButton.backgroundColor!, self.lineCount)
        if !isRecording {
            self.recordButton.backgroundColor = UIColor.red
            startRecording()
        } else {
            self.lineCount += 1
            self.recordButton.backgroundColor = UIColor.white
            stopRecording()
        }
    }
    
    func startRecording() {
        
        guard screenRecorder.isAvailable else {
            print("Screen recording is not available at this time.")
            return
        }
        
        if micToggle.isOn {
            screenRecorder.isMicrophoneEnabled = true
        } else {
            screenRecorder.isMicrophoneEnabled = false
        }
        
        screenRecorder.startRecording{ [unowned self] (error) in
            
            guard error == nil else {
                print("There was an error starting the recording.")
                return
            }
            
            self.recordAudioWithPermission(true)
            print("Started Recording Successfully")
//            self.statusLabel.text = "Recording..."
//            self.statusLabel.textColor = UIColor.red
            
            self.isRecording = true
        }
        
    }
    
    func recordAudioWithPermission(_ setup: Bool) {
        print("\(#function)")
        
        AVAudioSession.sharedInstance().requestRecordPermission {
            [unowned self] granted in
            if granted {
                
                DispatchQueue.main.async {
                    print("Permission to record granted")
                    self.setSessionPlayAndRecord()
                    if setup {
                        self.setupRecorder()
                    }
                    self.audioRecorder.record()
                    
                    self.meterTimer = Timer.scheduledTimer(timeInterval: 0.1,
                                                           target: self,
                                                           selector: #selector(self.updateAudioMeter(_:)),
                                                           userInfo: nil,
                                                           repeats: true)
                }
            } else {
                print("Permission to record not granted")
            }
        }
        
        if AVAudioSession.sharedInstance().recordPermission() == .denied {
            print("permission denied")
        }
    }
    
    func setupRecorder() {
        print("\(#function)")
        
        let format = DateFormatter()
        format.dateFormat="yyyy-MM-dd-HH-mm-ss"
        fileNameTime = Date()
        let currentFileName = "recording-\(format.string(from: fileNameTime)).m4a"
        print(currentFileName)
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.soundFileURL = documentsDirectory.appendingPathComponent(currentFileName)
        print("writing to soundfile url: '\(soundFileURL!)'")
        
        if FileManager.default.fileExists(atPath: soundFileURL.absoluteString) {
            // probably won't happen. want to do something about it?
            print("soundfile \(soundFileURL.absoluteString) exists")
        }
        
        let recordSettings: [String: Any] = [
            AVFormatIDKey: kAudioFormatAppleLossless,
            AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue,
            AVEncoderBitRateKey: 32000,
            AVNumberOfChannelsKey: 2,
            AVSampleRateKey: 44100.0
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: soundFileURL, settings: recordSettings)
            audioRecorder.delegate = self
            audioRecorder.isMeteringEnabled = true
            audioRecorder.prepareToRecord() // creates/overwrites the file at soundFileURL
        } catch {
            audioRecorder = nil
            print(error.localizedDescription)
        }
        
    }
    
    func setSessionPlayAndRecord() {
        print("\(#function)")
        
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord, with: .defaultToSpeaker)
        } catch {
            print("could not set session category")
            print(error.localizedDescription)
        }
        
        do {
            try session.setActive(true)
        } catch {
            print("could not make session active")
            print(error.localizedDescription)
        }
    }
    
    override func prefersHomeIndicatorAutoHidden() -> Bool {
        return true
    }
    
    // Initialize tracking when this ViewController is displayed
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        resetTracking()
    }
    
    // Stop the session if this ViewController is hidden
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    
    // Initial setting of node as the origin of Face Tracking
    private func setupFaceNodeContent() {
        // Erase tilde nodes below faceNode
        for child in faceNode.childNodes {
            child.removeFromParentNode()
        }
        
        // Add the virtualFaceNode containing the geometry of the mask to the node
        faceNode.addChildNode(virtualFaceNode)
    }
    
    func stopRecording() {
        
        screenRecorder.stopRecording { [unowned self] (preview, error) in
            print("Stopped recording")
            
            guard preview != nil else {
                print("Preview controller is not available.")
                return
            }
            
            let alert = UIAlertController(title: "Recording Finished", message: "Would you like to edit or delete your recording?", preferredStyle: .alert)
            
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: { (action: UIAlertAction) in
                self.screenRecorder.discardRecording(handler: { () -> Void in
                    self.lineCount -= 1
                    print("Recording suffessfully deleted.")
                })
            })
            
            let editAction = UIAlertAction(title: "Edit", style: .default, handler: { (action: UIAlertAction) -> Void in
                preview?.previewControllerDelegate = self
                self.present(preview!, animated: true, completion: nil)
            })
            
            alert.addAction(editAction)
            alert.addAction(deleteAction)
            self.present(alert, animated: true, completion: nil)
            
            self.isRecording = false
            self.viewReset()
            
        }
        
    }
    
    func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
        dismiss(animated: true)
    }
    
    func viewReset() {
        micToggle.isEnabled = true
//        statusLabel.text = "Ready to Record"
//        statusLabel.textColor = UIColor.black
//        recordButton.backgroundColor = UIColor.red
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - ARSCNViewDelegate
    /// ARNodeTracking start
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        faceNode = node
        serialQueue.async {
            self.setupFaceNodeContent()
        }
    }
    
    /// ARNodeTracking Update. Change contents of ARSCNFaceGeometry
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor else { return }
        
        let geometry = virtualFaceNode.geometry as! ARSCNFaceGeometry
        
        var curBlendShapeDict = [String: String]()
        
        if (isRecording) {
            for (blendShapeLocation, number) in faceAnchor.blendShapes {
                curBlendShapeDict[blendShapeLocation.rawValue] = String(format: "%.4f", number.doubleValue)
            }
            let timestamp = NSDate().timeIntervalSince1970
            // 25 frame per second
            if (timestamp - prevTimestamp > 0.05) {
                prevTimestamp = timestamp
                let faceMesh = FaceMesh(time: String(format: "%.3f", timestamp), frame: curBlendShapeDict)
                faceMeshList.append(faceMesh)
            }
        }
        
        geometry.update(from: faceAnchor.geometry)
    }
    
    // MARK: - ARSessionDelegate
    /// Error and suspend processing
    func session(_ session: ARSession, didFailWithError error: Error) {
        guard error is ARError else { return }
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        DispatchQueue.main.async {
            // Resume tracking after returning from interruption
            self.resetTracking()
        }
    }
    
    // Helper method to get a URL to the user's documents directory
    // see https://developer.apple.com/icloud/documentation/data-storage/index.html
    func getDocumentsURL() -> URL {
        if let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            return url
        } else {
            fatalError("Could not retrieve documents directory")
        }
    }
    
    func saveFacemashesToDisk(faceMeshes: [FaceMesh]) {
        // 1. Create a UR`L for documents-directory/posts.json
        let format = DateFormatter()
        format.dateFormat="yyyy-MM-dd-HH-mm-ss"
        let url = getDocumentsURL().appendingPathComponent("faceinfo-\(format.string(from: fileNameTime)).json")
        // 2. Endcode our [Post] data to JSON Data
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(faceMeshes)
            // 3. Write this data to the url specified in step 1
            print(data)
            try data.write(to: url, options: [])
            
            print("Face mash info saved to \(url)")
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func getFaceMashesFromDisk() -> [Dictionary<String, Double>] {
        // 1. Create a url for documents-directory/posts.json
        let url = getDocumentsURL().appendingPathComponent("facemeshes.json")
        let decoder = JSONDecoder()
        do {
            // 2. Retrieve the data on the file in this path (if there is any)
            let data = try Data(contentsOf: url, options: [])
            // 3. Decode an array of Posts from this Data
            let facemashes = try decoder.decode([Dictionary<String, Double>].self, from: data)
            return facemashes
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "LineCardViewSegue" {
            let destinationViewController: LineCardViewController = segue.destination as! LineCardViewController
            destinationViewController.initIndex = self.lineCount
        }
    }
}

// MARK: AVAudioRecorderDelegate
extension ViewController: AVAudioRecorderDelegate {
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder,
                                         successfully flag: Bool) {
        
        print("\(#function)")
        
        print("finished recording \(flag)")
        
        // iOS8 and later
        let alert = UIAlertController(title: "Recorder",
                                      message: "Finished Recording",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Keep", style: .default) {[unowned self] _ in
            print("keep was tapped")
            self.audioRecorder = nil
        })
        alert.addAction(UIAlertAction(title: "Delete", style: .default) {[unowned self] _ in
            print("delete was tapped")
            self.audioRecorder.deleteRecording()
        })
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder,
                                          error: Error?) {
        print("\(#function)")
        
        if let e = error {
            print("\(e.localizedDescription)")
        }
    }
    
}


