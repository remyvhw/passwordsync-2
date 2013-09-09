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
#import "UIImage+ImageEffects.h"
#import "Reachability.h"
#import "PSSVersionFlowPasswordCollectionViewController.h"
#import "PSSTwoStepCodeViewController.h"

#define kKeyValueCell @"KeyValueCell"


@interface PSSPasswordDetailViewController () {
    NSInteger __webViewLoads;
}

@property (strong, nonatomic) IBOutlet UIWebView * backgroundWebView;
@property (strong, nonatomic) IBOutlet UIImageView * backgroundImageView;

@property (strong, nonatomic) UITableViewCell * titleCell;
@property (strong, nonatomic) UITableViewCell * notesCell;

@end

@implementation PSSPasswordDetailViewController
dispatch_queue_t backgroundQueue;

-(void)removeWebViewFromViewStack{
    [self.backgroundWebView stopLoading];
    [self.backgroundWebView removeFromSuperview];
    self.backgroundWebView = nil;
}


-(void)editorAction:(id)sender{
    
    UIStoryboard * newPasswordStoryboard = [UIStoryboard storyboardWithName:@"PSSNewPasswordObjectStoryboard_iPhone" bundle:[NSBundle mainBundle]];
    PSSPasswordEditorTableViewController * passwordEditor = [newPasswordStoryboard instantiateViewControllerWithIdentifier:@"passwordEditorBaseViewControlller"];
    
    passwordEditor.editorDelegate = self;
    passwordEditor.baseObject = self.detailItem;
    
    [self.navigationController pushViewController:passwordEditor animated:YES];
    
}

-(void)lockUIAction:(id)notification{
    self.isPasscodeUnlocked = NO;
    [self createNotesCell];
    [super lockUIAction:notification];
}


-(void)presentVersionsBrowser:(id)sender{
    
    PSSVersionFlowPasswordCollectionViewController * flowController = [[PSSVersionFlowPasswordCollectionViewController alloc] initWithNibName:@"PSSVersionFlowGenericControllerViewController" bundle:[NSBundle mainBundle]];
    
    flowController.detailItem = self.detailItem;
    flowController.backgroundImage.image = self.backgroundImageView.image;
    flowController.editorDelegate = self;
    
    [self.navigationController pushViewController:flowController animated:YES];
    
}

-(void)presentTwoStepBrowser{
    PSSTwoStepCodeViewController * twoStepController = [[PSSTwoStepCodeViewController alloc] initWithNibName:@"PSSTwoStepCodeViewController" bundle:[NSBundle mainBundle]];
    
    twoStepController.detailItem = self.detailItem;
    [self.navigationController pushViewController:twoStepController animated:YES];
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

-(void)insertBlurredBackgroundImageViewInViewHierarchyWithImage:(UIImage*)backgroundImage animated:(BOOL)animated{
    
    
    if (!self.backgroundImageView.image) {
        
        
        CGFloat animationDuration = 0;
        if (animated) {
            animationDuration = 1;
        }
        
        [self.backgroundImageView setAlpha:0.0];
        
        
        dispatch_async(backgroundQueue, ^(void) {
            UIImage * blurredImage = [backgroundImage applyLightEffect];
            
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                
                // Set the image on the main thread
                [self.backgroundImageView setImage:blurredImage];
                [UIView animateWithDuration:animationDuration animations:^{
                    [self.backgroundImageView setAlpha:1.0];
                }];
            });
            
        });
        
        
    }
    
    
}

-(UIImage *)drawWebViewToImage:(UIView *)view{
    
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    view.hidden = NO;
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    view.hidden = YES;
    return img;
}

-(void)saveDecorativeImageViewAndAnimateBackgroundAppearance{
    
    
    
    double delayInSeconds = 1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        UIImage * image = [self drawWebViewToImage:self.backgroundWebView];
        
        [self.detailItem setDecorativeImageForDevice:image];
        
        [self insertBlurredBackgroundImageViewInViewHierarchyWithImage:image animated:YES];
        [self removeWebViewFromViewStack];
    });
    
    
    
}

