//
//  RBSplitViewController.m
//  RedBullself.Drive3
//
//  Created by Duarte Lopes on 03/06/13.
//  Copyright (c) 2013 NOUS. All rights reserved.
//

#import "RBSplitViewController.h"
#import "RBMenuViewHelper.h"
#import "RBDayCalendarViewController.h"
#import "RBWeekCalendarViewController.h"
#import "RBMonthCalendarViewController.h"
#import "RBCalendarViewController.h"
#import "RBImageSubtitleCell.h"
#import "RBDayCalendarAuditCell.h"
#import "RBWeekCalendarCell.h"
#import "RBMonthCalendarCell.h"
#import "AUDAuditHelper.h"
#import "RBConstants.h"
#import "RBCalendarEntryViewController.h"
#import "RBWeekCalendarDayHeaderView.h"
#import "MSTStoreHelper.h"
#import "CUSQuestionnaireHelper.h"

#define kRBScrollAreaHeight 40.f
#define kRBScrollSpeed 10.f

@interface RBSplitViewController (){
    CGRect convertedDetailCalendarRect;
    AUDAudit *newAudit;
}

@property (nonatomic, strong) UILongPressGestureRecognizer *longPress;

@property (nonatomic) CGPoint originCellOriginPoint;
@property (nonatomic, strong) UIImageView *draggedCell;
@property (nonatomic) CGPoint priorPoint;
@property (nonatomic) CGPoint clickedPoint;

// week variables
@property (nonatomic, strong) UITableView *selectedDayTableViewOfWeekCalendar;

@property (nonatomic, strong) UIView *intersectedCell;
@property (nonatomic, readwrite) NSUInteger indexOfSelectedCell;
@property (nonatomic, readwrite) BOOL inDrag;

@property (nonatomic, strong) RBDayCalendarAuditCell *draggedDayCellTemplate;
@property (nonatomic, strong) RBWeekCalendarCell *draggedWeekCellTemplate;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) RBWeekCalendarCell *theCopyWeekCell;

@property (nonatomic, readwrite) NSInteger originalCopyWeekCellTableTagSaved;

@property (nonatomic, readwrite) NSArray *topLevelObjects;

@property (nonatomic, strong) NSDate *savedAuditDateInWeekView; //save the dragged weekCell audit date for repost if, for example is dropped in a past position and not accepted

@end

@implementation RBSplitViewController

RBImageSubtitleCell *copyCell;

BOOL isDraggedCellIntersectedWithDetailCalendar;
BOOL hasBlankCell;
BOOL canDragWeekCell;

NSInteger copyWeekCellRow;
NSInteger copyWeekCellTableTag;
NSInteger originalCopyWeekCellRow;

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark - Lifecycle methods
////////////////////////////////////////////////////////////////////////

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
    self.view.backgroundColor = [UIColor blackColor];
    
    self.longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    self.longPress.minimumPressDuration = 0.2f;
    [self.view addGestureRecognizer:self.longPress];
    isDraggedCellIntersectedWithDetailCalendar = NO;
    hasBlankCell = NO;
    
    if (IS_IOS7_AND_GREATER) {
        [self setNeedsStatusBarAppearanceUpdate];
    }
}

- (void)viewDidUnload{
    [super viewDidUnload];
}

