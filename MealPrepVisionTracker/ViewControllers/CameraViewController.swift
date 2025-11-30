//
//  CameraViewController.swift
//  MealPrepVisionTracker
//
//  Created on 11/26/2025.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController, CameraPresentable {
    
    // MARK: - Properties
    
    weak var listener: PresentableListener? {
        get { return cameraListener }
        set { cameraListener = newValue as? CameraPresentableListener }
    }
    
    private weak var cameraListener: CameraPresentableListener?
    
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private let photoOutput = AVCapturePhotoOutput()
    
    private let captureButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 35
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "camera.fill"), for: .normal)
        button.tintColor = .white
        return button
    }()
    
    private let photoLibraryButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .systemGray5
        button.layer.cornerRadius = 25
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "photo.on.rectangle"), for: .normal)
        button.tintColor = .systemGreen
        return button
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        indicator.color = .white
        return indicator
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Scan Ingredients"
        view.backgroundColor = .black
        
        setupCamera()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let session = captureSession, !session.isRunning {
            DispatchQueue.global(qos: .userInitiated).async {
                session.startRunning()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let session = captureSession, session.isRunning {
            DispatchQueue.global(qos: .userInitiated).async {
                session.stopRunning()
            }
        }
    }
    
    // MARK: - Setup
    
    private func setupCamera() {
        checkCameraPermissions { [weak self] granted in
            if granted {
                self?.configureCaptureSession()
            } else {
                self?.showPermissionDeniedAlert()
            }
        }
    }
    
    private func checkCameraPermissions(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        default:
            completion(false)
        }
    }
    
    private func configureCaptureSession() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            DispatchQueue.main.async { [weak self] in
                self?.showCameraUnavailableAlert()
            }
            return
        }
        
        captureSession = AVCaptureSession()
        captureSession?.sessionPreset = .photo
        
        guard let captureSession = captureSession else {
            DispatchQueue.main.async { [weak self] in
                self?.showError("Failed to create camera session")
            }
            return
        }
        
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            DispatchQueue.main.async { [weak self] in
                self?.showCameraUnavailableAlert()
            }
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            } else {
                DispatchQueue.main.async { [weak self] in
                    self?.showError("Cannot configure camera input")
                }
                return
            }
        } catch {
            DispatchQueue.main.async { [weak self] in
                self?.showError("Camera input error: \(error.localizedDescription)")
            }
            return
        }
        
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.setupPreviewLayer()
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            captureSession.startRunning()
        }
    }
    
    private func setupPreviewLayer() {
        guard let captureSession = captureSession else { return }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.videoGravity = .resizeAspectFill
        previewLayer?.frame = view.bounds
        
        if let previewLayer = previewLayer {
            view.layer.insertSublayer(previewLayer, at: 0)
        }
    }
    
    private func setupUI() {
        view.addSubview(captureButton)
        view.addSubview(photoLibraryButton)
        view.addSubview(activityIndicator)
        
        captureButton.addTarget(self, action: #selector(capturePhoto), for: .touchUpInside)
        photoLibraryButton.addTarget(self, action: #selector(openPhotoLibrary), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            captureButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            captureButton.widthAnchor.constraint(equalToConstant: 70),
            captureButton.heightAnchor.constraint(equalToConstant: 70),
            
            photoLibraryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            photoLibraryButton.centerYAnchor.constraint(equalTo: captureButton.centerYAnchor),
            photoLibraryButton.widthAnchor.constraint(equalToConstant: 50),
            photoLibraryButton.heightAnchor.constraint(equalToConstant: 50),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    @objc private func openPhotoLibrary() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = false
        present(picker, animated: true)
    }
    
    // MARK: - Process Image
    
    private func processImage(_ image: UIImage) {
        cameraListener?.didCaptureImage(image)
    }
    
    // MARK: - CameraPresentable
    
    func showLoading() {
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicator.startAnimating()
        }
    }
    
    func hideLoading() {
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicator.stopAnimating()
        }
    }
    
    func showError(_ message: String) {
        DispatchQueue.main.async { [weak self] in
            let alert = UIAlertController(
                title: "Recognition Failed",
                message: message,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(alert, animated: true)
        }
    }
    
    private func showPermissionDeniedAlert() {
        DispatchQueue.main.async { [weak self] in
            let alert = UIAlertController(
                title: "Camera Access Required",
                message: "Please enable camera access in Settings to scan ingredients.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            self?.present(alert, animated: true)
        }
    }
    
    private func showCameraUnavailableAlert() {
        DispatchQueue.main.async { [weak self] in
            let alert = UIAlertController(
                title: "Camera Not Available",
                message: "Camera is not available on this device. You can still add ingredients manually or from photo library.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(alert, animated: true)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }
}

// MARK: - AVCapturePhotoCaptureDelegate

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil,
              let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            return
        }
        
        processImage(image)
    }
}

// MARK: - UIImagePickerControllerDelegate

extension CameraViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        if let image = info[.originalImage] as? UIImage {
            processImage(image)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
