//
//  MyFristViewController.m
//  RATreeViewBasicExample
//
//  Created by 惠上科技 on 2018/10/8.
//  Copyright © 2018年 com.Augustyniak. All rights reserved.
//

#import "MyFristViewController.h"
#import "RAViewController.h"
@interface MyFristViewController ()

@end

@implementation MyFristViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    nextButton.backgroundColor = [UIColor redColor];
    nextButton.frame = CGRectMake(100, 100, 80, 80);
    nextButton.layer.masksToBounds = YES;
    nextButton.layer.cornerRadius = 40;
    [self.view addSubview:nextButton];
    [nextButton addTarget:self action:@selector(nextButtonClick) forControlEvents:UIControlEventTouchUpInside];
}

-(void)nextButtonClick{
    RAViewController *nextView = [[RAViewController alloc] init];
    [self.navigationController pushViewController:nextView animated:YES];
}

@end