-(void)viewWDidAppear:(BOOL)animated{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark - UI change methods
////////////////////////////////////////////////////////////////////////


- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


- (void)moveRowFrom:(NSIndexPath*)fromRow toRow:(NSIndexPath*)toRow inSourceIndex:(NSInteger)index {
    
    if([self getCurrentCalendarType] == RBCalendarDetailDay) {
        [[self getDayTableView] moveRowAtIndexPath:fromRow toIndexPath:toRow];
        [self setCorrectOrderForDayCells];
    } else if([self getCurrentCalendarType] == RBCalendarDetailWeek) {

        [[[self getWeekTableViews] objectAtIndex:index] reloadData];
        
        [[[self getWeekTableViews] objectAtIndex:index] moveRowAtIndexPath:fromRow toIndexPath:toRow];
        [self setCorrectCellsStylesForWeekCellsAtSourceIndex:index];
    }
}

- (void)addNewRowTo:(NSIndexPath*)toIndexPath inSourceIndex:(NSInteger)index{

    if([self getCurrentCalendarType] == RBCalendarDetailDay) {
        [[self getDayTableView] beginUpdates];
        
        [[self getDayTableView] insertRowsAtIndexPaths:[NSArray arrayWithObject:toIndexPath] withRowAnimation:UITableViewRowAnimationNone];
        [[self getDayTableView] endUpdates];
        
        [self setCorrectOrderForDayCells];
    } else if([self getCurrentCalendarType] == RBCalendarDetailWeek) {
    
        UITableView *currentlySelectedTable = [[self getWeekTableViews] objectAtIndex:index];
        
        [currentlySelectedTable beginUpdates];
        [currentlySelectedTable insertRowsAtIndexPaths:[NSArray arrayWithObject:toIndexPath] withRowAnimation:UITableViewRowAnimationNone];
        [currentlySelectedTable endUpdates];
        
        [self setCorrectCellsStylesForWeekCellsAtSourceIndex:currentlySelectedTable.tag];
    }
}

- (void)removeRowIn:(NSIndexPath*)indexPath inSourceIndex:(NSInteger)sourceIndex {
    
    if([self getCurrentCalendarType] == RBCalendarDetailDay) {
        
        [[self getDayTableView] beginUpdates];
        [[self getDayTableView] deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
        [[self getDayTableView] endUpdates];
        
        [self setCorrectOrderForDayCells];
    } else if([self getCurrentCalendarType] == RBCalendarDetailWeek) {
        
        UITableView *selectedWeekTable = [[self getWeekTableViews] objectAtIndex:sourceIndex];

        [selectedWeekTable beginUpdates];
        [selectedWeekTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
        [selectedWeekTable endUpdates];

        [self setCorrectCellsStylesForWeekCellsAtSourceIndex:sourceIndex];
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark - GestureRecognizer methods
////////////////////////////////////////////////////////////////////////

- (IBAction)longPress:(UIGestureRecognizer *)sender {
    self.clickedPoint = [sender locationInView:self.view];
    
    RBMenuViewHelper *menuViewHelper = [RBMenuViewHelper sharedManager];


    if (sender.state == UIGestureRecognizerStateBegan && !self.inDrag) {

        if([self getCurrentCalendarType] == RBCalendarDetailDay) {
            // tableView
            convertedDetailCalendarRect = [self.view convertRect:[self getDayTableView].frame fromView:[self getDayTableView].superview];
        } else if([self getCurrentCalendarType] == RBCalendarDetailWeek) {
            
            // tableView
            UIView *weekCalendarView = [self getWeekCalendarView];
            convertedDetailCalendarRect = [self.view convertRect:weekCalendarView.frame fromView:weekCalendarView.superview];
        } else if([self getCurrentCalendarType] == RBCalendarDetailMonth){
            // collectionView
            UICollectionView *monthCollectionView = [self getMonthCollectionView];
            convertedDetailCalendarRect = [self.view convertRect:monthCollectionView.frame fromView:monthCollectionView.superview];
        }
        
        
        // get storeList View
        RBStoreListViewController *storeListViewController = (RBStoreListViewController*)menuViewHelper.masterViewController;
        UITableView *selectedTable = storeListViewController.storesTableView;
        
        // get most down subView user clicked
        UIView *clickedSubView = [self.view hitTest:self.clickedPoint withEvent:nil];
        
        // convert both Views
        CGRect convertedStoreList = [self.view convertRect:selectedTable.frame fromView:selectedTable.superview];
        
        UIImage *aCellImage;

        //check if longPress inside storeList
        if( CGRectContainsPoint(convertedStoreList, self.clickedPoint) ) {

            NSIndexPath *indexPath = [selectedTable indexPathForRowAtPoint:[sender locationInView:selectedTable]];
            if (!indexPath) {
                return;
            }
            
            MSTStore *existentStore = [storeListViewController getStoreAtIndex:indexPath];
            NSArray *openAudits = [AUDAuditHelper getOpenAuditsForStore:existentStore];
            if(openAudits.count > 0){
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"StoreAlreadyScheduled",nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK",nil), nil];
                [alert show];
                return;
            }
            
            newAudit = [self createBlankAudit];
            
            // load day dragged cells
            if(!self.draggedDayCellTemplate) {
                
                // needed to create a day cell .xib
                NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:[RBDayCalendarAuditCell identifierAndNibName] owner:self options:nil];
                self.draggedDayCellTemplate = [topLevelObjects objectAtIndex:0];
            }
            
            // load week dragged cells
            if(!self.draggedWeekCellTemplate) {
                NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:[RBWeekCalendarCell identifierAndNibName] owner:self options:nil];
                self.draggedWeekCellTemplate = [topLevelObjects objectAtIndex:0];
                self.draggedWeekCellTemplate.deleteButton.hidden = YES;
            }
            
            self.inDrag = YES;
            [self.splitDelegate enableSegmentedControl:NO];
            
            // copy cell from storeListVC
            copyCell = (RBImageSubtitleCell*)[selectedTable cellForRowAtIndexPath:indexPath];
            
            self.originCellOriginPoint = [self.view convertPoint:CGPointZero fromView:copyCell];
            
            if(![copyCell isSelected]) {
                [selectedTable selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
                [selectedTable.delegate tableView:selectedTable didSelectRowAtIndexPath:indexPath];
            }
            
            self.theCopyWeekCell = nil;
            copyWeekCellRow = -1;
            copyWeekCellTableTag = -1;
            aCellImage = copyCell.fkit_imageRepresentation;
            
            //load data to new audit
            MSTStore *curStore = [storeListViewController getStoreAtIndex:indexPath];
            
            newAudit.storeGuid = curStore.id ; //newStore;
            newAudit.questionnaire = [CUSQuestionnaireHelper getQuestionnairesForStore:curStore].firstObject;
            newAudit.auditType = @"";

        } else {
            
            BOOL isInsideWeekCell = NO;     // check if longPress inside a weekCell
            if (IS_IOS7_AND_GREATER) {
                if([clickedSubView.superview.superview isKindOfClass:[RBWeekCalendarCell class]]) {
                    isInsideWeekCell = YES;
                }
            } else {
                if([clickedSubView.superview isKindOfClass:[RBWeekCalendarCell class]]) {
                    isInsideWeekCell = YES;
                }
            }
            
            if(!canDragWeekCell || !isInsideWeekCell) {
                return;
            }
            
            UITableView *selectedTableInWeekCalendar;
            if (IS_IOS7_AND_GREATER) {
                selectedTableInWeekCalendar = (UITableView*)clickedSubView.superview.superview.superview.superview;
            } else {
                selectedTableInWeekCalendar = (UITableView*)clickedSubView.superview.superview;    // tableView
            }
            
            NSIndexPath *indexPath = [selectedTableInWeekCalendar indexPathForRowAtPoint:[sender locationInView:selectedTableInWeekCalendar]];
            if (!indexPath) {
                return;
            }
            
            // load week dragged cell
            if(!self.draggedWeekCellTemplate) {
                self.topLevelObjects = [[NSBundle mainBundle] loadNibNamed:[RBWeekCalendarCell identifierAndNibName] owner:self options:nil];
                self.draggedWeekCellTemplate = [self.topLevelObjects objectAtIndex:0];
            }
            
            self.inDrag = YES;
            [self.splitDelegate enableSegmentedControl:NO];
            
            self.theCopyWeekCell = (RBWeekCalendarCell*)[selectedTableInWeekCalendar cellForRowAtIndexPath:indexPath];
            self.originCellOriginPoint = [self.view convertPoint:CGPointZero fromView:self.theCopyWeekCell];
            
            newAudit = self.theCopyWeekCell.audit;
            

            //save current audit date before changing - in case is needed to put it back if audit new position is not accepted (e.g. dragging to a past date)
            self.savedAuditDateInWeekView = newAudit.dateFrom;
            

            // check if is past
            if([newAudit.auditStatus isEqualToString:AUDAUDIT_STATUS_COMPLETED]) {
                self.inDrag = NO;
                return;
            }
            
            copyCell = nil;
            aCellImage = self.theCopyWeekCell.fkit_imageRepresentation;
            
            copyWeekCellRow = indexPath.row;
            originalCopyWeekCellRow = indexPath.row;
            copyWeekCellTableTag = selectedTableInWeekCalendar.tag;
            self.originalCopyWeekCellTableTagSaved = selectedTableInWeekCalendar.tag;
        }

        self.draggedCell = nil;
        self.draggedCell = [[UIImageView alloc] initWithImage:aCellImage];
        self.draggedCell.frame = CGRectMake(self.originCellOriginPoint.x, self.originCellOriginPoint.y, self.draggedCell.frame.size.width, self.draggedCell.frame.size.height);
        self.draggedCell.layer.masksToBounds = NO;
        self.draggedCell.layer.cornerRadius = 2.0;
        self.draggedCell.layer.shadowOffset = CGSizeMake(-5, 5);
        self.draggedCell.layer.shadowRadius = 2.0;
        self.draggedCell.layer.shadowOpacity = 0.6;
        self.draggedCell.alpha = 0.7f;
        [self.view addSubview:self.draggedCell];
        [self.view bringSubviewToFront:self.draggedCell];

    } else if(sender.state == UIGestureRecognizerStateChanged && self.inDrag) {
        
        // we dragged it, so let's update the coordinates of the dragged view
        CGPoint center = self.draggedCell.center;
        center.x += self.clickedPoint.x - self.priorPoint.x;
        center.y += self.clickedPoint.y - self.priorPoint.y;
        self.draggedCell.center = center;
        
        //reset intersectedCell              
        self.intersectedCell.layer.borderWidth = 0.f;
        self.intersectedCell.tag = 0;
        
        // convert frames to this view
        CGFloat oldDraggedCellFrameHeight = self.draggedCell.frameHeight;
        CGFloat oldDraggedCellFrameOriginY = self.draggedCell.frameOrigin.y;
        CGFloat oldDraggedCellFrameWidth = self.draggedCell.frameWidth;
        CGFloat oldDraggedCellFrameOriginX = self.draggedCell.frameOrigin.x;
        
//      1. test intersection with tableView/collectionView - transform to old/new cells
        if( CGRectContainsPoint(convertedDetailCalendarRect, self.clickedPoint) ) {

            //if intersected with tableView/Collection
            if(!isDraggedCellIntersectedWithDetailCalendar) {
                UITableViewCell *cell;
                
                switch ([self getCurrentCalendarType]) {
                        
                    case RBCalendarDetailDay:
                    {
                        [self.draggedDayCellTemplate setupWithAudit:newAudit order:0];
                        cell = self.draggedDayCellTemplate;
                    }
                    break;
                        
                    case RBCalendarDetailWeek:
                    {
                        [self.draggedWeekCellTemplate setupWithAudit:newAudit order:nil style:RBWeekCalendarCellStyleSingle];
                        cell = self.draggedWeekCellTemplate;
                    }
                    break;
                        
                    case RBCalendarDetailMonth:
                    {
                        //
                    }
                    break;
                        
                    default:
                        break;
                }
                
                // fade into new cell in case of intersection with detailCalendarView - only for day and week views
                if( [self getCurrentCalendarType] == RBCalendarDetailDay || ( [self getCurrentCalendarType] == RBCalendarDetailWeek && copyCell) ) {
                    
                    FKLogInfo(@"Fade Into new cell Look: %@", self.draggedCell);
                    
                    [UIView transitionWithView:self.draggedCell
                                      duration:0.2f
                                       options:UIViewAnimationOptionTransitionCrossDissolve
                                    animations:^{
                                        self.draggedCell.frameSize = cell.frameSize;
                                        
                                        CGPoint correctPointClickedInNewCell = self.draggedCell.frameOrigin;
                                        //only proportionally translate if the new frame is smaller in height or width
                                        if(oldDraggedCellFrameHeight > self.draggedCell.frameHeight) {
                                            correctPointClickedInNewCell.y = self.clickedPoint.y - ((self.clickedPoint.y - oldDraggedCellFrameOriginY)/oldDraggedCellFrameHeight * self.draggedCell.frameHeight);
                                        }
                                        if(oldDraggedCellFrameWidth > self.draggedCell.frameWidth) {
                                            correctPointClickedInNewCell.x = self.clickedPoint.x - ((self.clickedPoint.x - oldDraggedCellFrameOriginX)/oldDraggedCellFrameWidth * self.draggedCell.frameWidth);
                                        }
                                        self.draggedCell.frameOrigin = correctPointClickedInNewCell;
                                        self.draggedCell.image = cell.fkit_imageRepresentation;
                                        isDraggedCellIntersectedWithDetailCalendar = YES;
                                    }
                                    completion:^(BOOL finished){}
                     ];
                } else {
                    isDraggedCellIntersectedWithDetailCalendar = YES;
                }
            }
        } else {
            
            if(isDraggedCellIntersectedWithDetailCalendar) {
                // fade into old cell in case of NON intersection with detailCalendarView - only for day and week views
                if([self getCurrentCalendarType] == RBCalendarDetailDay || ( [self getCurrentCalendarType] == RBCalendarDetailWeek && copyCell) ) {
                    [UIView transitionWithView:self.draggedCell
                                      duration:0.2f
                                       options:UIViewAnimationOptionTransitionCrossDissolve
                                    animations:^{
                                        self.draggedCell.frameSize = copyCell.frameSize;
                                        CGPoint correctPointClickedInNewCell = self.draggedCell.frameOrigin;
                                        //only proportionally translate if the new frame is smaller in height or width
                                        if(self.draggedCell.frameHeight > oldDraggedCellFrameHeight) {
                                            correctPointClickedInNewCell.y = self.clickedPoint.y - ((self.clickedPoint.y - oldDraggedCellFrameOriginY)/oldDraggedCellFrameHeight * self.draggedCell.frameHeight);
                                        }
                                        if(self.draggedCell.frameWidth > oldDraggedCellFrameWidth) {
                                            correctPointClickedInNewCell.x = self.clickedPoint.x - ((self.clickedPoint.x - oldDraggedCellFrameOriginX)/oldDraggedCellFrameWidth * self.draggedCell.frameWidth);
                                        }
                                        self.draggedCell.frameOrigin = correctPointClickedInNewCell;
                                        self.draggedCell.image = copyCell.fkit_imageRepresentation;
                                        isDraggedCellIntersectedWithDetailCalendar = NO;
                                    } completion:^(BOOL finished){}
                     ];
                } else {
                    isDraggedCellIntersectedWithDetailCalendar = NO;
                }
            }
        }

//      2. Test intersection with cells
        [self testCellsIntersections];

    } else if ((sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateCancelled || sender.state == UIGestureRecognizerStateFailed) && self.inDrag) {
        
        // we dropped, so remove draggedCell it from the view
        self.intersectedCell.layer.borderWidth = 0.f;
        isDraggedCellIntersectedWithDetailCalendar = NO;
        [self resetTimer];
        
        
        // Check if drop is in the Past
        BOOL cellDropIsPast = [self checkIfDropIsInPast];
        

        // if has intersection add to tableView/collectionView
        if(self.intersectedCell.tag && !cellDropIsPast) {

            //check for dragged week cells intersections
            if(self.theCopyWeekCell) {

                    CGRect convertedCellRect = [self.view convertRect:self.intersectedCell.frame fromView:self.intersectedCell.superview];
                    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                        self.draggedCell.frame = CGRectMake(convertedCellRect.origin.x, convertedCellRect.origin.y, self.draggedCell.frameWidth, self.draggedCell.frameHeight);
                    } completion:^(BOOL finished) {
                        
                        if(self.originalCopyWeekCellTableTagSaved == self.selectedDayTableViewOfWeekCalendar.tag) {

                            // only move
                            NSIndexPath *fromIndexPath = [NSIndexPath indexPathForRow:originalCopyWeekCellRow inSection:0];
                            [[self getCalendarViewController] saveDirectlyEditModeFrom:self withAudit:newAudit fromIndexPath:fromIndexPath editMode:0];
                            
                        } else {
                            
                            newAudit.dateFrom = [[self getCalendarViewController].detailViewController.firstDisplayDate fkit_dateByAddingDays:self.originalCopyWeekCellTableTagSaved];
                            [[self getCalendarViewController] saveDirectlyEditModeFrom:self withAudit:newAudit fromIndexPath:nil editMode:1];

                        }

                        [self.draggedCell removeFromSuperview];
                        self.inDrag = NO;
                        hasBlankCell = NO;
                        self.intersectedCell = nil;
                        isDraggedCellIntersectedWithDetailCalendar = NO;
                        
                        //refresh RBBaseMixViewController - in case is showing
                        [[self getCalendarViewController] refreshShowMixData];
                    }];

            } else {

                CGRect convertedCellRect = [self.view convertRect:self.intersectedCell.frame fromView:self.intersectedCell.superview];
                [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    self.draggedCell.frame = CGRectMake(convertedCellRect.origin.x, convertedCellRect.origin.y, self.draggedCell.frameWidth, self.draggedCell.frameHeight);
                } completion:^(BOOL finished) {
                    
                    // reset dateFrom because it´s a newAudit, it shouldn´t have a dateFrom
                    newAudit.dateFrom = nil;
            
                    [[self getCalendarViewController]saveDirectlyFrom:self withAudit:newAudit];

                    [self.draggedCell removeFromSuperview];
                    self.inDrag = NO;
                    hasBlankCell = NO;
                    self.intersectedCell = nil;
                    isDraggedCellIntersectedWithDetailCalendar = NO;
                    
                    //refresh RBBaseMixViewController - in case is showing
                    [[self getCalendarViewController] refreshShowMixData];
                }];
            }
        } else {     // go back to initial position
            
            //check for dragged week cells
            if(self.theCopyWeekCell) {

                    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                        self.draggedCell.frame = CGRectMake(self.originCellOriginPoint.x, self.originCellOriginPoint.y, self.draggedCell.frameWidth, self.draggedCell.frameHeight);
                        
                    } completion:^(BOOL finished) {
                        
                        [self.draggedCell removeFromSuperview];
                        self.inDrag = NO;
                        hasBlankCell = NO;
                        self.intersectedCell = nil;
                        isDraggedCellIntersectedWithDetailCalendar = NO;
                        
                        // set back to the first date before starting to dragging
                        newAudit.dateFrom = self.savedAuditDateInWeekView;
                        
                        RBWeekCalendarViewController *weekCalendarController = (RBWeekCalendarViewController*)[self getCalendarViewController].detailViewController;
                        [weekCalendarController loadData];
                    }];
           
            } else {    // for copyCell
                
                [AUDAuditHelper deleteAUDAudit:newAudit];
                
                [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    self.draggedCell.frame = CGRectMake(self.originCellOriginPoint.x, self.originCellOriginPoint.y, self.draggedCell.frameWidth, self.draggedCell.frameHeight);
                    
                } completion:^(BOOL finished) {
                    
                    [self.draggedCell removeFromSuperview];
                    self.inDrag = NO;
                    hasBlankCell = NO;
                    self.intersectedCell = nil;
                    isDraggedCellIntersectedWithDetailCalendar = NO;
                    
                    
                    // Must reload data sources
                    if([self getCurrentCalendarType] == RBCalendarDetailDay) {
                        
                        RBDayCalendarViewController *dayCalendarController = (RBDayCalendarViewController*)[self getCalendarViewController].detailViewController;
                        [dayCalendarController loadData];
                    } else if ([self getCurrentCalendarType] == RBCalendarDetailWeek) {
                        
                        if([self getCurrentCalendarType] == RBCalendarDetailWeek){
                            RBWeekCalendarViewController *weekCalendarController = (RBWeekCalendarViewController*)[self getCalendarViewController].detailViewController;
                            [weekCalendarController loadData];
                        }
                    }

                }];
            }
        }
        [self.splitDelegate enableSegmentedControl:YES];
    }
 
