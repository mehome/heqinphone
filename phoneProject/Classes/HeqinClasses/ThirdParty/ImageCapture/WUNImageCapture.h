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
 *  @package WunFramework
 *  @category Utils
 *  @date 02/04/2013
 */

#import <Foundation/Foundation.h>

#pragma mark - Completion handler definitions
/** @name Completion handler definitions */

/**
 *  Image capture completion definition returning image capture and editing information, or any errors.
 *
 *  The image captured is returned in the imageDetails parameter.
 *
 *  @param imageDetails NSDictionary image capture and editing information
 *  @param error        NSError
 */
typedef void (^CaptureCompletionHandler)(NSDictionary *imageDetails, NSError *error);

/**
 *  Image capture or selection completion definition returning the selected image, or any errors.
 *
 *  @param img UIImage selected or captured
 *  @param err NSError
 */
typedef void (^ImageCompletionHandler)(UIImage *img, NSError *err);


/**
 *  Provides image capture from camera or from photo library functionality.
 */
@interface WUNImageCapture : NSObject <UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

#pragma mark - Class Methods
/** @name Class Methods */

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
+ (void)captureImageInView:(UIViewController *)viewController
               completion:(CaptureCompletionHandler)completionBlock;

#pragma mark - Initializers
/** @name Initializers */

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
      imageCompletionHandler:(ImageCompletionHandler)handler;

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
                  completion:(CaptureCompletionHandler)completionBlock;

#pragma mark - Public Methods
/** @name Public Methods */

/**
 *  Capture Image In View
 *
 *  This method displays an image picker action sheet
 *
 */
- (void)captureImage;

#pragma mark - Constants
/** @name Constants */

/**
 *  Types of image errors
 */
typedef NS_ENUM(NSUInteger, WUNImageErrors){
    /**
     *  The user cancelled the image capture activity
     */
    WUNImageUserCancelled = 1
};

@end
