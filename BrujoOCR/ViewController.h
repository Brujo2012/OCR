//
//  ViewController.h
//  BrujoOCR
//
//  Created by Mario Alejandro Ramos on 24-04-15.
//  Copyright (c) 2015 Mario Alejandro Ramos. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "GPUImage.h"
#import <TesseractOCR/TesseractOCR.h>

@interface ViewController : UIViewController<G8TesseractDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (strong,nonatomic) G8Tesseract *tesseract;
@property (weak, nonatomic) IBOutlet UITextView *texto;

@end

