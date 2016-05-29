//
//  Configmanager.h
//  ArtCircle
//
//  Created by Yoever on 14-3-25.
//  Copyright (c) 2014年 Yoever. All rights reserved.
//
#import "Resource_Size.h"
#import "Resource_Color.h"
#import "Resource_Enum.h"

#define APPLICATIONDelegate ((GAAppDelegate *)[UIApplication sharedApplication].delegate)

#pragma mark- -----颜色相关-----
//概艺风格颜色
#define LOGO_COLOR        COLOR(0,174,202)
#define LOGO_COLOR_2        GetColorFromCSSHex(@"#6d9ba7")
#define NV_COLOR GetColorFromCSSHex(@"#F971AC")
//概艺黑色
#define GAIYI_BLACK       GetColorFromCSSHex(@"#333333")
//概艺灰色
#define GAIYI_GRAY        GetColorFromCSSHex(@"#999999")
//概艺绿色(用于显示“全职”，“免费”等底色)
#define GAIYI_GREEN       GetColorFromCSSHex(@"#6ad96f")
//概艺cell的border灰色
#define GAIYI_BORDER_GRAY       GetColorFromCSSHex(@"#c8c7cc")
//概艺按钮蓝色(用于显示概艺网字体按钮颜色)
#define GAIYI_BUTTON_BLUE COLOR(99,157,169)
//页面背景色
#define GAIYI_VC_BG GetColorFromCSSHex(@"#faf9f5")
//评论姓名颜色
#define GAIYI_COMMENT_TITLE_COLOR GetColorFromCSSHex(@"#6D9BA7")

#define FIVESTART_LEFTCOLOR GetColorFromCSSHex(@"#ff9f2e")
#define FIVESTART_RIGHTCOLOR  GetColorFromCSSHex(@"#d2d2d2")

#pragma mark - -----页面设置相关-----

//---艺术人---//
//艺术人姓名字体
#define ArtistNameFont [UIFont boldSystemFontOfSize:15]
//艺术人身份字体
#define ArtistDegreeFont [UIFont systemFontOfSize:12]
//艺术人发送时间字体
#define ArtistSendInfoFont [UIFont systemFontOfSize:10]
//艺术人生活数量字体
#define ArtistLifesFont [UIFont systemFontOfSize:14]
//艺术人头像宽度
#define ArtistIconWidth         75.f
//艺术人实名认证图片
#define                         ArtistConfirmImage
//艺术人加V图片
#define                         ArtistVImage
//艺术人Cell高度
#define ArtistCellHeight        95.f
//艺术人圆角弧度
#define ArtistImageCornerRadius 14.f
/**********生活主页宏定义************/
//发表信息的人名字高度
#define NAME_HEIGHT         20
//头像宽度
#define HEADICON_WIDTH      45
//生活内容文字最多行数
#define LINEBREAK_NUMBER    6
//内容文字最大宽度
#define CONTENT_WIDTH       (SCREEN_WIDTH-HEADICON_WIDTH-20-10)
//内容文字字号
#define TEXT_FONT_SIZE      14
//显示时间的label高度
#define TIME_LABEL_HEIGHT   20
//点赞评论列表字号
#define LIST_FONT_SIZE      13
//点赞评论列表的内容最大宽度
#define LIST_MAX_WIDTH      (CONTENT_WIDTH-16)
//评论列表的最低高度
#define LIST_MIN_CELLHEIGHT 25
//图片宽高
#define LIFE_IMAGE_WIDTH    75
//图片之间的间隙
#define LIFE_IMAGE_SPACE    5

/**********生活主页分割线************/
/******* BEGIN 概视频相关 BEGIN **********/
//视频预览图高度
#define VIDEO_PREVIEW_HEIGHT 169.f
//视频预览图宽度
#define VIDEO_PREVIEW_WIDTH 300.f
//视频每条内容之间的空白间隔
#define VIDEO_CELL_SPACE_HEIGHT 10
//视频title字号
#define VIDEO_TITLE_FONT_SIZE 18
//视频描述string字号
#define VIDEO_STRING_FONT_SIZE 13