//  3. Test if clicked point near the bottom or top of the tableView and scroll according
    if(isDraggedCellIntersectedWithDetailCalendar) {
        
        CGFloat areaToStartScroll = kRBScrollAreaHeight;
        
        //specific case for week CalendarView Top
        if([self getCurrentCalendarType] == RBCalendarDetailWeek) {
            areaToStartScroll = kRBScrollAreaHeight + 40.0;
        }

        if(self.clickedPoint.y > (convertedDetailCalendarRect.origin.y + convertedDetailCalendarRect.size.height - kRBScrollAreaHeight)) {  // check near bottom

            if(!self.timer) {
                self.timer = [NSTimer scheduledTimerWithTimeInterval:0.03 target:self selector:@selector(scrollDown:) userInfo:nil repeats:YES];

            }
        } else if(self.clickedPoint.y < (convertedDetailCalendarRect.origin.y + areaToStartScroll /*kRBScrollAreaHeight*/)) {     //check near top
            
            if(!self.timer) {
                
                UITableView *auxTableView;
                if([self getCurrentCalendarType] == RBCalendarDetailDay) {
                    auxTableView = [self getDayTableView];
                } else if( [self getCurrentCalendarType] == RBCalendarDetailWeek) {
                    auxTableView = self.selectedDayTableViewOfWeekCalendar;
                }
                
                if(auxTableView.contentOffset.y != 0) {
                    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.03 target:self selector:@selector(scrollUp:) userInfo:nil repeats:YES];
                }
            }
        } else {
            [self resetTimer];
        } 
    } else {
        [self resetTimer];
    }

    self.priorPoint = self.clickedPoint;
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark - getters from calendarViewController methods
////////////////////////////////////////////////////////////////////////

