//
//  ViewController.swift
//  Project13_CoreImage
//
//  Created by iMac on 02.03.2021.
//

import UIKit
import CoreImage

class ViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var intensitySlider: UISlider!
    
    var context: CIContext!
    var currentFilter: CIFilter!
    var currentImage: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Core Image Filter" //Yet Another CoreImage Filter Photo
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(importPicture))
        
        context = CIContext()
        currentFilter = CIFilter(name: "CISepiaTone")
    }
    
    //MARK: Actions: -----------------------------------------------------------------------
    @IBAction func changeFilter(_ sender: Any) {
        let ac = UIAlertController(title: "Choose filter", message: nil, preferredStyle: .actionSheet)
        
            ac.addAction(UIAlertAction(title: "CIBumpDistortion", style: .default, handler: setFilter))
            ac.addAction(UIAlertAction(title: "CIGaussianBlur", style: .default, handler: setFilter))
            ac.addAction(UIAlertAction(title: "CIPixellate", style: .default, handler: setFilter))
            ac.addAction(UIAlertAction(title: "CISepiaTone", style: .default, handler: setFilter))
            ac.addAction(UIAlertAction(title: "CITwirlDistortion", style: .default, handler: setFilter))
            ac.addAction(UIAlertAction(title: "CIUnsharpMask", style: .default, handler: setFilter))
            ac.addAction(UIAlertAction(title: "CIVignette", style: .default, handler: setFilter))
            ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
            present(ac, animated: true)
    }
    
    @IBAction func save(_ sender: Any) {
        guard let image = imageView.image else { return }
        
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @IBAction func intensityChanged(_ sender: Any) {
        applyProcessing()
    }
    
    //MARK: Functions: -----------------------------------------------------------------------
    @objc func importPicture() {
        let picker = UIImagePickerController()
//        //Если хотим использовать камеру - только для реальных устройств:
//        if UIImagePickerController.isSourceTypeAvailable(.camera) {
//            picker.sourceType = .camera
//        }
        
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func applyProcessing() {
        let inputKeys = currentFilter.inputKeys
        
        if inputKeys.contains(kCIInputIntensityKey) { currentFilter.setValue(intensitySlider.value, forKey: kCIInputIntensityKey) }
        
        if inputKeys.contains(kCIInputRadiusKey) { currentFilter.setValue(intensitySlider.value * 200, forKey: kCIInputRadiusKey) }
        
        if inputKeys.contains(kCIInputScaleKey) { currentFilter.setValue(intensitySlider.value * 10, forKey: kCIInputScaleKey) }
        
        if inputKeys.contains(kCIInputCenterKey) { currentFilter.setValue(CIVector(x: currentImage.size.width / 2, y: currentImage.size.height / 2), forKey: kCIInputCenterKey) }
        
        if let cgimg = context.createCGImage(currentFilter.outputImage!, from: currentFilter.outputImage!.extent) {
            let processedImage = UIImage(cgImage: cgimg)
            imageView.image = processedImage
        }
        
    }
    
    func setFilter(action: UIAlertAction) {
        guard currentImage != nil else { return }
        
        guard let actionTitle = action.title else { return }
        
        currentFilter = CIFilter(name: actionTitle)
        
        let beginImage = CIImage(image: currentImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        
        applyProcessing()
        
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        var title = ""
        var message = ""
        
        if let error = error {
            title  = "Save error"
            message = error.localizedDescription
        } else {
            title = "Saved"
            message = "Your altered image has been saved to your photos!"
        }
        
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    //MARK: UIImagePickerControllerDelegate ------------------------------------------------
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[.editedImage] as? UIImage else { return }
        dismiss(animated: true)
        currentImage = image
        
        let beginImage = CIImage(image: currentImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        
        applyProcessing()
    }
}

