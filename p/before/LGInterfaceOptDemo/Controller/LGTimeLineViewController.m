//
//  LGTimeLineViewController.m
//  LGInterfaceOptDemo
//
//  Created by cooci on 2020/4/12.
//

// 一般是滚动的时候，卡顿

// 主线程，避免耗时计算

#import "LGTimeLineViewController.h"
#import "Masonry.h"
#import "TimeLineModel.h"
#import "TimeLineCell.h"
#import "YYModel.h"

#import "YYFPSLabel.h"

@interface LGTimeLineViewController ()<UITableViewDelegate,UITableViewDataSource>{
    BOOL _notStarted;
}

@property (nonatomic, strong) UITableView *timeLineTableView;
@property (nonatomic, strong) NSMutableArray<TimeLineModel *> *timeLineModels;
@property (nonatomic, strong) NSMutableArray *photos;


@property (nonatomic, strong) YYFPSLabel * label;

@end

@implementation LGTimeLineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"XXXX";
    
    [self combineUI];
    
    [self loadData];
    
    
    [self fpsDo];
}



- (void)fpsDo{
    CGRect bounds = [[UIScreen mainScreen] bounds];
    self.label = [[YYFPSLabel alloc] initWithFrame: CGRectMake(20, 20, bounds.size.width - 20 * 2, 80)];
    [self.view addSubview: self.label];
    _notStarted = true;
}






#pragma mark -- Private Method

- (void)combineUI{
    [self.view addSubview:self.timeLineTableView];
    [self.timeLineTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
        make.top.equalTo(self.view).offset(isiPhonex ? 88 : 64);
    }];
}

- (void)loadData{
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"timeLine" ofType:@"json"];
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    NSDictionary *dicJson=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    for (int i = 0; i < 30; i++) {
        for (id json in dicJson[@"data"]) {
            TimeLineModel *timeLineModel = [TimeLineModel yy_modelWithJSON:json];
            [self.timeLineModels addObject:timeLineModel];
        }
    }

    [self.timeLineTableView reloadData];
}

#pragma mark -- UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    TimeLineModel *timeLineModel = self.timeLineModels[indexPath.row];

    timeLineModel.cacheId = indexPath.row + 1;
   
    NSString *stateKey = nil;
    
    if (timeLineModel.isExpand) {
        stateKey = @"expanded";
    } else {
        stateKey = @"unexpanded";
    }
    
    TimeLineCell *cell = [[TimeLineCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    
    [cell configureTimeLineCell:timeLineModel];
    
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    
    CGFloat rowHeight = 0;
    
    for (UIView *bottomView in cell.contentView.subviews) {
        if (rowHeight < CGRectGetMaxY(bottomView.frame)) {
            rowHeight = CGRectGetMaxY(bottomView.frame);
        }
    }
    
    return rowHeight;

}

#pragma mark -- UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  self.timeLineModels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
       TimeLineCell *cell = [tableView dequeueReusableCellWithIdentifier:ResuseID];

       TimeLineModel *timeLineModel = self.timeLineModels[indexPath.row];
       [cell configureTimeLineCell:timeLineModel];
        cell.expandBlock = ^(BOOL isExpand) {
            timeLineModel.expand = isExpand;
            [tableView reloadRowsAtIndexPaths:@[indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
        };
        
       __weak typeof(self) weakSelf = self;
        cell.previewPhotosBlock = ^(NSMutableArray *icons, int i) {
            NSMutableArray *photos = [NSMutableArray array];
            weakSelf.photos = photos;
        };
    
        return cell;
}



- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (_notStarted){
        [self.label reset];
        _notStarted = NO;
    }
}


#pragma mark -- Getter and Setter

- (UITableView *)timeLineTableView{
    if (!_timeLineTableView) {
        _timeLineTableView = [[UITableView alloc] init];
        _timeLineTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _timeLineTableView.dataSource = self;
        _timeLineTableView.delegate = self;
        _timeLineTableView.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1];
        [_timeLineTableView registerClass:[TimeLineCell class] forCellReuseIdentifier:ResuseID];
    }
    return _timeLineTableView;
}

- (NSMutableArray<TimeLineModel *> *)timeLineModels{
    if (!_timeLineModels) {
        _timeLineModels = [NSMutableArray arrayWithCapacity:0];
    }
    return _timeLineModels;
}

@end
