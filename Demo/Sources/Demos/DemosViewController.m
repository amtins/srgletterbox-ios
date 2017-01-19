//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "DemosViewController.h"

#import "ModalPlayerViewController.h"
#import "SimplePlayerViewController.h"

@implementation DemosViewController

#pragma mark Object lifecycle

- (instancetype)init
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:NSStringFromClass([self class]) bundle:nil];
    return [storyboard instantiateInitialViewController];
}

#pragma mark Getters and setters

- (NSString *)title
{
    return @"Letterbox demos";
}

#pragma mark UITableViewDelegate protocol

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0: {
            SimplePlayerViewController *playerViewController = [[SimplePlayerViewController alloc] initWithUid:@"41981254"];
            [self.navigationController pushViewController:playerViewController animated:YES];
            break;
        }
            
        case 1: {
            SimplePlayerViewController *playerViewController = [[SimplePlayerViewController alloc] initWithUid:@"42844052"];
            [self.navigationController pushViewController:playerViewController animated:YES];
            break;
        }
            
        case 2: {
            ModalPlayerViewController *playerViewController = [[ModalPlayerViewController alloc] initWithURN:@"urn:swi:video:41981254"];
            [self presentViewController:playerViewController animated:YES completion:nil];
            break;
        }
            
        case 3: {
            ModalPlayerViewController *playerViewController = [[ModalPlayerViewController alloc] initWithURN:@"urn:swi:video:42844052"];
            [self presentViewController:playerViewController animated:YES completion:nil];
            break;
        }
        case 4: {
            ModalPlayerViewController *playerViewController = [[ModalPlayerViewController alloc] initWithURN:@"urn:srf:ais:video:db741834-044f-443e-901a-e2fc03a4ef25"];
            [self presentViewController:playerViewController animated:YES completion:nil];
            break;
        }
            
        default: {
            break;
        }
    }
}

@end