- (enum RBCalendarDetail)getCurrentCalendarType {
    if([self getCalendarViewController]) {
        return [[self getCalendarViewController] getCurrentCalendarType];
    }
    
    return -1;
}

- (UITableView*)getDayTableView {
    return [[self getCalendarViewController] getDayTableView];
}

- (UIView*)getWeekCalendarView {
    return  [[self getCalendarViewController] getWeekCalendarView];
}

- (NSArray*)getWeekTableViews {
    return [[self getCalendarViewController] getWeekTableViews];
}

- (UICollectionView*)getMonthCollectionView {
    return [[self getCalendarViewController] getMonthCollectionView];
}


- (RBCalendarViewController*)getCalendarViewController {
    
    RBMenuViewHelper *menuViewHelper = [RBMenuViewHelper sharedManager];
    UIViewController *shownViewController = [menuViewHelper.detailNavigationController.childViewControllers lastObject];
    
    if( [shownViewController isKindOfClass:[RBCalendarViewController class]] ) {
        RBCalendarViewController *calendarController = (RBCalendarViewController*)shownViewController;
        return calendarController;
    }
    return nil;
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark - private methods
////////////////////////////////////////////////////////////////////////

- (BOOL)checkIfDropIsInPast {

    // Check if dropping audit in the PAST. It can´t be.
    NSDate *todayDate = [NSDate date];
    NSDate *calendarSelectedDate = [self getCurrentHoveredDate];
    
    //normalize both dates
    [[NSCalendar currentCalendar] rangeOfUnit:NSDayCalendarUnit startDate:&todayDate interval:NULL forDate:todayDate];
    [[NSCalendar currentCalendar] rangeOfUnit:NSDayCalendarUnit startDate:&calendarSelectedDate interval:NULL forDate:calendarSelectedDate];
    
    BOOL isPast = NO;
    if( [calendarSelectedDate compare:todayDate] == NSOrderedAscending) {
        isPast = YES;
    }
    
    if(self.intersectedCell.tag && isPast) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"NoDroppingStoreInPast", @"Date selected is a past date.") delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK",nil), nil];
        [alert show];
    }
    
    return isPast;
}

