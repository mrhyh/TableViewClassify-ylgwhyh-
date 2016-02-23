//
//  MultilevelMenu.m
//  MultilevelMenu
//
//  Created by gitBurning on 15/3/13.
//  Copyright (c) 2015年 BR. All rights reserved.
//

#import "MultilevelMenu.h"
#import "MultilevelTableViewCell.h"
#import "MJFriendGroup.h"
#import "MJFriend.h"
#import "MJHeaderView.h"
#import "MJFriendCell2TableViewCell.h"

#define kCellRightLineTag 100
#define kImageDefaultName @"tempShop"
#define kMultilevelCollectionViewCell @"MultilevelCollectionViewCell"
#define kScreenWidth [UIScreen mainScreen].bounds.size.width

#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
@interface MultilevelMenu() <MJHeaderViewDelegate>

@property(strong,nonatomic ) UITableView * leftTablew;
@property(strong,nonatomic ) UITableView * rightTablew;
@property(strong,nonatomic ) UICollectionView * rightCollection;

@property(assign,nonatomic) BOOL isReturnLastOffset;

@property (nonatomic, strong) NSArray *groups;

@end
@implementation MultilevelMenu



-(instancetype)initWithFrame:(CGRect)frame WithData:(NSArray *)data withSelectIndex:(void (^)(NSInteger, NSInteger, id))selectIndex
{
    self=[super initWithFrame:frame];
    if (self) {
        if (data.count==0) {
            return nil;
        }
        
        _block=selectIndex;
        self.leftSelectColor=[UIColor blueColor];
        self.leftSelectBgColor=[UIColor whiteColor];
        self.leftBgColor=UIColorFromRGB(0xF3F4F6);
        //self.leftBgColor=[UIColor whiteColor];
        self.leftSeparatorColor=UIColorFromRGB(0xE5E5E5);
        self.leftUnSelectBgColor=UIColorFromRGB(0xF3F4F6);
        self.leftUnSelectColor=[UIColor whiteColor];
        
        _selectIndex=0;
        _allData=data;
        
        
        /**
         左边的视图
        */
        self.leftTablew=[[UITableView alloc] initWithFrame:CGRectMake(0, 0, kLeftWidth, frame.size.height)];
        self.leftTablew.dataSource=self;
        self.leftTablew.delegate=self;
        
        self.leftTablew.tableFooterView=[[UIView alloc] init];
        [self addSubview:self.leftTablew];
        self.leftTablew.backgroundColor=self.leftBgColor;
        if ([self.leftTablew respondsToSelector:@selector(setLayoutMargins:)]) {
            self.leftTablew.layoutMargins=UIEdgeInsetsZero;
        }
        if ([self.leftTablew respondsToSelector:@selector(setSeparatorInset:)]) {
            self.leftTablew.separatorInset=UIEdgeInsetsZero;
        }
        self.leftTablew.separatorColor=self.leftSeparatorColor;
        
        
        /**
         右边的视图
         */
        
        float leftMargin =0;
//        self.rightTablew=[[UITableView alloc] initWithFrame:CGRectMake(kLeftWidth+leftMargin,0,kScreenWidth-kLeftWidth-leftMargin*2,frame.size.height)];
        self.rightTablew=[[UITableView alloc] initWithFrame:CGRectMake(kLeftWidth+leftMargin,0,kScreenWidth-kLeftWidth-leftMargin*2,frame.size.height)];
        NSLog(@"%f",kScreenWidth-kLeftWidth-leftMargin*2);
        
        self.rightTablew.delegate=self;
        self.rightTablew.dataSource=self;
        
        // 每一行cell的高度
        self.rightTablew.rowHeight = 42;
        // 每一组头部控件的高度
        self.rightTablew.sectionHeaderHeight = 42;
        self.rightTablew.backgroundColor=[UIColor whiteColor];
        
        [self addSubview:_rightTablew];
        
        self.isReturnLastOffset=YES;
        self.backgroundColor=self.leftSelectBgColor;
        //self.backgroundColor=[UIColor whiteColor];
    }
    return self;
}

