//
//  ViewToPDF.m
//  ViewToPDF
//
//  Created by Igor Ananiev on 5/02/13.
//  Copyright (c) 2013 Igor Ananiev. All rights reserved.
//

#import "ViewToPDF.h"

@interface ViewToPDF()

-(void)renderSubviewsOfView:(UIView*)parentView;

/* Drawing methods */
-(void)drawAndFillRect:(CGRect)rect andFillWithColor:(UIColor *)color;
-(void)drawText:(NSString*)textToDraw inFrame:(CGRect)frameRect withFont:(UIFont *)labelFont andColor:(UIColor*)color andTextAlignment:(UITextAlignment)alignment;
-(void)drawImage:(UIImage*)image inRect:(CGRect)rect;

@end

@implementation ViewToPDF
{
    UIView *viewToRender;
}

@synthesize fullPDFPath = _fullPDFPath;

-(ViewToPDF *)initWithView:(UIView*)view andPDFFileName:(NSString*)PDFFileName
{
    if (self = [super init]) {
        NSArray *arrayPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *path = [arrayPaths objectAtIndex:0];
        _fullPDFPath = [path stringByAppendingPathComponent:PDFFileName];
        viewToRender = view;
    }
    return self;
}

-(void)renderSubviewsOfView:(UIView*)parentView
{
    NSArray *subviews = [parentView subviews];
    if ([subviews count] == 0) return;
    
    for (UIView *view in subviews)
    {
        CGRect drawFrame = view.frame;
        if(parentView != viewToRender)
        {
            drawFrame = CGRectMake(view.frame.origin.x+parentView.frame.origin.x, view.frame.origin.y+parentView.frame.origin.y, view.frame.size.width, view.frame.size.height);
        }
        
        if([view isKindOfClass:[UILabel class]])
        {
            UILabel *label = (UILabel*)view;
            
            if(label.backgroundColor != [UIColor clearColor] && label.backgroundColor != nil)
            {
                [self drawAndFillRect:drawFrame andFillWithColor:label.backgroundColor];
            }
            drawFrame = CGRectMake(label.frame.origin.x, label.frame.origin.y+label.frame.size.height, label.frame.size.width, label.frame.size.height);
            [self drawText:label.text inFrame:drawFrame withFont:label.font andColor:label.textColor andTextAlignment:label.textAlignment];
        }
        else if([view isKindOfClass:[UIImageView class]])
        {
            UIImageView *imgView = (UIImageView*)view;
            if(imgView.image != nil)
            {
                [self drawImage:imgView.image inRect:drawFrame];
            }
            else if(imgView.backgroundColor != [UIColor clearColor] && imgView.backgroundColor != nil)
            {
                [self drawAndFillRect:drawFrame andFillWithColor:imgView.backgroundColor];
            }
        }
        else if([view isKindOfClass:[UIView class]])
        {
            if(view.backgroundColor != [UIColor clearColor] && view.backgroundColor != nil)
            {
                [self drawAndFillRect:drawFrame andFillWithColor:view.backgroundColor];
            }
        }
        [self renderSubviewsOfView:view];
    }
}

-(void)render
{
    UIGraphicsBeginPDFContextToFile(_fullPDFPath, CGRectZero, nil);
    UIGraphicsBeginPDFPageWithInfo(viewToRender.frame, nil);
    [self renderSubviewsOfView:viewToRender];
    UIGraphicsEndPDFContext();
}

#pragma mark Drawing Methods

-(void)drawText:(NSString*)textToDraw inFrame:(CGRect)frameRect withFont:(UIFont *)labelFont andColor:(UIColor*)color andTextAlignment:(UITextAlignment)alignment
{
    CGSize stringsize = [textToDraw sizeWithFont:labelFont];
    if(alignment == UITextAlignmentCenter)
    {
        frameRect = CGRectMake(frameRect.origin.x+((frameRect.size.width - stringsize.width)/2), frameRect.origin.y, stringsize.width, frameRect.size.height);
    }
    else if(alignment == UITextAlignmentRight)
    {
        frameRect = CGRectMake(frameRect.origin.x+(frameRect.origin.x-stringsize.width), frameRect.origin.y, stringsize.width, frameRect.size.height);
    }
    
    frameRect = CGRectMake(frameRect.origin.x, frameRect.origin.y+((frameRect.size.height - stringsize.height)/2), frameRect.size.width, stringsize.height);
    
    int length=[textToDraw length];
    CFStringRef string = (__bridge CFStringRef) textToDraw;
    CFMutableAttributedStringRef currentText = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
    
    CFAttributedStringReplaceString (currentText,CFRangeMake(0, 0), string);
    CFAttributedStringSetAttribute(currentText, CFRangeMake(0, length), kCTForegroundColorAttributeName, color.CGColor);
    CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)labelFont.fontName, labelFont.pointSize, nil);
    CFAttributedStringSetAttribute(currentText,CFRangeMake(0, length),kCTFontAttributeName,font);
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(currentText);
    
    CGMutablePathRef framePath = CGPathCreateMutable();
    CGPathAddRect(framePath, NULL, frameRect);
    CFRange currentRange = CFRangeMake(0, 0);
    CTFrameRef frameRef = CTFramesetterCreateFrame(framesetter, currentRange, framePath, NULL);
    CGPathRelease(framePath);
    CGContextRef    currentContext = UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(currentContext, CGAffineTransformIdentity);
    CGContextTranslateCTM(currentContext, 0, frameRect.origin.y*2);
    CGContextScaleCTM(currentContext, 1.0, -1.0);
    CTFrameDraw(frameRef, currentContext);
    CGContextScaleCTM(currentContext, 1.0, -1.0);
    CGContextTranslateCTM(currentContext, 0, (-1)*frameRect.origin.y*2);
    CFRelease(frameRef);
    CFRelease(framesetter);
}

-(void)drawAndFillRect:(CGRect)rect andFillWithColor:(UIColor *)color
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGPathRef path = CGPathCreateWithRect(rect, NULL);
    [color setFill];
    [color setStroke];
    CGContextAddPath(context, path);
    CGContextDrawPath(context, kCGPathFillStroke);
    CGPathRelease(path);
}

-(void)drawImage:(UIImage*)image inRect:(CGRect)rect
{
    [image drawInRect:rect];
}

@end
