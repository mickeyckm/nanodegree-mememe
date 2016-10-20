//
//  ViewController.swift
//  MemeMe
//
//  Created by Mickey Cheong on 20/10/16.
//  Copyright © 2016 CHEO.NG. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var cameraBarButton: UIBarButtonItem!
    @IBOutlet weak var albumBarButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!

    @IBOutlet weak var imageDisplay: UIImageView!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    
    struct Meme {
        var topText: String?
        var bottomText: String?
        var image: UIImage?
        var memedImage: UIImage?
    }
    
    var meme: Meme!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            self.cameraBarButton.isEnabled = false
        }
        
        if imageDisplay.image == nil {
            self.shareButton.isEnabled = false
            self.cancelButton.isEnabled = false
        }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.center
        
        let memeTextAttributes = [
            NSStrokeColorAttributeName : UIColor.black,
            NSForegroundColorAttributeName : UIColor.white,
            NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName : -5.0,
            NSParagraphStyleAttributeName: paragraphStyle
        ] as [String : Any]
        
        self.topTextField.delegate = self
        self.topTextField.defaultTextAttributes = memeTextAttributes
        self.bottomTextField.delegate = self
        self.bottomTextField.defaultTextAttributes = memeTextAttributes
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillHide, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func captureImage(_ sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            self.present(imagePicker, animated: true, completion: nil)
        }
        else {
            self.cameraBarButton.isEnabled = false
        }
    }
    
    @IBAction func pickImage(_ sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func shareMeme(_ sender: AnyObject) {
        self.meme = Meme(topText: self.topTextField.text, bottomText: self.bottomTextField.text, image: self.imageDisplay.image, memedImage: self.generateMemedImage())
        let image = self.meme.memedImage
        let shareItems = [ image! ]
        let shareActivity = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
        self.present(shareActivity, animated: true, completion: nil)
    }
    
    @IBAction func cancelImage(_ sender: AnyObject) {
        self.shareButton.isEnabled = false
        self.cancelButton.isEnabled = false
        self.imageDisplay.image = nil
        self.topTextField.text = "Top"
        self.bottomTextField.text = "Bottom"
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        imageDisplay.image = chosenImage
        self.shareButton.isEnabled = true
        self.cancelButton.isEnabled = true
        dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func keyboardWillShow(notification: Notification) {
        self.view.frame.origin.y -= getKeyboardHeight(notification: notification)
    }
    
    func keyboardWillHide(notification: Notification) {
        self.view.frame.origin.y += getKeyboardHeight(notification: notification)
    }
    
    func getKeyboardHeight(notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        if self.bottomTextField.isFirstResponder {
            return keyboardSize.cgRectValue.height
        }
        else {
            return 0
        }
        
    }
    
    
    func generateMemedImage() -> UIImage
    {
        // Hide toolbar and navbar
        self.navigationController?.navigationBar.isHidden = true
        self.bottomToolbar.isHidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        self.view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // Show toolbar and navbar
        self.navigationController?.navigationBar.isHidden = false
        self.bottomToolbar.isHidden = false
        
        return memedImage
    }
}

