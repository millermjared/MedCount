//
//  PillCounterView.swift
//  MedCount
//
//  Created by Mathew Miller on 11/5/21.
//

import UIKit
import AVFoundation

class PillCounterView: UIView {

    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var serialBackgroundQueue = DispatchQueue(label: "sessionManagementQueue")
    private var operationQueue = OperationQueue()
    
    static func checkPermissions(callback: @escaping (Result<Bool, Error>)->()) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        if status != .authorized {
            AVCaptureDevice.requestAccess(for: .video) { granted in
                callback(.success(granted))
            }
        } else {
            callback(.success(true))
        }        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .black
        
    }
    
}