/******* END 概视频 END ************/

BOOL GA_Video_Rotate;
BOOL GA_Video_Locked;

BOOL Video_FullScreen_Play;

/**********登陆模块************/
/** 宏定义 **/
//登陆按钮颜色
#define LOGIN_BUTTON_COLOR GetColorFromCSSHex(@"#FF4040")
//注册按钮颜色
#define REGI_BUTTON_COLOR GetColorFromCSSHex(@"#00AECA")
//弹窗背景颜色
#define POPView_BACKGROUNDCOLOR GetColorFromCSSHex(@"#EDEDED")
//取消按钮颜色
#define CANCEL_BACKGROUNDCOLOR GetColorFromCSSHex(@"#999999")
//登陆按钮边框颜色
#define LOGIN_BORDER_COLOR GetColorFromCSSHex(@"#C8C7CC")
//登陆按钮字体颜色
#define LOGIN_FONT_COLOR GetColorFromCSSHex(@"#666666")
//
#define LOGIN_BUTTON_SIZE [UIFont boldSystemFontOfSize:16]
//登陆按钮字体大小
#define LOGIN_BUTTON2_SIZE [UIFont boldSystemFontOfSize:16]
//第三方登陆按钮字体大小
#define LOGIN_BUTTON3_SIZE [UIFont boldSystemFontOfSize:15]
#define DOC_TITLE_ORINY 10
//字体颜色
#define LOGIN_GRAY GetColorFromCSSHex(@"#CCCCCC")

/******* END 登陆模块 END ************/

/*******Content表示图模块************/

#define CELL_HEAD_SPACE 15.f
#define CELL_SPACE 8.f
#define CELL_HEAD_WIDTH 40.f
#define CELL_TITLE_HEIGHT 16.f
#define CELL_GENDER_HEIGHT 12.f
#define CELL_CONTENT_FONT_SIZE 15.f
#define CELL_CONTENT_MAX_WIDTH (SCREEN_WIDTH-10-40-10-20)
#define PREVIEWER_MAX_WIDTH 233.5
#define PREVIEWER_MAX_HEIGHT 311.f
#define PREVIEWER_MIN_HEIGHT 60.f
#define CELL_ADDTIME_HEIGHT 20.f
#define CELL_ADDTIME_FONTSIZE 13.f

/**********设置模块************/

#import "GAColorManager.h"
#import "GAImageManager.h"

//----资讯模块-----------//
//cell间距
#define NewsCellPadding         10.f
//cell高度
#define NewsCellHeight          307.f
//图片高度
#define NewsCellImageHeight     229.f
//标题左右两遍间距
#define NewsCellTitleHorPadding 15.f
//上下间距
#define NewsCellTitleVerPadding 10.f
//标题高度
#define NewsCellTitleHeight     17
//标题字体
#define NewsCellTitleFont [UIFont systemFontOfSize:16]
//日期字体
#define NewsCellDateFont [UIFont systemFontOfSize:14]

//------资讯详情页-------///
//标题字体
#define NewsDetailTitleFont [UIFont boldSystemFontOfSize:19]
//时间字体
#define NewsDetailDateFont [UIFont systemFontOfSize:14]
//button字体大小
#define NewsDetailButtonFont [UIFont systemFontOfSize:14]
//文章字体
#define NewsDetailArticleFont [UIFont systemFontOfSize:14]
//距离顶部
#define NewsDetailTitleTopPadding       18.f
//时间label高度
#define NewsDetailDateHeight            15
//时间label宽度
#define NewsDetailDateWidth             76
//时间与button间距
#define NewsDetailTitleAndButtonPadding 5.f
//时间与标题顶部距离以及赞列表的距离
#define NewsDetailDateVerPadding        10.f
//title两次边距
#define NewsDetailTitleHorPadding       15.f
//button赞间距
#define NewsDetailButtonAndAssitPadding 10.f

//活动详情页
//活动顶部左右间距
#define ActivityTopHorPadding           10.f
//时间与封面左边间距
#define ActivityTimeAndImageLeftPadding 10.f
//时间地点间距
#define ActivityTimeAndAddrVerPadding   10.f

