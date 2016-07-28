//
//  RDRCellsSelectView.h
//  linphone
//
//  Created by baidu on 15/12/18.
//
//

#import <UIKit/UIKit.h>

typedef void(^confirmBlock)(NSArray *selectedDatas);
typedef void(^cancelBlock)();

@interface RDRCellsSelectView : UIView

+ (void)showSelectViewWith:(NSString *)title withArr:(NSArray *)datas hasSelectedArr:(NSArray *)selectedArr withConfirmBlock:(confirmBlock)doneBlock withCancelBlcok:(cancelBlock)cancelBlock singleChoose:(BOOL)singleChoose;

@end
