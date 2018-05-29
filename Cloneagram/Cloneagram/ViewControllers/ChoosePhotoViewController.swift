//
//  ChoosePhotoViewController.swift
//  Cloneagram
//
//  Created by Student on 2018. 03. 08..
//  Copyright © 2018. Student. All rights reserved.
//

import UIKit

class ChoosePhotoViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    private struct Constants {
        static let filterNames = [
            "None",
            "Chrome",
            "Fade",
            "Instant",
            "Noir",
            "Process",
            "Tonal",
            "Transfer",
            "Sepia"
        ]
        
        static let filterCodes = [
            "",
            "CIPhotoEffectChrome",
            "CIPhotoEffectFade",
            "CIPhotoEffectInstant",
            "CIPhotoEffectNoir",
            "CIPhotoEffectProcess",
            "CIPhotoEffectTonal",
            "CIPhotoEffectTransfer",
            "CISepiaTone"
        ]
    }
    
    @IBOutlet weak var titleTextView: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var filterPickerView: UIPickerView!
    
    var chooseProfilePicture = false
    private var chosenImage: UIImage?
    private let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if chooseProfilePicture {
            titleTextView.isHidden = true
        }
        
        // Do any additional setup after loading the view.
        filterPickerView.delegate = self
        filterPickerView.dataSource = self
 
        // Initialize image picker
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        
        present(imagePicker, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        guard let data = UIImageJPEGRepresentation(imageView.image!, 1.0) else {
            createAndShowErrorAlert(for: "Could not convert image to JPEG!")
            return
        }
        
        guard data.count < 1 * 1024 * 1024 else {
            createAndShowErrorAlert(for: "Photo size too large!")
            return
        }
        
        if chooseProfilePicture {
            FirebaseManager.shared.uploadProfilePicture(data: data) { (errorMessage) in
                if let errorMessage = errorMessage {
                    self.createAndShowErrorAlert(for: errorMessage)
                    return
                }
                
                self.navigationController!.popViewController(animated: true)
            }
            
        } else {
            FirebaseManager.shared.uploadPhoto(data: data, title: titleTextView.text) { (errorMessage) in
                if let errorMessage = errorMessage {
                    self.createAndShowErrorAlert(for: errorMessage)
                    return
                }
                
                self.navigationController!.popViewController(animated: true)
            }
        }
    }
    
    // MARK: - UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Constants.filterNames[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row == 0 {
            imageView.image = chosenImage
        } else {
            let queue = DispatchQueue(label: "Cloneagram")
            queue.async {
                // Apply filter to the image
                let context = CIContext(options: nil)
                let coreImage = CIImage(image: self.chosenImage!)
                let filter = CIFilter(name: Constants.filterCodes[row])
                filter!.setDefaults()
                filter!.setValue(coreImage, forKey: kCIInputImageKey)
                
                let filteredImageData = filter!.value(forKey: kCIOutputImageKey) as! CIImage
                let filteredImageRef = context.createCGImage(filteredImageData, from: filteredImageData.extent)
                let image = UIImage(cgImage: filteredImageRef!)
                
                DispatchQueue.main.async {
                    self.imageView.image = image
                }
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 32.0
    }
    
    // MARK: - UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Constants.filterNames.count
    }
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            // Resize image
            let newWidth = imageView.bounds.size.width
            let scale = newWidth / pickedImage.size.width
            let newHeight = pickedImage.size.height * scale
            UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
            pickedImage.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            chosenImage = newImage
            imageView.image = newImage
        }
        
        // Dismiss image picker
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss image picker
        dismiss(animated: true, completion: nil)
        // Dismiss ChoosePhotoViewController
        navigationController?.popViewController(animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
