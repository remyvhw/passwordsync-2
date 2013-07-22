//
//  PSSPasswordDetailViewController.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-21.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSPasswordDetailViewController.h"
#import "PSSPasswordBaseObject.h"
#import "PSSPasswordVersion.h"
#import "PSSPasswordDomain.h"
#import "PSSPasswordEditorTableViewController.h"

#define kKeyValueCell @"KeyValueCell"


@interface PSSPasswordDetailViewController () {
    NSInteger __webViewLoads;
}

@property (strong, nonatomic) UIWebView * backgroundWebView;
@property (weak, nonatomic) IBOutlet UIImageView * backgroundImageView;

@property (strong, nonatomic) UITableViewCell * titleCell;
@property (strong, nonatomic) UITableViewCell * notesCell;

@end

@implementation PSSPasswordDetailViewController





-(void)editorAction:(id)sender{
    
    UIStoryboard * newPasswordStoryboard = [UIStoryboard storyboardWithName:@"PSSNewPasswordObjectStoryboard_iPhone" bundle:[NSBundle mainBundle]];
    PSSPasswordEditorTableViewController * passwordEditor = [newPasswordStoryboard instantiateViewControllerWithIdentifier:@"passwordEditorBaseViewControlller"];
    
    passwordEditor.editorDelegate = self;
    passwordEditor.passwordBaseObject = self.detailItem;
    
    [self.navigationController pushViewController:passwordEditor animated:YES];
    
    
}

-(void)lockUIAction:(id)notification{
    self.isPasscodeUnlocked = NO;
    [self createNotesCell];
    [super lockUIAction:notification];
}

-(void)userDidUnlockWithPasscode{
    
    // We need to reload the note cell
    [self createNotesCell];
    [super userDidUnlockWithPasscode];
    
}


-(void)showWebBrowserForDomain:(PSSPasswordDomain*)domain {
    
    NSURL * urlWithDomain = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", [domain hostname]]];
    
    [[UIApplication sharedApplication] openURL:urlWithDomain];
    
}

-(void)insertBlurredBackgroundImageViewInViewHierarchyWithImage:(UIImage*)image animated:(BOOL)animated{
    
    
    
    CGFloat animationDuration = 0;
    if (animated) {
        animationDuration = 1;
    }
    
    [self.backgroundImageView setAlpha:0.0];
    [self.backgroundImageView setImage:image];
    [UIView animateWithDuration:animationDuration animations:^{
        [self.backgroundImageView setAlpha:1.0];
    }];
    
}

-(UIImage *)drawWebViewToImage:(UIView *)view{
    
    
    UIGraphicsBeginImageContext(view.bounds.size);
    [view.layer drawInContext:UIGraphicsGetCurrentContext()];
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

-(void)saveDecorativeImageViewAndAnimateBackgroundAppearance{
    
    
    
    double delayInSeconds = 1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        UIImage * image = [self drawWebViewToImage:[self.backgroundWebView snapshotView]];
        [self insertBlurredBackgroundImageViewInViewHierarchyWithImage:image animated:YES];
        [self.backgroundWebView removeFromSuperview];
        self.backgroundWebView = nil;
    });
    
    
    
}

-(void)fetchDecorativeImageForCurrentDevice{
    
    if (![self.detailItem mainDomain]) {
        // There are no url so we don't care
        return;
    }
    
    UIWebView * backgroundWebView = [[UIWebView alloc] initWithFrame:self.view.frame];
    
    [backgroundWebView setUserInteractionEnabled:NO];
    [backgroundWebView setOpaque:YES];
    
    NSString * domainHostname = [self.detailItem.mainDomain hostname];
    
    NSURL * hostnameURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", domainHostname]];
    
    NSURLRequest * domainRequest = [[NSURLRequest alloc] initWithURL:hostnameURL];
    
    [backgroundWebView loadRequest:domainRequest];
    backgroundWebView.delegate = self;
    [self.view addSubview:backgroundWebView];
    
    self.backgroundWebView = backgroundWebView;
    
    [self.view sendSubviewToBack:self.backgroundWebView];
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    /*__webViewLoads = 0;
    
    self.tableView.backgroundColor = [UIColor clearColor];
    if (self.detailItem.decorativeImageForDevice) {
        [self insertBlurredBackgroundImageViewInViewHierarchyWithImage:self.detailItem.decorativeImageForDevice animated:NO];
    } else {
        [self fetchDecorativeImageForCurrentDevice];
    }
    */
    
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)createNotesCell{
    UITableViewCell * notesCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    
    notesCell.textLabel.numberOfLines = 0;
    notesCell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSString * decryptedNotes = self.detailItem.currentVersion.decryptedNotes;
    if (decryptedNotes && ![decryptedNotes isEqualToString:@""]) {
        
        if (self.isPasscodeUnlocked) {
            notesCell.textLabel.text = decryptedNotes;
        } else {
            notesCell.textLabel.text = NSLocalizedString(@"Locked", nil);
            notesCell.textLabel.textColor = [UIColor lightGrayColor];
            notesCell.accessoryView = [self lockedImageAccessoryView];
        }
        
        
    } else {
        notesCell.textLabel.text = NSLocalizedString(@"No Notes", nil);
        notesCell.textLabel.textColor = [UIColor lightGrayColor];
        notesCell.textLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    self.notesCell = notesCell;
    
}


#pragma mark - UITableViewDelegate methods

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 3) {
        return NSLocalizedString(@"Notes", nil);
    }
    return @"";
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 3) {
        // Notes
        
        if (!self.notesCell) {
            [self createNotesCell];
        }
        
        CGRect labelFrame = self.notesCell.textLabel.frame;
        labelFrame.size.width = self.view.frame.size.width;
        self.notesCell.textLabel.frame = labelFrame;
        [self.notesCell.textLabel sizeToFit];
        
        return self.notesCell.textLabel.frame.size.height + 20;
        
    }
    
    return 44.;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 4;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (section == 0) {
        // Title section
        return 1;
    } else if (section == 1) {
        // Password and username
        int numberOfRows = 0;
        if (self.detailItem.currentVersion.username) {
            numberOfRows++;
        }
        if (self.detailItem.currentVersion.username) {
            numberOfRows++;
        }
        
        return numberOfRows;
    } else if (section == 2) {
        // URL
        return [self.detailItem.domains count];
    } else if (section == 3) {
        // Notes
        if (self.detailItem.currentVersion.notes) {
            return 1;
        }
    }
    
    return 0;
}