- (void)toggleLongPressGestureRecognizer:(BOOL)toggle {
    
    if(toggle == YES) {
        [self.view fkit_removeAllGestureRecognizers];
    } else {
        [self.view addGestureRecognizer:self.longPress];
    }
}

- (void)toggleDragWeekCellWithinWeekCalendar:(BOOL)toggle {
 
    canDragWeekCell = toggle;
}

- (void)setupSelectionUI {

    [self.intersectedCell setTag:1];
    
    if([self getCurrentCalendarType] == RBCalendarDetailMonth) {
        self.intersectedCell.layer.borderWidth = 1.f;
        self.intersectedCell.layer.borderColor = [UIColor redColor].CGColor;
    }
}

- (AUDAudit*)createBlankAudit {

    AUDAudit *newBlankAudit = [AUDAuditHelper newAUDAuditWithStore:nil date:nil orderNr:0 comment:@"" questionnaire:nil questionGroup:nil];
    return newBlankAudit;
}

- (void)scrollUp:(id)sender {
    
    if([self getCurrentCalendarType] == RBCalendarDetailDay) {
    
        if([self getDayTableView].contentOffset.y >= 0.f) {
        
            CGPoint currentOff = [self getDayTableView].contentOffset;
            currentOff.y -= kRBScrollSpeed;
            [[self getDayTableView] setContentOffset:currentOff animated: NO];

            [self testCellsIntersections];
        }
        
    } else if([self getCurrentCalendarType] == RBCalendarDetailWeek && self.selectedDayTableViewOfWeekCalendar.contentOffset.y >= 0.f) {
        
        CGPoint currentOff = self.selectedDayTableViewOfWeekCalendar.contentOffset;
        currentOff.y -= kRBScrollSpeed;
        [self.selectedDayTableViewOfWeekCalendar setContentOffset:currentOff animated: NO];
        
        [self testCellsIntersections];
    }
}

