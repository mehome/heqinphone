/**
 *  Copyright (c) 2013 William George.
 *
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to deal
 *  in the Software without restriction, including without limitation the rights
 *  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *  copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *
 *  The above copyright notice and this permission notice shall be included in
 *  all copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 *  THE SOFTWARE.
 *
 *  @author William George
 *  @package WUNFramework
 *  @category Utils
 *  @date 02/04/2013
 */

#import "WUNImageCapture.h"

static WUNImageCapture *instance = nil;


@interface WUNImageCapture ()

#pragma mark - Private Properties
/** @name Private Properties */

@property(nonatomic, copy) CaptureCompletionHandler captureCompletionHandler;

@end


@implementation WUNImageCapture {
    //StatusBar Log
    UIStatusBarStyle statusBarStyle;
    BOOL statusBarHidden;
    __weak UIViewController *viewController;
    ImageCompletionHandler imageHandler;
    UIImagePickerController *imagePicker;
}


#pragma mark - Public Methods
/** @name Public Methods */

/**
 *  Initializes instance with given UIViewController
 *
 *  @param vc UIViewController
 *
 *  @return WUNImageCapture instance
 */
- (id)initWithViewController:(UIViewController *)vc
{
  if ((self = [super init])) {
    viewController = vc;
  }
  
  return self;
}

/**
 *  Initializes instance with given UIViewController and completion block
 *
 *  The completion block is called when image selection completes or is cancelled, returning the selected image or any errors.
 *
 *  @param vc      UIViewController
 *  @param handler ImageCompletionHandler
 *
 *  @return WUNImageCapture instance
 */
- (id)initWithViewController:(UIViewController *)vc
      imageCompletionHandler:(ImageCompletionHandler)handler
{
  if ((self = [self initWithViewController:vc])) {
    imageHandler = handler;
  }
  
  return self;
}

/**
 *  Initializes instance with given UIViewController and completion block
 *
 *  The completion block is called when image selection completes or is cancelled, returning image capture and editing information and any errors.
 *
 *  Use this method when detail about the image capture and editing information is required.
 *
 *  @param vc              UIViewController
 *  @param completionBlock CaptureCompletionHandler
 *
 *  @return WUNImageCapture instance
 */
- (id)initWithViewController:(UIViewController *)vc
                  completion:(CaptureCompletionHandler)completionBlock
{
  if ((self = [self initWithViewController:vc])) {
    _captureCompletionHandler = completionBlock;
  }
  
  return self;
}

/**
 *  Capture Image In View With Completion Block
 *
 *  Use this function to interact with the class. Set a callback to fire when the user selects an image.
 *
 *  Probably best not to use this as it needlessly creates a singleton affectively leaking an instance of this object.
 *
 *  @param viewController  UIViewController
 *  @param completionBlock CaptureCompletionHandler
 */
+ (void)captureImageInView:(UIViewController *)vc
                completion:(CaptureCompletionHandler)completionBlock
{
    if (!instance)
        instance = [[self alloc] initWithViewController:vc];
    else
        instance->viewController = vc;
  
    instance.captureCompletionHandler = completionBlock;
    return [instance captureImage];
}

#pragma mark - Internal Methods
/** @name Internal Methods */

/**
 *  Capture Image In View
 *
 *  This method displays an image picker action sheet
 *
 */
- (void)captureImage
{
    BOOL cameraAvailible = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    BOOL libraryAvailible = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary];
    
    if(cameraAvailible || libraryAvailible)
    {
        UIActionSheet *photoSourcePicker = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles: nil];
        
        //Display Camera Button If Device Supports It
        if(cameraAvailible)
        {
            [photoSourcePicker addButtonWithTitle:@"拍照"];
        }
        //Display library button idf the device supports it
        if(libraryAvailible)
        {
            [photoSourcePicker addButtonWithTitle:@"从相册中选择"];
        }
        
        //Add Cancel Button And Set The Style
        [photoSourcePicker addButtonWithTitle:@"取消"];
        photoSourcePicker.cancelButtonIndex = photoSourcePicker.numberOfButtons-1;
        
        //Add Action Sheet To View
        //TODO: iOS 7 Check
        [photoSourcePicker showInView:[UIApplication sharedApplication].keyWindow];
    }
}


#pragma mark - Action Sheet Delegate
/** @name Action Sheet Delegate */

/**
 *  Action sheet clicked delegate callback
 *
 *  Performs the showWithCamera or showWithLibrary if the hardware supports it.
 *
 *  @param modalView   UIActionSheet
 *  @param buttonIndex NSInteger
 */
- (void)actionSheet:(UIActionSheet *)modalView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    BOOL cameraAvailible = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    BOOL libraryAvailible = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary];
    
    //ImagePicker doesn't respect users choice of status bar style
    statusBarHidden = [UIApplication sharedApplication].statusBarHidden;
    statusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    
    //Camera Confirm
    if(cameraAvailible && buttonIndex == 0)
    {
        [self performSelector:@selector(showWithCamera) withObject:nil afterDelay:0.3];
    }
    else if(((!cameraAvailible && buttonIndex == 0) || (cameraAvailible && buttonIndex ==1)) && libraryAvailible)
    {
         [self performSelector:@selector(showWithLibrary) withObject:nil afterDelay:0.3];
    }
    else if (buttonIndex == [modalView numberOfButtons] - 1)
    {
        NSError *userCancelled = [[NSError alloc] initWithDomain:@"com.wunelli.imageCaptureError" code:WUNImageUserCancelled userInfo:@{ NSLocalizedDescriptionKey : @"User cancelled photo taking" }];
        
		if(_captureCompletionHandler)
        {
			self.captureCompletionHandler (nil, userCancelled);
		}
		if(imageHandler)
        {
			imageHandler(nil, userCancelled);
		}
    }
}

- (void)showWithCamera
{
    imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera;
    imagePicker.delegate = self;
    imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
    imagePicker.allowsEditing = NO;
    imagePicker.view.tintColor = [UIColor blackColor];
    imagePicker.modalPresentationStyle = UIModalPresentationFullScreen;
    [viewController presentViewController:imagePicker animated:YES completion:nil];
    
}

- (void)showWithLibrary
{
    imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.delegate = self;
    imagePicker.allowsEditing = NO;
    imagePicker.view.tintColor = [UIColor blackColor];
    imagePicker.modalPresentationStyle = UIModalPresentationFullScreen;
    [viewController presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - Image Picker Delegate
/** @name Image Picker Delegate */

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    //Close Picker
    [picker dismissViewControllerAnimated:YES completion:nil];
    [[UIApplication sharedApplication] setStatusBarStyle:statusBarStyle animated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //Close Picker
    [picker dismissViewControllerAnimated:YES completion:nil];
    [[UIApplication sharedApplication] setStatusBarStyle:statusBarStyle animated:YES];
    
    //Fire Completion Block
    dispatch_async(dispatch_get_main_queue(), ^{
      if (_captureCompletionHandler)
      {
          _captureCompletionHandler(info, nil);
      }
      else if (imageHandler)
      {
          UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
          imageHandler (image, nil);
      }
    });
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([navigationController isKindOfClass:[UIImagePickerController class]] && ((UIImagePickerController *)navigationController).sourceType == UIImagePickerControllerSourceTypePhotoLibrary)
    {
        [[UIApplication sharedApplication] setStatusBarHidden:statusBarHidden];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
    }
}


@end
