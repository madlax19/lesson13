//
//  ProductsTableViewController.m
//  CoreDataSample
//
//  Created by Sergey Zalozniy on 01/02/16.
//  Copyright © 2016 GeekHub. All rights reserved.
//

#import "CoreDataManager.h"

#import "CDBasket.h"
#import "CDProduct.h"

#import "ProductsTableViewController.h"

@interface ProductsTableViewController () <UITableViewDelegate>

@property (nonatomic, strong) CDBasket *basket;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end

@implementation ProductsTableViewController

#pragma mark - Instance initialization

+(instancetype) instanceControllerWithBasket:(CDBasket *)basket {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ProductsTableViewController *controller = [sb instantiateViewControllerWithIdentifier:@"ProductsTableViewControllerIdentifier"];
    controller.basket = basket;
    return controller;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewProduct:)];
}

-(NSFetchedResultsController*)fetchedResultsController{
    if (!_fetchedResultsController) {
        NSManagedObjectContext *context = [CoreDataManager sharedInstance].managedObjectContext;
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"CDProduct"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"complete" ascending:NO],[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
        request.predicate = [NSPredicate predicateWithFormat:@"basket=%@",self.basket.objectID];
        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:@"complete" cacheName:nil];
        [_fetchedResultsController performFetch:nil];
    }
    return _fetchedResultsController;
}

#pragma mark - Private methods

-(void) refreshData {
    [self.fetchedResultsController performFetch:nil];
    [self.tableView reloadData];
}


-(void) addNewProduct:(id)sender {
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"New Product" message:@"Enter name" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [controller addAction:action];
    [controller addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Product name";
    }];
    [controller addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Product count";
        textField.keyboardType = UIKeyboardTypeNumberPad;
    }];
    action = [UIAlertAction actionWithTitle:@"Create" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *textField = controller.textFields[0];
        UITextField *countTextField = controller.textFields[1];
        [self createProductWithName:textField.text count:[NSDecimalNumber decimalNumberWithString:countTextField.text]];
    }];
    
    [controller addAction:action];
    [self presentViewController:controller animated:YES completion:NULL];
}


-(void) createProductWithName:(NSString *)name count:(NSDecimalNumber*) count{
    NSManagedObjectContext *context = [CoreDataManager sharedInstance].managedObjectContext;
    CDProduct *product = [NSEntityDescription insertNewObjectForEntityForName:[[CDProduct class] description]
                                                     inManagedObjectContext:context];
    product.name = name;
    product.count = count;
    [self.basket addProductsObject:product];
    [[CoreDataManager sharedInstance] saveContext];
    [self refreshData];
}


-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   CDProduct *product = [self.fetchedResultsController objectAtIndexPath:indexPath];
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Edit Product" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    
    [controller addAction:[UIAlertAction actionWithTitle:@"Edit" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self showEditProductAlert:product];
    }]];
    [controller addAction:[UIAlertAction actionWithTitle:@"Mark" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if ([product.complete boolValue]) {
                product.complete = @NO;
            } else {
                product.complete = @YES;
                [self showEditProductPrice:product];
            }
        [[CoreDataManager sharedInstance] saveContext];
        [self refreshData];
    }]];
    [controller addAction:[UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSManagedObjectContext *context = [CoreDataManager sharedInstance].managedObjectContext;
        [context deleteObject:product];
        [[CoreDataManager sharedInstance] saveContext];
        [self refreshData];

    }]];
    [controller addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    
    [self presentViewController:controller animated:YES completion:NULL];

 }

-(void) showEditProductAlert:(CDProduct*) product {
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Edit Product" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [controller addAction:action];
    [controller addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Product name";
        textField.text = product.name;
    }];
    [controller addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Product count";
        textField.keyboardType = UIKeyboardTypeNumberPad;
        textField.text = product.count.stringValue;
    }];
    [controller addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Product price";
        textField.text = product.price.stringValue;
        textField.keyboardType = UIKeyboardTypeDecimalPad;
    }];

    action = [UIAlertAction actionWithTitle:@"Update" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *textField = controller.textFields[0];
        UITextField *countTextField = controller.textFields[1];
        UITextField *priceTextField = controller.textFields[2];

        product.name = textField.text;
        product.count = [NSDecimalNumber decimalNumberWithString:countTextField.text];
        product.price = [NSDecimalNumber decimalNumberWithString:priceTextField.text];
        [[CoreDataManager sharedInstance] saveContext];
        [self refreshData];
    }];
    
    [controller addAction:action];
    [self presentViewController:controller animated:YES completion:NULL];
  
}

-(void) showEditProductPrice:(CDProduct*) product {
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Set Product Price" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [controller addAction:action];
    
    [controller addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Product price";
        textField.keyboardType = UIKeyboardTypeDecimalPad;
        textField.text = product.price.stringValue;
    }];
    
    
    action = [UIAlertAction actionWithTitle:@"Update" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *priceTextField = controller.textFields[0];

        product.price = [NSDecimalNumber decimalNumberWithString:priceTextField.text];
        [[CoreDataManager sharedInstance] saveContext];
        [self refreshData];
    }];
    
    [controller addAction:action];
    [self presentViewController:controller animated:YES completion:NULL];
}

#pragma mark - Table view data source


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.fetchedResultsController.sections.count;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
    label.backgroundColor = [UIColor colorWithRed:0.615 green:0.921 blue:0.502 alpha:1.0];
    label.text = section == 0 ? @"Buyed" : @"Not buyed";
    return label;
}

-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section==0) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
        label.backgroundColor = [UIColor orangeColor];
        label.textAlignment = NSTextAlignmentRight;
        double summ = 0.0;
        NSArray *objects = self.fetchedResultsController.sections[section].objects;
        for (int i = 0; i < objects.count; i++) {
            CDProduct *product = [objects objectAtIndex:i];
            summ = summ + ((double)product.count.intValue * product.price.doubleValue);
        }
        label.text = [NSString stringWithFormat:@"Total price : %.2f", summ];
        return label;
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id<NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController.sections objectAtIndex:section];
    
    return sectionInfo.numberOfObjects;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier" forIndexPath:indexPath];
    CDProduct *product = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = product.name;
    
    if ([product.complete boolValue]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        CDProduct *product = self.fetchedResultsController.sections[indexPath.section].objects[indexPath.row];
//        [[CoreDataManager sharedInstance].managedObjectContext deleteObject:product];
//        //NSMutableArray *items = [self.items mutableCopy];
//        [items removeObject:product];
//        self.items = [items copy];
//        
//        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
//        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//    }   
//}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