- (void)scrollDown:(id)sender {
    
    if([self getCurrentCalendarType] == RBCalendarDetailDay) {
        
        if([self getDayTableView].contentOffset.y <= [self getDayTableView].contentSize.height - [self getDayTableView].bounds.size.height) {
                
            CGPoint currentOff = [self getDayTableView].contentOffset;
            currentOff.y += kRBScrollSpeed;
            [[self getDayTableView] setContentOffset:currentOff animated: NO];
            
            [self testCellsIntersections];
        }
    } else if([self getCurrentCalendarType] == RBCalendarDetailWeek && (self.selectedDayTableViewOfWeekCalendar.contentOffset.y <= self.selectedDayTableViewOfWeekCalendar.contentSize.height - self.selectedDayTableViewOfWeekCalendar.bounds.size.height)) {
        
        CGPoint currentOff = self.selectedDayTableViewOfWeekCalendar.contentOffset;
        currentOff.y += kRBScrollSpeed;
        [self.selectedDayTableViewOfWeekCalendar setContentOffset:currentOff animated: NO];
        
        [self testCellsIntersections];
    }
}

- (void)resetTimer {

    if (self.timer != nil)
        [self.timer invalidate];
    self.timer = nil;
}

- (void)setCorrectOrderForDayCells {
    [[self getCalendarViewController] setCorrectOrderOrStyleOfCellsInDataSourceIndex:0];
}

- (void)setCorrectCellsStylesForWeekCellsAtSourceIndex:(NSInteger)index {
    [[self getCalendarViewController] setCorrectOrderOrStyleOfCellsInDataSourceIndex:index];
}

- (void)reorderBackTableView {
    
    // only used for day and week CalendarView
    if([self getCurrentCalendarType] == RBCalendarDetailDay) {
        
        NSIndexPath *indexPathSelected = [[self getDayTableView] indexPathForCell:(RBDayCalendarAuditCell*)self.intersectedCell];
        
        if (!indexPathSelected) {
            return;
        }
        
        [[self getCalendarViewController] removeRowInIndexPath:indexPathSelected inDataSourceIndex:0];
        
    } else if ([self getCurrentCalendarType] == RBCalendarDetailWeek) {
        
        if(!self.intersectedCell) {
            return;
        }
        
        NSIndexPath *indexPathSelected = [self.selectedDayTableViewOfWeekCalendar indexPathForCell:(RBWeekCalendarCell*)self.intersectedCell];
        if (!indexPathSelected) {
            return;
        }
        
        [[self getCalendarViewController] removeRowInIndexPath:indexPathSelected inDataSourceIndex:self.selectedDayTableViewOfWeekCalendar.tag];
}
    
    hasBlankCell = NO;
}

