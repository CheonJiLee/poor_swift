//
//  CaputureCamera.swift
//  roop
//
//  Created by 이천지 on 2016. 10. 9..
//  Copyright © 2016년 project. All rights reserved.
//

import UIKit
import AVFoundation

class CaputureCamera: UIViewController,AVCapturePhotoCaptureDelegate {
    
    @IBOutlet weak var cam: UIView!
    
    var connectImage = UIImage()
    var status = false
    @IBAction func tak(_ sender: AnyObject) {
        saveToCamera()
    }
    
    override func prepare(for segue:UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! RegisterNew
        destination.setImage = connectImage
    }
    
    
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var stillImageOutput: AVCapturePhotoOutput?
    private var capturedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startCamera()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    private func startCamera() {
        captureSession = AVCaptureSession()
        captureSession!.sessionPreset = AVCaptureSessionPresetPhoto
        let frontcam = AVCaptureDeviceDiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaTypeVideo, position: .back).devices.first
        do {
            let input = try AVCaptureDeviceInput(device: frontcam)
            
            
            captureSession!.addInput(input)
            
            stillImageOutput = AVCapturePhotoOutput()
            captureSession!.addOutput(stillImageOutput)
            
            if let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession) {
                previewLayer.position = CGPoint(x:self.cam.frame.width / 2, y:self.cam.frame.height / 2)
                cam.layer.addSublayer(previewLayer)
                
                previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
                previewLayer.connection.videoOrientation = AVCaptureVideoOrientation.portrait
                
                previewLayer.bounds = cam.frame
                
            }
            
        } catch let error as NSError {
            print(error)
        }
        
        captureSession?.startRunning()
        
    }
    private func saveToCamera() {
        guard let connection = stillImageOutput?.connection(withMediaType: AVMediaTypeVideo) else { return }
        connection.automaticallyAdjustsVideoMirroring = true
        
        
        let settings = AVCapturePhotoSettings()
        let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
        let previewFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
                             kCVPixelBufferWidthKey as String: 160,
                             kCVPixelBufferHeightKey as String: 160,
                             ]
        settings.previewPhotoFormat = previewFormat
        
        stillImageOutput?.capturePhoto(with: settings, delegate: self)
        
    }
    
    public func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        
        let data = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer!, previewPhotoSampleBuffer: previewPhotoSampleBuffer)
        
        if let data = data {
            self.capturedImage = UIImage(data: data)
            self.connectImage = UIImage(data: data)!
            UIImageWriteToSavedPhotosAlbum(self.capturedImage!, self,nil, nil)
            self.performSegue(withIdentifier: "connectSegue", sender: self)
        }
    }
}
