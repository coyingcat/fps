//
//  LGTimeLineViewController.m
//  LGInterfaceOptDemo
//
//  Created by cooci on 2020/4/12.
//

#import "LGTimeLineViewController.h"
#import "Masonry.h"
#import "TimeLineModel.h"
#import "TimeLineCell.h"
#import "TimeLineCellLayout.h"
#import "YYModel.h"

#import "YYFPSLabel.h"
@interface LGTimeLineViewController ()<UITableViewDelegate,UITableViewDataSource>{
    BOOL _notStarted;
}

@property (nonatomic, strong) UITableView *timeLineTableView;
@property (nonatomic, strong) NSMutableArray<TimeLineModel *> *timeLineModels;
@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSMutableArray<TimeLineCellLayout *> *layouts;



@property (nonatomic, strong) YYFPSLabel * label;

@end

@implementation LGTimeLineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"我的动态";
    
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
   //外面的异步线程：网络请求的线程
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
           //加载`JSON 文件`
              NSString *path = [[NSBundle mainBundle] pathForResource:@"timeLine" ofType:@"json"];
              NSData *data = [[NSData alloc] initWithContentsOfFile:path];
              NSDictionary *dicJson=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            for (int i = 0; i < 30; i++) {
                for (id json in dicJson[@"data"]) {
                    TimeLineModel *timeLineModel = [TimeLineModel yy_modelWithJSON:json];
                    [self.timeLineModels addObject:timeLineModel];
                }
            }
              
           
               for (TimeLineModel *timeLineModel in self.timeLineModels) {
                   TimeLineCellLayout *cellLayout = [[TimeLineCellLayout alloc] initWithModel:timeLineModel];
                   [self.layouts addObject:cellLayout];
               }
           
               dispatch_async(dispatch_get_main_queue(), ^{
                    [self.timeLineTableView reloadData];
               });

       });
}

#pragma mark -- UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return  self.layouts[indexPath.row].height;
}

#pragma mark -- UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
     return  self.layouts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
       TimeLineCell *cell = [tableView dequeueReusableCellWithIdentifier:ResuseID];

       [cell configureLayout:self.layouts[indexPath.row]];
        cell.expandBlock = ^(BOOL isExpand) {
            TimeLineModel *timeLineModel = self.layouts[indexPath.row].timeLineModel;
            timeLineModel.expand = !isExpand;
            self.layouts[indexPath.row].timeLineModel = timeLineModel;
            [tableView reloadRowsAtIndexPaths:@[indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
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

- (NSMutableArray<TimeLineCellLayout *> *)layouts{
    if (!_layouts) {
        _layouts = [NSMutableArray arrayWithCapacity:0];
    }
    return _layouts;
}

@end
