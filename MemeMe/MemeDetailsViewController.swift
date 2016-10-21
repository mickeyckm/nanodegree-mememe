//
//  MemeDetailsViewController.swift
//  MemeMe
//
//  Created by Mickey Cheong on 21/10/16.
//  Copyright © 2016 CHEO.NG. All rights reserved.
//

import UIKit

class MemeDetailsViewController: UIViewController {

    @IBOutlet weak var imageDisplay: UIImageView!
    
    var meme:Meme?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        imageDisplay.image = meme?.memedImage
    }

}