//-----设置模块宏定义-----//
//图标

/***********评论模块宏定义************/
//头像宽度
#define COMMENT_ICON_WIDTH   45
//用户名高度
#define COMMENT_NAME_HEIGHT  20
//用户名字号
#define COMMENT_NAME_SIZE    16
//内容文字最大宽度
#define COMMENT_WIDTH        (SCREEN_WIDTH-HEADICON_WIDTH-20-18)
//内容文字字号
#define COMMENT_FONT_SIZE    13
//发送时间的label高度
#define COMMENT_LABEL_HEIGHT 20
//发送时间的字号
#define COMMENT_TIME_SIZE    12


//生活内容文字最多行数
#define COMMENT_LINEBREAK_NUMBER 6

//点赞评论列表字号
#define COMMENT_FONT_SIZE      13
//点赞评论列表的内容最大宽度
#define COMMENT_MAX_WIDTH      (CONTENT_WIDTH-16)
//评论列表的最低高度
#define COMMENT_MIN_CELLHEIGHT 25
//图片宽高
#define COMMENT_IMAGE_WIDTH    75
//图片之间的间隙
#define COMMENT_IMAGE_SPACE    5
/**********评论模块分割线************/


/*****常用粗宏定义******/
//alert
#define actionSheet(title,destruct,other) [[UIActionSheet alloc]initWithTitle:title delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:destruct otherButtonTitles:other, nil]
//拍照alert
#define photoAction(title) actionSheet(title,@"拍照",@"从相册选择")


/**********设置模块分割线************/
inline static float getWidthFromForLoopAllCharactorsWithString(NSString* string,UIFont *font,CGFloat maxWidth){
    float width = 0;
    for (int index = 0; index < string.length; index ++) {
        NSString *str = [string substringWithRange:NSMakeRange(index,1)];
        CGSize size = sizeWithFont(str,font);
        width += size.width;
    }
    width = width>maxWidth ? maxWidth : width;
    return width;
}

