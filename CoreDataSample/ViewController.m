//
//  ViewController.m
//  CoreDataSample
//
//  Created by Sergey Zalozniy on 01/02/16.
//  Copyright © 2016 GeekHub. All rights reserved.
//

#import "CoreDataManager.h"

#import "ProductsTableViewController.h"
#import "CDBasket.h"

#import "ViewController.h"

@interface ViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UITextField *dateTextField;
@property (strong, nonatomic) UIDatePicker *datePicker;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end

@implementation ViewController

-(void) viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewBasket:)];
}


-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

#pragma mark - Action methods

-(void) addNewBasket:(id)sender {
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"New Basket" message:@"Enter name" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [controller addAction:action];
    [controller addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Basket name";
    }];
    [controller addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Schedule Date";
        UIDatePicker *picker = [[UIDatePicker alloc] init];
        picker.datePickerMode = UIDatePickerModeDate;
        textField.inputView = picker;
        self.dateTextField = textField;
        self.datePicker = picker;
        [picker addTarget:self action:@selector(datePicked) forControlEvents:UIControlEventValueChanged];
        NSDateFormatter *formater =[[NSDateFormatter alloc] init];
        formater.dateFormat = @"dd/MMMM/yyyy";
        textField.text = [formater stringFromDate:picker.date];
    }];
    action = [UIAlertAction actionWithTitle:@"Create" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *textField = controller.textFields[0];
        UITextField *dateTextField = controller.textFields[1];
        NSDateFormatter *formater =[[NSDateFormatter alloc] init];
        formater.dateFormat = @"dd/MMMM/yyyy";
        [self createBasketWithName:textField.text date:[formater dateFromString:dateTextField.text]];
    }];
    
    [controller addAction:action];
    [self presentViewController:controller animated:YES completion:NULL];
}

- (void)datePicked {
    NSDateFormatter *formater =[[NSDateFormatter alloc] init];
    formater.dateFormat = @"dd/MMMM/yyyy";
    self.dateTextField.text = [formater stringFromDate:[self.datePicker date]];

}

#pragma mark - Private methods

-(void) refreshData {
    [self.fetchedResultsController performFetch:nil];
    [self.tableView reloadData];
}

-(NSArray *) fetchBaskets {
    NSManagedObjectContext *context = [CoreDataManager sharedInstance].managedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:[[CDBasket class] description]];
    return [context executeFetchRequest:request error:nil];
}

-(NSFetchedResultsController*) fetchedResultsController {
    if (!_fetchedResultsController) {
        NSManagedObjectContext *context = [CoreDataManager sharedInstance].managedObjectContext;
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:[[CDBasket class] description]];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"sheduleDate" ascending:YES]];
        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:@"sheduleDate" cacheName:nil];
        [_fetchedResultsController performFetch:nil];
    }
    return _fetchedResultsController;
}

-(void) createBasketWithName:(NSString *)name date:(NSDate*)date {
    NSManagedObjectContext *context = [CoreDataManager sharedInstance].managedObjectContext;
    CDBasket *basket = [NSEntityDescription insertNewObjectForEntityForName:[[CDBasket class] description]
                                              inManagedObjectContext:context];
    basket.name = name;
    basket.sheduleDate = date;
    [[CoreDataManager sharedInstance] saveContext];
    [self refreshData];
}

#pragma mark - Delegated methods

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ProductsTableViewController *controller = [ProductsTableViewController instanceControllerWithBasket:[self.fetchedResultsController objectAtIndexPath:indexPath]];
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - UITableViewDataSource Delegated methods

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.fetchedResultsController.sections[section].numberOfObjects;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.fetchedResultsController.sections.count;
}

-(UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
    label.backgroundColor = [UIColor colorWithRed:0.615 green:0.921 blue:0.502 alpha:1.0];
    CDBasket *basket = self.fetchedResultsController.sections[section].objects[0];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"dd/MMMM/yyyy";
    label.text = [formatter stringFromDate:basket.sheduleDate];
    return label;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier" forIndexPath:indexPath];
    CDBasket *basket = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = basket.name;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

@end