-(void)fetchDecorativeImageForCurrentDevice{
    
    if (![self.detailItem mainDomain]) {
        // There are no url so we don't care
        return;
    }
    
    
    [self.backgroundWebView setUserInteractionEnabled:NO];
    [self.backgroundWebView setOpaque:YES];
    
    NSString * domainHostname = [self.detailItem.mainDomain hostname];
    
    NSURL * hostnameURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", domainHostname]];
    
    NSURLRequest * domainRequest = [[NSURLRequest alloc] initWithURL:hostnameURL];
    
    [self.backgroundWebView loadRequest:domainRequest];
    self.backgroundWebView.delegate = self;
    
    
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
    
    __webViewLoads = 0;
    
    backgroundQueue = dispatch_queue_create([[NSString stringWithFormat:@"%@.WebsitesWebViewFetchBlurThread", [[NSBundle mainBundle] bundleIdentifier]] cStringUsingEncoding:NSUTF8StringEncoding], NULL);
    
    
    self.tableView.backgroundColor = [UIColor clearColor];
    if (self.detailItem.decorativeImageForDevice) {
        [self removeWebViewFromViewStack];
        [self insertBlurredBackgroundImageViewInViewHierarchyWithImage:self.detailItem.decorativeImageForDevice animated:YES];
    } else {
        
        // Test for reachability
        
        __weak Reachability* reachability = [Reachability reachabilityWithHostname:@"www.google.com"];
        
        // We only will capture a screenshot if user is currently connected to wifi.
        reachability.reachableOnWWAN = NO;
        
        reachability.reachableBlock = ^(Reachability*reach)
        {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [self fetchDecorativeImageForCurrentDevice];
                [self.backgroundWebView setScalesPageToFit:YES];
            });
            [reachability stopNotifier];
        };
        
        reachability.unreachableBlock = ^(Reachability*reach)
        {
            [reachability stopNotifier];
        };
        
        [reachability startNotifier];
        
    }
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView.contentInset = UIEdgeInsetsMake(64., 0, 49., 0);
    
    
    
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
    
    NSString * decryptedNotes = [(PSSPasswordVersion*)self.detailItem.currentHardLinkedVersion decryptedNotes];
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
    if (self.isPasscodeUnlocked) {
        return 5;
    }
    return 4;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (section == 0) {
        // Title section
        return 1;
    } else if (section == 1) {
        // Password and username
        int numberOfRows = 0;
        if ([(PSSPasswordVersion*)self.detailItem.currentHardLinkedVersion username]) {
            numberOfRows++;
        }
        if ([(PSSPasswordVersion*)self.detailItem.currentHardLinkedVersion username]) {
            numberOfRows++;
        }
        
        return numberOfRows;
    } else if (section == 2) {
        // URL
        return [self.detailItem.domains count];
    } else if (section == 3) {
        // Notes
        if ([(PSSPasswordVersion*)self.detailItem.currentHardLinkedVersion notes]) {
            return 1;
        }
    } else if (section==4){
        // Buttons
        return 4;
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
        if (indexPath.row == 0 && [(PSSPasswordVersion*)self.detailItem.currentHardLinkedVersion username]) {
            
            if (self.isPasscodeUnlocked) {
                cell.detailTextLabel.text = [(PSSPasswordVersion*)self.detailItem.currentHardLinkedVersion decryptedPassword];
                cell.accessoryView = [self copyImageAccessoryView];
            } else {
                cell.accessoryView = nil;
            }
            
            cell.textLabel.text = NSLocalizedString(@"Username", nil);
            cell.detailTextLabel.text = [(PSSPasswordVersion*)self.detailItem.currentHardLinkedVersion decryptedUsername];
            
        } else if (indexPath.row == 1) {
            
            cell.textLabel.text = NSLocalizedString(@"Password", nil);
            if (self.isPasscodeUnlocked) {
                cell.detailTextLabel.text = [(PSSPasswordVersion*)self.detailItem.currentHardLinkedVersion decryptedPassword];
                cell.accessoryView = [self copyImageAccessoryView];
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
    
    // Buttons
    if (indexPath.section == 4) {
        
        if (indexPath.row == 0) {
            // Favorite
            UITableViewCell * favoriteCell = [self favoriteTableViewCell];
            if ([[self.detailItem favorite] boolValue]) {
                favoriteCell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                favoriteCell.accessoryType = UITableViewCellAccessoryNone;
            }
            
            return favoriteCell;
        } else if (indexPath.row == 1) {
            // Versions
            return [self versionsTableViewCell];
        } else if (indexPath.row == 2) {
            // Tags
            return [self tagsTableViewCell];
        } else if (indexPath.row == 3){
            return [self twoStepsTableViewCell];
        }
        
        
    }
    
    return nil;
}

#pragma mark - UITableViewDelegate methods

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    if (![self isPasscodeUnlocked]) {
        
        [self showUnlockingViewController];
        return;
    }
    
    
    if (indexPath.section == 1 && indexPath.row == 0) {
        // Copy username
        
        UIActionSheet * copyUsernameActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Copy Username", nil), nil];
        
        [copyUsernameActionSheet setTag:1000];
        
        [copyUsernameActionSheet showFromTabBar:[(UITabBarController*)self.view.window.rootViewController tabBar]];
        
    } else if (indexPath.section == 1 && indexPath.row == 1) {
        // Copy password
        
        UIActionSheet * copyPasswordActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:NSLocalizedString(@"Copy Password", nil) otherButtonTitles:nil];
        
        [copyPasswordActionSheet setTag:1001];
        
        [copyPasswordActionSheet showFromTabBar:[(UITabBarController*)self.view.window.rootViewController tabBar]];
        
    }
    
    
    
    if (indexPath.section == 2) {
        // URL
        
        [self showWebBrowserForDomain:[self.detailItem.fetchedDomains objectAtIndex:indexPath.row]];
        
    }
    
    
    
    // Buttons
    if (indexPath.section == 4) {
        
        if (indexPath.row == 0) {
            // Favorite
            [self toggleFavorite];
            self.favoriteTableViewCell= nil;
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        } else if (indexPath.row == 1) {
            // Versions
            [self presentVersionsBrowser:tableView];
        } else if (indexPath.row == 2) {
            // Tags
            [self presentTagsBrowser:[tableView cellForRowAtIndexPath:indexPath]];
        } else if (indexPath.row == 3){
            [self presentTwoStepBrowser];
        }
        
        
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        
    }
    
    
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
    
    
}

- (void)webView:(UIWebView*)webView didFailLoadWithError:(NSError*)error {
    __webViewLoads--;
}


#pragma mark - UIActionSheetDelegate

-(void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex{
    
    if (actionSheet.tag == 1000) {
        // Username
        
        if (buttonIndex==0) {
            [UIPasteboard generalPasteboard].string = [(PSSPasswordVersion*)self.detailItem.currentHardLinkedVersion decryptedUsername];
            [SVProgressHUD showImage:[UIImage imageNamed:@"Success"] status:NSLocalizedString(@"Copied", nil)];
        }
        
        
    } else if (actionSheet.tag == 1001) {
        // Password
        
        if (buttonIndex==0) {
            [UIPasteboard generalPasteboard].string = [(PSSPasswordVersion*)self.detailItem.currentHardLinkedVersion decryptedPassword];
            [SVProgressHUD showImage:[UIImage imageNamed:@"Success"] status:NSLocalizedString(@"Copied", nil)];
        }
        
        
    }
    
    
}


@end
