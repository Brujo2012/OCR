//
//  ViewController.m
//  BrujoOCR
//
//  Created by Mario Alejandro Ramos on 24-04-15.
//  Copyright (c) 2015 Mario Alejandro Ramos. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *recongnizeButton;
@property (weak, nonatomic) IBOutlet UILabel *progressText;
@property (weak, nonatomic) IBOutlet UIButton *improvePictureButton;

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    _recongnizeButton.hidden=true;
    _progressText.hidden=true;
    _improvePictureButton.hidden=true;

    }


- (void)progressImageRecognitionForTesseract:(G8Tesseract *)tesseract {
    NSLog(@"progress: %lu", (unsigned long)tesseract.progress);
    //NSString *progress=[NSString stringWithFormat:@"Análisis Completo"] ;

    //_progressText.text=progress;
   
}


- (BOOL)shouldCancelImageRecognitionForTesseract:(G8Tesseract *)tesseract {
    return NO;  // return YES, if you need to interrupt tesseract before it finishes
}


- (IBAction)improvePicturePressed:(id)sender {
    
    UIImage *imageReadyForOCR = [self optimizeImageForOCR:_imageView.image];
    _imageView.image=imageReadyForOCR;
    
    _improvePictureButton.hidden=true;
    _recongnizeButton.hidden=false;
    
}

- (IBAction)cameraButtonPressed:(id)sender {
     _progressText.hidden=true;
    
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeCamera])
    {
         NSLog(@"Camara seleccionada");
        UIImagePickerController *imagePicker =
        [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType =
        UIImagePickerControllerSourceTypeCamera;
        imagePicker.allowsEditing = YES;
        [self presentViewController:imagePicker
                           animated:YES completion:nil];
            }
    NSLog(@"No hay camara");
}


- (IBAction)openGalleryButtonPressed:(id)sender {
    
    _progressText.hidden=true;
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];

}

- (UIImage*) preprocessedImageForTesseract:(G8Tesseract *)tesseract sourceImage:(UIImage *)sourceImage{
    return sourceImage;
}

- (IBAction)recognizeImageButtonPressed:(id)sender {
    NSLog(@"Boton reconocer oprimido");
    _recongnizeButton.hidden=true;
    _progressText.hidden=false;
    
    // Languages are used for recognition (e.g. eng, ita, etc.). Tesseract engine
    // will search for the .traineddata language file in the tessdata directory.
    // For example, specifying "eng+ita" will search for "eng.traineddata" and
    // "ita.traineddata". Cube engine will search for "eng.cube.*" files.
    // See https://code.google.com/p/tesseract-ocr/downloads/list.
    
    // Create your G8Tesseract object using the initWithLanguage method:
     _tesseract= [[G8Tesseract alloc] initWithLanguage:@"eng+spa"];
    
    // Optionaly: You could specify engine to recognize with.
    // G8OCREngineModeTesseractOnly by default. It provides more features and faster
    // than Cube engine. See G8Constants.h for more information.
    //_tesseract.engineMode = G8OCREngineModeCubeOnly;
    _tesseract.pageSegmentationMode = G8PageSegmentationModeAutoOSD;
    
    // Set up the delegate to receive Tesseract's callbacks.
    // self should respond to TesseractDelegate and implement a
    // "- (BOOL)shouldCancelImageRecognitionForTesseract:(G8Tesseract *)tesseract"
    // method to receive a callback to decide whether or not to interrupt
    // Tesseract before it finishes a recognition.
    _tesseract.delegate = self;
    
    _tesseract.sourceResolution =400;
    
    // Optional: Limit the character set Tesseract should try to recognize from
    _tesseract.charWhitelist = @"0123456789abcdefghijklmnñopqrstuvwxyzáéíóúABCDEFGHIJKLMNÑOPQRSTUVWXYZ.,:%$";
    
    // This is wrapper for common Tesseract variable kG8ParamTesseditCharWhitelist:
    // [tesseract setVariableValue:@"0123456789" forKey:kG8ParamTesseditCharBlacklist];
    // See G8TesseractParameters.h for a complete list of Tesseract variables
    
    // Optional: Limit the character set Tesseract should not try to recognize from
    //tesseract.charBlacklist = @"OoZzBbSs";
    
    // Specify the image Tesseract should recognize on
    _tesseract.image = _imageView.image;
    
    // Optional: Limit the area of the image Tesseract should recognize on to a rectangle
    //tesseract.rect = CGRectMake(20, 20, 100, 100);
    
    // Optional: Limit recognition time with a few seconds
    _tesseract.maximumRecognitionTime = 30.0;
    
    // Start the recognition
    [_tesseract recognize];
    NSString *textoReconocido =[_tesseract recognizedText];
    // Retrieve the recognized text
    NSLog(@"%@", [_tesseract recognizedText]);
    
    _texto.text=textoReconocido;
    // You could retrieve more information about recognized text with that methods:
    NSArray *characterBoxes = [_tesseract recognizedBlocksByIteratorLevel:G8PageIteratorLevelSymbol];
    NSArray *paragraphs = [_tesseract recognizedBlocksByIteratorLevel:G8PageIteratorLevelParagraph];
    
    NSArray *characterChoices = _tesseract.characterChoices;
    
    UIImage *imageWithBlocks = [_tesseract imageWithBlocks:characterBoxes drawText:YES thresholded:NO];
    
    
}



-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    _recongnizeButton.hidden=true;
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    _imageView.image = chosenImage;
    //_recongnizeButton.hidden=false;
    _improvePictureButton.hidden=false;
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
      [picker dismissViewControllerAnimated:YES completion:NULL];
}

// Tesseract delegate method inside of your class
- (UIImage *)optimizeImageForOCR:(UIImage *)sourceImage {
    /*
    //Image Pre-Optimization for OCR
    CGImageRef imageRef = [sourceImage CGImage];
    CIContext *context = [CIContext contextWithOptions:nil]; // 1
    CIImage *ciImage = [CIImage imageWithCGImage:imageRef]; // 2
    CIFilter *filter = [CIFilter filterWithName:@"CIColorMonochrome" keysAndValues:@"inputImage", ciImage, @"inputColor", [CIColor colorWithRed:1.f green:1.f blue:1.f alpha:1.0f], @"inputIntensity", [NSNumber numberWithFloat:1.f], nil]; // 3
    CIImage *ciResult = [filter valueForKey:kCIOutputImageKey]; // 4
    CGImageRef cgImage = [context createCGImage:ciResult fromRect:[ciResult extent]];
    UIImage *img = [UIImage imageWithCGImage:cgImage];
    */
     
    // Initialize our adaptive threshold filter
    GPUImageAdaptiveThresholdFilter *stillImageFilter = [[GPUImageAdaptiveThresholdFilter alloc] init];
    stillImageFilter.blurRadiusInPixels = 4.0; // adjust this to tweak the blur radius of the filter, defaults to 4.0
    
    // Retrieve the filtered image from the filter
    UIImage *filteredImage = [stillImageFilter imageByFilteringImage:sourceImage];
    
    // Now the filter Thershold
    GPUImageLuminanceThresholdFilter * adaptiveThreshold = [[GPUImageLuminanceThresholdFilter alloc] init];
    [adaptiveThreshold setThreshold:0.3f];
    
    UIImage *finalImage= [adaptiveThreshold imageByFilteringImage:filteredImage];
    
    // Give the filteredImage to Tesseract instead of the original one,
    // allowing us to bypass the internal thresholding step.
    // filteredImage will be sent immediately to the recognition step
    return finalImage;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
