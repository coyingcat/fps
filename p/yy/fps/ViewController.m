//
//  ViewController.m
//  fps
//
//  Created by Jz D on 2021/10/17.
//

#import "ViewController.h"

#import "YYFPSLabel.h"

@interface ViewController ()

@property (nonatomic, strong) YYFPSLabel * label;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CGRect bounds = [[UIScreen mainScreen] bounds];
    self.label = [[YYFPSLabel alloc] initWithFrame: CGRectMake(20, 20, bounds.size.width - 20 * 2, 80)];
    [self.view addSubview: self.label];
    
}


@end