-(void)setNeedToScorllerIndex:(NSInteger)needToScorllerIndex{
    
        /**
         *  滑动到 指定行数
         */
        [self.leftTablew selectRowAtIndexPath:[NSIndexPath indexPathForRow:needToScorllerIndex inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];

        _selectIndex=needToScorllerIndex;
        
        [self.rightTablew reloadData];

    _needToScorllerIndex=needToScorllerIndex;
}
-(void)setLeftBgColor:(UIColor *)leftBgColor{
    _leftBgColor=leftBgColor;
    self.leftTablew.backgroundColor=leftBgColor;
   
}
-(void)setLeftSelectBgColor:(UIColor *)leftSelectBgColor{
    
    _leftSelectBgColor=leftSelectBgColor;
    self.rightTablew.backgroundColor=leftSelectBgColor;
    
    self.backgroundColor=leftSelectBgColor;
}
-(void)setLeftSeparatorColor:(UIColor *)leftSeparatorColor{
    _leftSeparatorColor=leftSeparatorColor;
    self.leftTablew.separatorColor=leftSeparatorColor;
}
-(void)reloadData{
    
    [self.leftTablew reloadData];
    [self.rightTablew reloadData];
    
}
-(void)setLeftTablewCellSelected:(BOOL)selected withCell:(MultilevelTableViewCell*)cell
{
    UILabel * line=(UILabel*)[cell viewWithTag:kCellRightLineTag];
    if (selected) {
        
        line.backgroundColor=cell.backgroundColor;
        cell.titile.textColor=self.leftSelectColor;
        cell.backgroundColor=self.leftSelectBgColor;
    }
    else{
        
        cell.titile.textColor=self.leftUnSelectColor;
        cell.backgroundColor=self.leftUnSelectBgColor;
        line.backgroundColor=_leftTablew.separatorColor;
    }
   

}

#pragma mark---左边的tablew 代理
#pragma mark--deleagte
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if(_leftTablew == tableView){
        return 1;
    }else {
        return self.groups.count;;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    
    if(_leftTablew == tableView){
        
        return self.allData.count;
    }else {
        //return (self.allData.count>0 ? self.allData.count : 1);
        MJFriendGroup *group = self.groups[section];
        return (group.isOpened ? group.friends.count : 0);
    }
   
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    if(_leftTablew == tableView){
        
        static NSString * Identifier=@"MultilevelTableViewCell";
        MultilevelTableViewCell * cell=[tableView dequeueReusableCellWithIdentifier:Identifier];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        
        if (!cell) {
            cell=[[NSBundle mainBundle] loadNibNamed:@"MultilevelTableViewCell" owner:self options:nil][0];
            
            UILabel * label=[[UILabel alloc] initWithFrame:CGRectMake(kLeftWidth-0.5, 0, 0.5, 44)];
            label.backgroundColor=tableView.separatorColor;
            [cell addSubview:label];
            label.tag=kCellRightLineTag;
        }
        
        
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        rightMeun * title=self.allData[indexPath.row];
        
        cell.titile.text=title.meunName;
        
        
        if (indexPath.row==self.selectIndex) {
            NSLog(@"设置点中");
            [self setLeftTablewCellSelected:YES withCell:cell];
        }
        else{
            [self setLeftTablewCellSelected:NO withCell:cell];
            
            NSLog(@"设置不点中");
            
        }
        
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
            cell.layoutMargins=UIEdgeInsetsZero;
        }
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            cell.separatorInset=UIEdgeInsetsZero;
        }
        
        return cell;
    }else {
        
        // 1.创建cell
        MJFriendCell2TableViewCell *cell = [MJFriendCell2TableViewCell cellWithTableView:tableView];
        cell.indicatorBtn.tag = indexPath.row;
        // 2.设置cell的数据
        MJFriendGroup *group = self.groups[indexPath.section];
        cell.friendData = group.friends[indexPath.row];
        //[cell.indicatorBtn setImage:[UIImage imageNamed:@"code"] forState:UIControlStateNormal];
        return cell;
        
    }
    
}