//生活主页 获取图片所占用的高度
inline static float getImagesHeightFromImageArray(NSArray *imageArray){
    if ([imageArray count]<1) {
        return 0;
    }
    int imageCount = (int)[imageArray count];
    int lines = (imageCount-1)/3;
    float height = (lines+1) *(LIFE_IMAGE_WIDTH+LIFE_IMAGE_SPACE);
    return height;
}
//生活主页  文字
static float getLifeCellContentTextHeightFromString(NSString *string){
    float height = 0;
    UIFont *font = [UIFont systemFontOfSize:TEXT_FONT_SIZE];
    float tempWidth = 0;
    int lineNumber = 1;
    for (int index = 0; index<[string length]; index++) {
        NSString *charactor = [string substringWithRange:NSMakeRange(index, 1)];
        CGSize size = sizeWithFont(charactor,font);
        tempWidth += size.width;
        if ([charactor isEqualToString:@"\n"]&&tempWidth<LIST_MAX_WIDTH) {
            tempWidth = 0;
            lineNumber++;
        }
        if (tempWidth>CONTENT_WIDTH) {
            lineNumber ++;
            tempWidth = size.width;
        }
    }
    height = sizeWithFont(string,font ).height * lineNumber;
    height = (height>20)?height:20;//高度最低需要20像素
//    NSLog(@"content height：%f",height);
    return height;
}
//评论列表(单个cell的点赞或评论)   每条cell高度计算
static float getCommentListCellHeightByString(NSString *string)
{
    float height = 0;
    UIFont *font = [UIFont systemFontOfSize:LIST_FONT_SIZE];
    float tempWidth = 0;
    int lineNumber = 1;
    for (int index = 0; index<[string length]; index++) {
        NSString *charactor = [string substringWithRange:NSMakeRange(index, 1)];
        CGSize size = sizeWithFont(charactor,font);
        tempWidth += size.width;
        if ([charactor isEqualToString:@"\n"]&&tempWidth<CONTENT_WIDTH) {
            tempWidth = 0;
            lineNumber++;
        }
        if (tempWidth>CONTENT_WIDTH) {
            lineNumber ++;
            tempWidth = size.width;
        }
    }
    height = sizeWithFont(string,font).height * lineNumber;
    height = (height>LIST_MIN_CELLHEIGHT)?height:LIST_MIN_CELLHEIGHT;//高度最低需要的像素
    
    return height;
}
//评论+赞   列表高度
inline static float getCommentListViewHeightBy(NSDictionary*dictionary)
{
    float listHeight = 0;
    
    if ([[dictionary objectForKey:@"admirelist"]count]>1) {
        listHeight = LIST_MIN_CELLHEIGHT;
    }
    if ([[dictionary objectForKey:@"commentlist"]count]>1) {
        NSArray *comment = [dictionary objectForKey:@"commentlist"];
        for (int lll = 0; lll<[comment count]; lll++) {
            NSString *list = [[comment objectAtIndex:lll]objectForKey:@"content"];
            NSString *listName = [[comment objectAtIndex:lll]objectForKey:@"userName"];
            NSString *result = [NSString stringWithFormat:@"%@: %@",listName,list];
            float height = getCommentListCellHeightByString(result);
            listHeight += height;
        }
    }
    return listHeight;
}
//生活每条消息（头像+名字+内容+时间）高度
inline static float getLifeCellEachContentHeightFromData(NSDictionary *dataBase)
{
    float distance = 10;//cell顶部与名字的间隔
    float contentHeight = 0;//生活文本内容高度
    NSString *text = [[dataBase objectForKey:@"content"]objectForKey:@"text"];
    contentHeight = getLifeCellContentTextHeightFromString(text);
    
    float imageContentHeight = 0;
    float heightUnderContent = 8;//时间与内容的间隔高度
    NSArray *images = [[dataBase objectForKey:@"content"]objectForKey:@"image"];
    if ([images count]>=1) {
        heightUnderContent = 0;
        imageContentHeight = 10;
        imageContentHeight += getImagesHeightFromImageArray(images);
    }
    float heightUnderName = 8;//名字与内容的间隔高度
    float heightUnderTimeLabel = 10;//列表与时间的间隔高度
    return (distance + NAME_HEIGHT + heightUnderName + contentHeight + heightUnderContent +imageContentHeight + TIME_LABEL_HEIGHT + heightUnderTimeLabel);
}

//生活首页   每条cell的总高度
inline static float getLifeCellHightFromDataBase(NSDictionary *dataBase){
    float totalHeight = 0;
    float headContentHeight = getLifeCellEachContentHeightFromData(dataBase);
    float listHeight = 0;//点赞或者评论的列表高度
    listHeight = getCommentListViewHeightBy(dataBase);
    float grayBackHeight = 8+8;//列表灰色背景8+table+8//上下边多出8像素
    float heightUnderListView = 10;//列表与cell底部边界的间隔高度
    if ([[dataBase objectForKey:@"commentlist"]count]<1 && [[dataBase objectForKey:@"admirelist"]count]<1) {
        heightUnderListView = 0;
        grayBackHeight = 0;
    }
    totalHeight = headContentHeight + listHeight + heightUnderListView+grayBackHeight;
//    NSLog(@"---------------total height：%f",totalHeight);
    return totalHeight;
}

