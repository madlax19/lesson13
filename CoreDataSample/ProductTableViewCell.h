//
//  ProductTableViewCell.h
//  CoreDataSample
//
//  Created by Elena on 14.02.16.
//  Copyright © 2016 GeekHub. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *productNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *productCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *productPriceLabel;

@end
