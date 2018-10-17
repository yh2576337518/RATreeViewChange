
//The MIT License (MIT)
//
//Copyright (c) 2014 Rafał Augustyniak
//
//Permission is hereby granted, free of charge, to any person obtaining a copy of
//this software and associated documentation files (the "Software"), to deal in
//the Software without restriction, including without limitation the rights to
//use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
//the Software, and to permit persons to whom the Software is furnished to do so,
//subject to the following conditions:
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "RAViewController.h"
#import "RATreeView.h"
#import "RADataObject.h"
#import "RATableViewCell.h"
@interface RAViewController () <RATreeViewDelegate, RATreeViewDataSource>
@property (strong, nonatomic) NSMutableArray *data;
@property (weak, nonatomic) RATreeView *treeView;
@end

@implementation RAViewController
- (void)viewDidLoad{
  [super viewDidLoad];
  self.data = [NSMutableArray arrayWithCapacity:0];
  
  [self loadData];
  
  RATreeView *treeView = [[RATreeView alloc] initWithFrame:self.view.bounds];
  
  treeView.delegate = self;
  treeView.dataSource = self;
  treeView.treeFooterView = [UIView new];
  treeView.separatorStyle = RATreeViewCellSeparatorStyleSingleLine;

  UIRefreshControl *refreshControl = [UIRefreshControl new];
  [refreshControl addTarget:self action:@selector(refreshControlChanged:) forControlEvents:UIControlEventValueChanged];
  [treeView.scrollView addSubview:refreshControl];
  
  [treeView reloadData];
  [treeView setBackgroundColor:[UIColor colorWithWhite:0.97 alpha:1.0]];
  
  
  self.treeView = treeView;
  self.treeView.frame = self.view.bounds;
  self.treeView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  [self.view insertSubview:treeView atIndex:0];
  
  [self.navigationController setNavigationBarHidden:NO];
  self.navigationItem.title = NSLocalizedString(@"Things", nil);
  
  [self.treeView registerNib:[UINib nibWithNibName:NSStringFromClass([RATableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([RATableViewCell class])];
}

- (void)viewWillAppear:(BOOL)animated{
  [super viewWillAppear:animated];
  int systemVersion = [[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."][0] intValue];
  if (systemVersion >= 7 && systemVersion < 8) {
    CGRect statusBarViewRect = [[UIApplication sharedApplication] statusBarFrame];
    float heightPadding = statusBarViewRect.size.height+self.navigationController.navigationBar.frame.size.height;
    self.treeView.scrollView.contentInset = UIEdgeInsetsMake(heightPadding, 0.0, 0.0, 0.0);
    self.treeView.scrollView.contentOffset = CGPointMake(0.0, -heightPadding);
  }
  
  self.treeView.frame = self.view.bounds;
}


#pragma mark ------------Actions
- (void)refreshControlChanged:(UIRefreshControl *)refreshControl{
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    [refreshControl endRefreshing];
  });
}


#pragma mark -------------------TreeView Delegate methods
- (CGFloat)treeView:(RATreeView *)treeView heightForRowForItem:(id)item{
  return 44;
}

- (BOOL)treeView:(RATreeView *)treeView canEditRowForItem:(id)item{
  return NO;
}

// 列表展开
- (void)treeView:(RATreeView *)treeView willExpandRowForItem:(id)item{
  RATableViewCell *cell = (RATableViewCell *)[treeView cellForItem:item];
  NSInteger level = [self.treeView levelForCellForItem:item];
  [cell setAdditionButtonHidden:NO animated:YES level:level];
}

// 列表收起
- (void)treeView:(RATreeView *)treeView willCollapseRowForItem:(id)item{
  RATableViewCell *cell = (RATableViewCell *)[treeView cellForItem:item];
  NSInteger level = [self.treeView levelForCellForItem:item];
  [cell setAdditionButtonHidden:YES animated:YES level:level];
}


#pragma mark ------------------TreeView Data Source
- (UITableViewCell *)treeView:(RATreeView *)treeView cellForItem:(id)item{
  RADataObject *dataObject = item;
  if (![dataObject isKindOfClass:[RADataObject class]]) {
    dataObject = [[RADataObject alloc] init];
    [dataObject setValuesForKeysWithDictionary:item];
  }
  NSInteger level = [self.treeView levelForCellForItem:item];
  NSInteger numberOfChildren = [dataObject.children count];
  NSString *detailText = [NSString localizedStringWithFormat:@"Number of children %@", [@(numberOfChildren) stringValue]];
  BOOL expanded = [self.treeView isCellForItemExpanded:item];
  RATableViewCell *cell = [self.treeView dequeueReusableCellWithIdentifier:NSStringFromClass([RATableViewCell class])];
  [cell setupWithTitle:dataObject.name detailText:detailText level:level additionButtonHidden:!expanded updownButtonHidden:dataObject.children.count==0?YES:NO];
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
  return cell;
}


- (NSInteger)treeView:(RATreeView *)treeView numberOfChildrenOfItem:(id)item{
  if (item == nil) {
    return [self.data count];
  }
  RADataObject *data = item;
  if (![data isKindOfClass:[RADataObject class]]) {
    data = [[RADataObject alloc] init];
    [data setValuesForKeysWithDictionary:item];
  }
  return [data.children count];
}


- (id)treeView:(RATreeView *)treeView child:(NSInteger)index ofItem:(id)item{
  RADataObject *data = item;
  if (![data isKindOfClass:[RADataObject class]]) {
    data = [[RADataObject alloc] init];
    [data setValuesForKeysWithDictionary:item];
  }
  if (item == nil) {
    return [self.data objectAtIndex:index];
  }
  return data.children[index];
}


#pragma mark -----------------Helpers
- (void)loadData{
  NSArray *dataSource = @[
  @{@"name":@"Phones",@"children":@[
     @{@"name":@"Phone 1",@"children":@[
        @{@"name":@"Phone 1_01",@"children":@[]},
        @{@"name":@"Phone 1_02",@"children":@[]},
        @{@"name":@"Phone 1_03",@"children":@[]},
        @{@"name":@"Phone 1_04",@"children":@[]}]
       },
     @{@"name":@"Phone 2",@"children":@[]},
     @{@"name":@"Phone 3",@"children":@[]},
     @{@"name":@"Phone 4",@"children":@[]}]},
  @{@"name":@"Computers",@"children":@[
     @{@"name":@"Computer 1",@"children":@[]},
     @{@"name":@"Computer 2",@"children":@[]},
     @{@"name":@"Computer 3",@"children":@[]},]},
  @{@"name":@"Cars",@"children":@[]},
  @{@"name":@"Bikes",@"children":@[]},
  @{@"name":@"Houses",@"children":@[]},
  @{@"name":@"Flats",@"children":@[]},
  @{@"name":@"Motorbikes",@"children":@[]}];
  for (NSDictionary *dataDic in dataSource) {
    NSLog(@"==========%@",dataDic);
    RADataObject *object = [[RADataObject alloc] init];
    [object setValuesForKeysWithDictionary:dataDic];
    [self.data addObject:object];
  }
}
@end