-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    /// TITLE
    if (indexPath.section == 0 && indexPath.row == 0) {
        // Title cell
        if (!self.titleCell) {
            UITableViewCell * titleCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            titleCell.selectionStyle = UITableViewCellSelectionStyleNone;
            self.titleCell = titleCell;
        }
        self.titleCell.textLabel.text = self.detailItem.displayName;
        [self.titleCell.imageView setImage:[UIImage imageWithData:self.detailItem.favicon]];
        
        return self.titleCell;
    }
    
    
    if (indexPath.section == 1) {
        // Username && password
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kKeyValueCell forIndexPath:indexPath];
        cell.detailTextLabel.textColor = [UIColor blackColor];
        cell.accessoryView = nil;
        if (indexPath.row == 0 && self.detailItem.currentVersion.username) {
            
            cell.textLabel.text = NSLocalizedString(@"Username", nil);
            cell.detailTextLabel.text = self.detailItem.currentVersion.decryptedUsername;
            
        } else if (indexPath.row == 1) {
            
            cell.textLabel.text = NSLocalizedString(@"Password", nil);
            if (self.isPasscodeUnlocked) {
                cell.detailTextLabel.text = self.detailItem.currentVersion.decryptedPassword;
            } else {
                cell.detailTextLabel.text = NSLocalizedString(@"Locked", nil);
                cell.detailTextLabel.textColor = [UIColor lightGrayColor];
                cell.accessoryView = [self lockedImageAccessoryView];
            }
            
            
        }
        
        
        return cell;
    }
    
    
    // Domains
    if (indexPath.section == 2) {
        // Domains
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"urlCell" forIndexPath:indexPath];
        cell.textLabel.text = NSLocalizedString(@"URL", nil);
        cell.detailTextLabel.text = [[self.detailItem.fetchedDomains objectAtIndex:indexPath.row] hostname];
        cell.detailTextLabel.textColor = self.view.window.tintColor;
        
        
        
        return cell;
    }
    
    if (indexPath.section == 3) {
        
        if (!self.notesCell) {
            [self createNotesCell];
        }
        return self.notesCell;
        
    }
    
    
    return nil;
}

#pragma mark - UITableViewDelegate methods

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    if (![self isPasscodeUnlocked]) {
        
        [self showUnlockingViewController];
        return;
    }
    
    if (indexPath.section == 2) {
        // URL
        
        [self showWebBrowserForDomain:[self.detailItem.fetchedDomains objectAtIndex:indexPath.row]];
        
    }
    
    // Offer different options
    
    
}

#pragma mark - UIWebViewDelegate methods

- (void)webViewDidStartLoad:(UIWebView *)webView {
    __webViewLoads++;
}

-(void)webViewDidFinishLoad:(UIWebView *)webView {
    __webViewLoads--;
    
    if (__webViewLoads > 0) {
        return;
    }
    [self saveDecorativeImageViewAndAnimateBackgroundAppearance];
    
    [self.view sendSubviewToBack:webView];
    //[webView removeFromSuperview];
    //self.backgroundWebView = nil;
    //[webView setAlpha:0.2];
}

- (void)webView:(UIWebView*)webView didFailLoadWithError:(NSError*)error {
    __webViewLoads--;
}


@end