//设置行距
inline static NSAttributedString*  setLineHeight(NSString* string,CGFloat lineHeight)
{
    NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc]initWithString:string];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:lineHeight];//调整行间距
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [string length])];
    return attributedString;
}
//概视频文本描述内容高度
inline static float getVideoCellHeightWithDescriptionString(NSString *descriptions)
{
    float height = 0;
    
    UIFont *font = [UIFont systemFontOfSize:VIDEO_STRING_FONT_SIZE];
    float maxWidth = VIDEO_PREVIEW_WIDTH-20-20;
    float tempWidth = 0;
    int lineNumber = 1;
    for (int i = 0; i<descriptions.length; i++) {
        NSString *str = [descriptions substringWithRange:NSMakeRange(i, 1)];
        CGSize size = sizeWithFont(str,font);
        tempWidth += size.width;
        if ([str isEqualToString:@"\n"]&&tempWidth<maxWidth) {
            tempWidth = 0;
            lineNumber++;
        }
        if (tempWidth>maxWidth) {
            lineNumber ++;
            tempWidth = size.width;
        }
    }
    height = sizeWithFont(descriptions,font).height * lineNumber;
    height = height>20 ? height : 20;
    
    height = VIDEO_PREVIEW_HEIGHT + 10 + 20 + 10 + height +10+ 20 +10+VIDEO_CELL_SPACE_HEIGHT;
    
    return height;
}
inline static CGSize getPreviewerWorkFrontCoverSizeFromImages(NSArray *imagesArray)
{
    CGSize size = CGSizeZero;
    NSString *frontCover = nil;
    for (int num = 0; num < imagesArray.count; num ++) {
        frontCover = [[imagesArray objectAtIndex:num]objectForKey:@"front_cover"];
        if ([frontCover isEqualToString:@"1"]) {
            float imageWidth = [[[imagesArray objectAtIndex:num]objectForKey:@"width"] floatValue];
            float imageHeight = [[[imagesArray objectAtIndex:num]objectForKey:@"height"] floatValue];
            
            float myRatio = PREVIEWER_MAX_WIDTH/PREVIEWER_MAX_HEIGHT;
            float imageRatio = imageWidth/imageHeight;
            
            if (imageRatio<=myRatio) {
                size.width = PREVIEWER_MAX_HEIGHT * imageWidth/imageHeight;
                size.height = PREVIEWER_MAX_HEIGHT;
            }else{
                float height = PREVIEWER_MAX_WIDTH * imageHeight/imageWidth;
                if (height>PREVIEWER_MIN_HEIGHT) {
                    size.width = PREVIEWER_MAX_WIDTH;
                    size.height = height;
                }else{
                    size.width = PREVIEWER_MAX_WIDTH;
                    size.height = PREVIEWER_MIN_HEIGHT;
                }
            }
        }
    }
    return size;
}
//一张图片显示控件高度计算 // previewer
inline static CGSize getPreviewerSizeFromArray(NSArray *arrays)
{
    CGFloat maxWidth = SCREEN_WIDTH - 120;
    CGSize size = CGSizeZero;
    float imageWidth = [[[arrays objectAtIndex:0]objectForKey:@"width"] floatValue];
    float imageHeight = [[[arrays objectAtIndex:0]objectForKey:@"height"] floatValue];

    float myRatio = maxWidth/PREVIEWER_MAX_HEIGHT;
    float imageRatio = imageWidth/imageHeight;

    if (imageRatio>myRatio)//更矮一点
    {
        if (imageWidth>maxWidth) {
            size.width = maxWidth;
            size.height = maxWidth / imageRatio;
        }else
        {
            size.width = imageWidth;
            size.height = imageHeight;
        }
    }
    else
    {
        if (imageHeight>PREVIEWER_MAX_HEIGHT) {
            size.height = PREVIEWER_MAX_HEIGHT;
            size.width = PREVIEWER_MAX_HEIGHT * imageRatio;
        }else
        {
            size.height = imageHeight;
            size.width = imageWidth;
        }
    }
    return size;
}

inline static void setRadiusCorner(UIView* view,float radius)
{
    [view.layer setCornerRadius:radius];
    [view setClipsToBounds:YES];
}

//获取视图在父视图的绝对位置
inline static CGRect getCGRectInScreenFromView(UIView *view,UIView *superView)
{
    CGRect frame = [view convertRect:view.bounds toView:superView];
    return frame;
}

inline static CGFloat getHeightFromDrawMethodWithContents(NSString *string,UIFont *font,float maxWidth)
{
    if (!string || !font || maxWidth < 1) {
        return 0;
    }
    CGRect frame = [string boundingRectWithSize:CGSizeMake(maxWidth, 0)
                                        options:NSStringDrawingUsesLineFragmentOrigin
                                     attributes:@{NSFontAttributeName:font} context:nil];
    return frame.size.height;
}