/**
 *  返回每一组需要显示的头部标题(字符出纳)
 */
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    // 1.创建头部控件
    MJHeaderView *header = [MJHeaderView headerViewWithTableView:tableView identifierWithString:[NSString stringWithFormat:@"identifier%ld",(long)section]];
    header.tag = section;
    header.indicatorBtn.tag = section;
    //header.backgroundColor = [UIColor redColor];
    header.delegate = self;
    
    // 2.给header设置数据(给header传递模型)
    header.group = self.groups[section];
    
    return header;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 42;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(self.leftTablew == tableView){
        MultilevelTableViewCell * cell=(MultilevelTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
        
        //    MultilevelTableViewCell * BeforeCell=(MultilevelTableViewCell*)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathWithIndex:_selectIndex]];
        //
        //    [self setLeftTablewCellSelected:NO withCell:BeforeCell];
        _selectIndex=indexPath.row;
        
        [self setLeftTablewCellSelected:YES withCell:cell];
        
        rightMeun * title=self.allData[indexPath.row];
        
        [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        
        self.isReturnLastOffset=NO;
        
        [self.rightTablew reloadData];
        
        
        if (self.isRecordLastScroll) {
            [self.rightTablew scrollRectToVisible:CGRectMake(0, title.offsetScorller, self.rightTablew.frame.size.width, self.rightTablew.frame.size.height) animated:self.isRecordLastScrollAnimated];
        }
        else{
            
            [self.rightTablew scrollRectToVisible:CGRectMake(0, 0, self.rightTablew.frame.size.width, self.rightTablew.frame.size.height) animated:self.isRecordLastScrollAnimated];
        }

    }else{
        //NSLog(@"rightTableView.indexPath%ld",(long)indexPath.row);
        NSLog(@"rightTableCellSelect...");
    }
    

}


-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(self.leftTablew == tableView){
        MultilevelTableViewCell * cell=(MultilevelTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
        //    cell.titile.textColor=self.leftUnSelectColor;
        //    UILabel * line=(UILabel*)[cell viewWithTag:100];
        //    line.backgroundColor=tableView.separatorColor;
        
        [self setLeftTablewCellSelected:NO withCell:cell];
        
        cell.backgroundColor=self.leftUnSelectBgColor;

    }else{
        NSLog(@"rightTableViewCellDidSelect...");
    }
}

#pragma mark---记录滑动的坐标
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([scrollView isEqual:self.rightTablew]) {

        
        self.isReturnLastOffset=YES;
    }
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if ([scrollView isEqual:self.rightTablew]) {
        
        rightMeun * title=self.allData[self.selectIndex];
        
        title.offsetScorller=scrollView.contentOffset.y;
        self.isReturnLastOffset=NO;
        
    }

 }

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if ([scrollView isEqual:self.rightTablew]) {
        
        rightMeun * title=self.allData[self.selectIndex];
        
        title.offsetScorller=scrollView.contentOffset.y;
        self.isReturnLastOffset=NO;
        
    }

}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if ([scrollView isEqual:self.rightTablew] && self.isReturnLastOffset) {
        rightMeun * title=self.allData[self.selectIndex];
        
        title.offsetScorller=scrollView.contentOffset.y;

        
    }
}



#pragma mark--Tools
-(void)performBlock:(void (^)())block afterDelay:(NSTimeInterval)delay{
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), block);
}


- (NSArray *)groups
{
    if (_groups == nil) {
        NSArray *dictArray = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"friends.plist" ofType:nil]];
        
        NSMutableArray *groupArray = [NSMutableArray array];
        for (NSDictionary *dict in dictArray) {
            MJFriendGroup *group = [MJFriendGroup groupWithDict:dict];
            [groupArray addObject:group];
        }
        
        _groups = groupArray;
    }
    return _groups;
}


- (BOOL)prefersStatusBarHidden
{
    return YES;
}


#pragma mark - headerView的代理方法

/**
 *  点击了headerView上面的名字按钮时就会调用
 */
- (void)headerViewDidClickedNameView:(MJHeaderView *)headerView
{
    [self.rightTablew reloadData];
}






@end

@implementation rightMeun

@end
