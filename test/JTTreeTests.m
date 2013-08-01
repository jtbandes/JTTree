//
//  JTTreeTests.m
//  JTTreeTests
//
//  Created by Jacob Bandes-Storch on 7/30/13.
//

#import <SenTestingKit/SenTestingKit.h>

#import "JTTree.h"


@interface JTTreeTests : SenTestCase
@end


@implementation JTTreeTests

- (void)testStructure
{
    JTTree *tree = [JTTree new];
    STAssertNotNil(tree, @"New tree should not be nil");
    
    STAssertTrue([tree isLeaf], @"New tree should be a leaf");
    STAssertTrue([tree isEqual:tree.root], @"New tree should be its own root");
    STAssertEquals(tree.numberOfChildren, (NSUInteger)0, @"New tree should have no children");
    
    [tree insertChildObject:nil atIndex:0];
    
    STAssertEquals(tree.numberOfChildren, (NSUInteger)1, @"Adding a child should increment number of children");
    
    JTTree *child1 = [tree childAtIndex:0];
    
    STAssertNotNil(child1, @"New child should not be nil");
    STAssertEqualObjects([NSIndexPath indexPathWithIndex:0], child1.indexPath, @"Child index path should be 0");
    STAssertTrue([child1 isLeaf], @"New child should be a leaf");
    STAssertEqualObjects(tree, child1.parent, @"New child's parent should be original tree");
    STAssertEqualObjects(tree, child1.root, @"New child's root should be original tree");
    STAssertNil(child1.nextSibling, @"New child should have no next sibling");
    STAssertNil(child1.previousSibling, @"New child should have no previous sibling");
    STAssertEqualObjects(child1, tree.firstChild, @"New child should be parent's first child");
    STAssertEqualObjects(child1, tree.lastChild, @"New child should be parent's last child");
    STAssertFalse([tree isLeaf], @"Tree with children should not be a leaf");
    
    [tree insertChildObject:nil atIndex:0];
    
    JTTree *child2 = [tree childAtIndex:0];
    STAssertEqualObjects(child1, child2.nextSibling, @"Child should be inserted before sibling");
    STAssertEqualObjects([NSIndexPath indexPathWithIndex:1], child1.indexPath, @"Child index path should be 1");
    STAssertEqualObjects(child1, [tree childAtIndex:1], @"Sibling index should have incremented");
    STAssertEqualObjects([NSIndexPath indexPathWithIndex:1], child1.indexPath, @"Sibling index path should be 1");
    STAssertEqualObjects(child2, child1.previousSibling, @"Child should be inserted before sibling");
    STAssertNil(child1.nextSibling, @"Last child should have no next sibling");
    STAssertNil(child2.previousSibling, @"First child should have no previous sibling");
    STAssertEqualObjects(child2, tree.firstChild, @"New child should be parent's first child");
    STAssertEqualObjects(child1, tree.lastChild, @"Parent's last child should not change");
    
    [child1 insertChildObject:nil atIndex:0];
    
    JTTree *grandchild = [child1 childAtIndex:0];
    STAssertNotNil(grandchild, @"Grandchild should not be nil");
    NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:((NSUInteger[]){1,0}) length:2];
    STAssertEqualObjects(grandchild, [tree descendantAtIndexPath:indexPath], @"Grandchild should be reachable by index path 1 0");
    STAssertEqualObjects(indexPath, grandchild.indexPath, @"Grandchild index path should be 1 0");
}

- (void)testObjectLifetime
{
    JTTree *tree = [JTTree new];
    id obj = [NSObject new];
    id __weak weakObj = obj;
    
    tree.object = obj;
    
    obj = nil;
    STAssertNotNil(weakObj, @"Object should not be released before tree node");
    
    tree = nil;
    STAssertNil(weakObj, @"Object should be released along with tree node");
    
    tree = [JTTree new];
    obj = [NSObject new];
    weakObj = obj;
    
    [tree insertChildObject:obj atIndex:0];
    obj = nil;
    STAssertNotNil(weakObj, @"Object should not be released before parent");
    
    [tree removeAllChildren];
    STAssertNil(weakObj, @"Object should be released when removed from parent");
    
    tree = [JTTree new];
    obj = [NSObject new];
    weakObj = obj;
    
    [tree insertChildObject:obj atIndex:0];
    obj = nil;
    STAssertNotNil(weakObj, @"Object should not be released before parent");
    
    tree = nil;
    STAssertNil(weakObj, @"Child should be released along with parent");
}

@end