- (NSDate*)getCurrentHoveredDate {

    NSDate *curdate;
    if([self getCurrentCalendarType] == RBCalendarDetailDay) {
    
        RBDayCalendarViewController *dayCalendarController = (RBDayCalendarViewController*)[self getCalendarViewController].detailViewController;
        curdate = dayCalendarController.selectedDate;
    } else if ([self getCurrentCalendarType] == RBCalendarDetailWeek) {
        
        RBWeekCalendarViewController *weekCalendarController = (RBWeekCalendarViewController*)[self getCalendarViewController].detailViewController;
        curdate = [weekCalendarController.firstDisplayDate fkit_dateByAddingDays:self.selectedDayTableViewOfWeekCalendar.tag];
        
    } else if ([self getCurrentCalendarType] == RBCalendarDetailMonth) {
    
        NSIndexPath *indexPathMonth = [[self getMonthCollectionView] indexPathForCell:(RBMonthCalendarCell*)self.intersectedCell];
        int dayIndex = ((indexPathMonth.section - 1) * 7) + indexPathMonth.item;
        curdate = [[self getCalendarViewController].detailViewController.firstDisplayDate fkit_dateByAddingDays:dayIndex];
    }
    
    return curdate;
}

- (void)testCellsIntersections {
    
    if(isDraggedCellIntersectedWithDetailCalendar) {
        
        NSArray *visibleCellsArray;
        UICollectionView *monthCollectionView;
        
        // 2.1. load array of visible cells
        switch ([self getCurrentCalendarType]) {
                
            case RBCalendarDetailDay:
                visibleCellsArray = [[NSArray alloc] initWithArray:[[self getDayTableView] visibleCells]];
                break;
                
            case RBCalendarDetailWeek:
                
                for(UITableView *tView in [self getWeekTableViews]) {
                    CGRect convertedTableViewRect = [self.view convertRect:tView.frame fromView:tView.superview];
                    if(CGRectContainsPoint(convertedTableViewRect, self.clickedPoint)) {
                        
                        visibleCellsArray = [[NSArray alloc] initWithArray:[tView visibleCells]];
                        
                        // when changing to new tableView inside week calendarView
                        if(self.selectedDayTableViewOfWeekCalendar != tView) {
                            [self reorderBackTableView];
                        }

                        self.selectedDayTableViewOfWeekCalendar = tView;
                        
                        break;
                    }
                }
                break;
                
            case RBCalendarDetailMonth:
                monthCollectionView = [self getMonthCollectionView];
                visibleCellsArray = [[NSArray alloc] initWithArray:[monthCollectionView visibleCells]];
                break;
                
            default:
                break;
        }
        
        // 2.2. Run all visible cells array to check intersections
        for(UIView *vCell in visibleCellsArray) {
            
            vCell.layer.borderWidth = 2.0;
            vCell.layer.borderColor = [UIColor clearColor].CGColor;
            
            CGRect convertedCellRect = [self.view convertRect:vCell.frame fromView:vCell.superview];
            
            // check if clicked point intersects cell
            if( CGRectContainsPoint(convertedCellRect, self.clickedPoint) ) {

                // DAY Calendar
                if([self getCurrentCalendarType] == RBCalendarDetailDay) {              // DAY CALENDAR
                
                    // test
                    NSIndexPath *indexPathVCell = [[self getDayTableView] indexPathForCell:(RBDayCalendarAuditCell*)vCell];
                    
                    if(!hasBlankCell) {
                        
                        newAudit.dateFrom = [self getCurrentHoveredDate];
                        
                        [[self getCalendarViewController] addRowToIndexPath:indexPathVCell withAudit:newAudit inDataSourceIndex:0];
                        hasBlankCell = YES;
                        
                        self.intersectedCell = [[self getDayTableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPathVCell.row inSection:0]];
                    } else if( self.indexOfSelectedCell != indexPathVCell.row ) {
                        
                        NSIndexPath *fromIndexPath = [NSIndexPath indexPathForRow:self.indexOfSelectedCell inSection:0];
                        
                        [[self getCalendarViewController] moveRowFromIndexPath:fromIndexPath toIndexPath:indexPathVCell inDataSourceIndex:0 withNewAudit:newAudit];
                        
                    }
                    
                    self.indexOfSelectedCell = indexPathVCell.row;
  
                    
                } else if([self getCurrentCalendarType] == RBCalendarDetailWeek) {      // WEEK Calendar

                    NSIndexPath *indexPathVCell = [self.selectedDayTableViewOfWeekCalendar indexPathForCell:(RBWeekCalendarCell*)vCell];
    
                    // dragged week cell
                    if(self.theCopyWeekCell) {
                        
                        //only move row
                        if(self.selectedDayTableViewOfWeekCalendar.tag == copyWeekCellTableTag) {
                            
                            if(indexPathVCell.row != copyWeekCellRow) {

                                NSIndexPath *fromIndexPath = [NSIndexPath indexPathForRow:self.indexOfSelectedCell inSection:0];
                                
                                [[self getCalendarViewController] moveRowFromIndexPath:fromIndexPath toIndexPath:indexPathVCell inDataSourceIndex:self.selectedDayTableViewOfWeekCalendar.tag withNewAudit:newAudit];
                                copyWeekCellRow = indexPathVCell.row;
                                
                            }
                            
                        } else if(!hasBlankCell) {

                            copyWeekCellTableTag = self.selectedDayTableViewOfWeekCalendar.tag;
                            
                            newAudit.dateFrom = [self getCurrentHoveredDate];
                            
                            [[self getCalendarViewController] addRowToIndexPath:indexPathVCell withAudit:newAudit inDataSourceIndex:self.selectedDayTableViewOfWeekCalendar.tag];
                            hasBlankCell = YES;
                            
                        }
                        
                    } else if(copyCell){    // dragged storeList cell
                        
                        if(!hasBlankCell) {
                            
                            newAudit.dateFrom = [self getCurrentHoveredDate];
                            
                            [[self getCalendarViewController] addRowToIndexPath:indexPathVCell withAudit:newAudit inDataSourceIndex:self.selectedDayTableViewOfWeekCalendar.tag];
                            hasBlankCell = YES;
                            
                        } else if( self.indexOfSelectedCell != indexPathVCell.row) {
                            
                            NSIndexPath *fromIndexPath = [NSIndexPath indexPathForRow:self.indexOfSelectedCell inSection:0];
                            [[self getCalendarViewController] moveRowFromIndexPath:fromIndexPath toIndexPath:indexPathVCell inDataSourceIndex:self.selectedDayTableViewOfWeekCalendar.tag withNewAudit:newAudit];
                        
                        }

                    }
                    
                    self.intersectedCell = (RBWeekCalendarCell*)[self.selectedDayTableViewOfWeekCalendar cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPathVCell.row inSection:0]];
                    self.indexOfSelectedCell = indexPathVCell.row;
                    
                } else {    // MONTH Calendar
                    self.intersectedCell = vCell;
                }
                
                // Particular situation in case of month CalendarView must check if is cell is a header or a day not belonging to the current month
                if([self getCurrentCalendarType] == RBCalendarDetailMonth) {
                    NSIndexPath *indexPathCell = [monthCollectionView indexPathForCell:(UICollectionViewCell*)vCell];
                    RBMonthCalendarCell *monthCell = (RBMonthCalendarCell*)vCell;
                    if(indexPathCell.section == 0 || !monthCell.isInCurrentMonth) {
                        break;
                    }
                }
                
                [self setupSelectionUI];
            }
        }

        // 2.3. Extra test: if no cell is selected but clicked Point still inside tableView, it should add and select one row in the bottom of tableView
        if([self getCurrentCalendarType] == RBCalendarDetailDay) {
            
            if(self.intersectedCell.tag == 0 && !hasBlankCell) {
                
                RBCalendarViewController *calendarViewController = [self getCalendarViewController];
                NSUInteger lastRow = [calendarViewController numberOfRowsInDataSourceWithIndex:0];

                newAudit.dateFrom = [self getCurrentHoveredDate];
                
                [calendarViewController addRowToIndexPath:[NSIndexPath indexPathForRow:lastRow inSection:0] withAudit:newAudit inDataSourceIndex:0];
                hasBlankCell = YES;
                
                self.intersectedCell = [[self getDayTableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:lastRow inSection:0]];
                self.indexOfSelectedCell = lastRow;
            }
            
            [self setupSelectionUI];
            
        } else if([self getCurrentCalendarType] == RBCalendarDetailWeek) {
            
            if(self.intersectedCell.tag == 0 && !hasBlankCell) {

                RBWeekCalendarViewController *weekCalendarController = (RBWeekCalendarViewController*)[self getCalendarViewController].detailViewController;
                UIView *headerView = [weekCalendarController tableView:self.selectedDayTableViewOfWeekCalendar viewForHeaderInSection:1];
                CGRect convertedHeaderViewRect = [self.view convertRect:headerView.frame fromView:headerView.superview];
                
                // check if not headerCell from tableView
                if(!CGRectContainsPoint(convertedHeaderViewRect, self.clickedPoint) ) {

                    RBCalendarViewController *calendarViewController = [self getCalendarViewController];
                    NSUInteger lastRow = [calendarViewController numberOfRowsInDataSourceWithIndex:self.selectedDayTableViewOfWeekCalendar.tag];
                        
                    newAudit.dateFrom = [self getCurrentHoveredDate];
                    
                    if(copyCell || (self.theCopyWeekCell && self.selectedDayTableViewOfWeekCalendar.tag != copyWeekCellTableTag)) {
                       
                        [calendarViewController addRowToIndexPath:[NSIndexPath indexPathForRow:lastRow inSection:0] withAudit:newAudit inDataSourceIndex:self.selectedDayTableViewOfWeekCalendar.tag];
                        hasBlankCell = YES;
                        
                        if(self.theCopyWeekCell) {
                            copyWeekCellTableTag = self.selectedDayTableViewOfWeekCalendar.tag;
                        }
                        
                        self.intersectedCell = (RBWeekCalendarCell*)[self.selectedDayTableViewOfWeekCalendar cellForRowAtIndexPath:[NSIndexPath indexPathForRow:lastRow inSection:0]];
                        self.indexOfSelectedCell = lastRow;
                        
                        [self setCorrectCellsStylesForWeekCellsAtSourceIndex:self.selectedDayTableViewOfWeekCalendar.tag];
                    }
                }
            }
        
            [self setupSelectionUI];
        }
    } else {    // end 2. No cells intersected
        if([self getCurrentCalendarType] == RBCalendarDetailDay || [self getCurrentCalendarType] == RBCalendarDetailWeek) {
            [self reorderBackTableView];
            copyWeekCellTableTag = -1;
        }
        
    }
}

@end
