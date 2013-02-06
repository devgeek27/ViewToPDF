//
//  ViewToPDF.h
//  ViewToPDF
//
//  Created by Igor Ananiev on 5/02/13.
//  Copyright (c) 2013 Igor Ananiev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>

@interface ViewToPDF : NSObject

@property (nonatomic, readonly) NSString *fullPDFPath;

-(ViewToPDF *)initWithView:(UIView*)view andPDFFileName:(NSString*)PDFFileName;
-(void)render;

@end
