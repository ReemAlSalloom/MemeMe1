//
//  ViewController.swift
//  MemeMe
//
//  Created by Reem AlSalloom on 11/18/18.
//  Copyright © 2018 Reem AlSalloom. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate
{
    
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var shareBtn: UIBarButtonItem!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var navigationBar : UINavigationBar!
    
    let imageController = UIImagePickerController()
    
    let memeTextAttributes:[NSAttributedString.Key: Any] = [
        NSAttributedString.Key(rawValue: NSAttributedString.Key.strokeColor.rawValue): UIColor.black,
        NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): UIColor.white,
        NSAttributedString.Key(rawValue: NSAttributedString.Key.font.rawValue): UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedString.Key(rawValue: NSAttributedString.Key.strokeWidth.rawValue): 2.0]
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageController.delegate = self
        topTextField.delegate = self
        bottomTextField.delegate = self
        
        //Issue: text is not aligned
        topTextField.textAlignment = NSTextAlignment.center
        bottomTextField.textAlignment = NSTextAlignment.center
        
        bottomTextField.defaultTextAttributes = memeTextAttributes
        topTextField.defaultTextAttributes = memeTextAttributes
        
        topTextField.text = "TOP TEXT"
        bottomTextField.text = "BOTTOM TEXT"
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Manage camera and share button when application starts
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        shareBtn.isEnabled = imageView.image != nil
        
        subscribeToKeyboardNotification()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        unsubscribeToKeyboardNotification()
    }
    
    
    @IBAction func share(sender: UIButton){
        
        //generate meme
        let memedImage = generateMemedImage()
        
        //create activity controller and pass the MememedImage
        let controller = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        
        //Issue: not sure this works!
        controller.completionWithItemsHandler = {(activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            
            self.save()
//
//            var meme : Meme!{
//                didSet{
//
//                }
//            }
        }
        
        //preset the activity controller 
        present(controller, animated: true, completion: nil)
    }
    
    
    
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        imageController.sourceType = .camera
        present(imageController, animated: true, completion: nil)
        
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            dismiss(animated: true, completion: nil)
        }    }
    
    
    @IBAction func pickAnImage(_ sender: Any) {
        imageController.sourceType = .photoLibrary
        present(imageController, animated: true, completion: nil)
        
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        
        if let selectedImage = info[.originalImage] as? UIImage
        {
            imageView.contentMode = .scaleAspectFit
            imageView.image = selectedImage
        }
        else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        
        
        func imagePickerControllerDidCancel(picker: UIImagePickerController) {
            dismiss(animated: true, completion: nil)
        }
        
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
        
    }
    
    //hide/show bars
    func toggleBars(flag : Bool)
    {
        toolbar.isHidden = flag
        navigationBar.isHidden = flag
        
    }
    
    func generateMemedImage() -> UIImage {
        
        // TODO: Hide toolbar and navbar
        toggleBars(flag : true)
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        
        // TODO: Show toolbar and navbar
        toggleBars(flag : false)
        return memedImage
    }
    
    struct Meme {
        var topText: String!
        var bottomText: String!
        var originalImage:UIImage!
        var memedImage: UIImage!
    }
    
    func save() {
        // Create the meme
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imageView.image!, memedImage: generateMemedImage())
    }
    
    
    func getKeyboardHeight(_ notification: Notification) ->CGFloat
    {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        
        return keyboardSize.cgRectValue.height
    }
    
    @objc func keyboardWillShow(_ notification: Notification)
    {
        view.frame.origin.y -= getKeyboardHeight(notification)
    }
    
    @objc func keyboardWillHide(_ notification: Notification)
    {
        // view.frame.origin.y += getKeyboardHeight(notification)
        view.frame.origin.y = 0
    }
    
    //Issue: Keyboard doesnt show up at all
    func subscribeToKeyboardNotification()
    {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    func unsubscribeToKeyboardNotification()
    {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    

    
    
}

