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
    STAssertEquals(tree.depth, (NSUInteger)0, @"New tree should have depth 0");
    
    [tree insertChildObject:nil atIndex:0];
    
    STAssertEquals(tree.numberOfChildren, (NSUInteger)1, @"Adding a child should increment number of children");
    
    JTTree *child1 = [tree childAtIndex:0];
    
    STAssertNotNil(child1, @"New child should not be nil");
    STAssertEqualObjects([NSIndexPath indexPathWithIndex:0], child1.indexPath, @"Child index path should be 0");
    STAssertEquals(child1.depth, (NSUInteger)1, @"Child depth should be 1");
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
    STAssertEquals(grandchild.depth, (NSUInteger)2, @"Grandchild depth should be 2");
    
    JTTree *intermediate = [JTTree treeWithObject:nil];
    [child1 insertChild:intermediate atIndex:0];
    [grandchild removeFromParent];
    [intermediate insertChild:grandchild atIndex:0];
    STAssertEquals(grandchild.depth, (NSUInteger)3, @"Descendant depth should be 3 after inserting a node above");
}

- (void)testTraversal
{
//    *     A
//    *    / \
//    *   B   C
//    *  / \
//    * D   E
    
    JTTree *a = [JTTree treeWithObject:@"a"];
    JTTree *b = [JTTree treeWithObject:@"b"];
    JTTree *c = [JTTree treeWithObject:@"c"];
    JTTree *d = [JTTree treeWithObject:@"d"];
    JTTree *e = [JTTree treeWithObject:@"e"];
    
    [a insertChild:b atIndex:0];
    [a insertChild:c atIndex:1];
    [b insertChild:d atIndex:0];
    [b insertChild:e atIndex:1];
    
    NSMutableArray *results = [NSMutableArray array];
    id block = ^(JTTree *descendant, BOOL *stop) { [results addObject:descendant]; };
    
    STAssertThrows([a enumerateDescendantsWithOptions:JTTreeTraversalChildrenOnly|JTTreeTraversalBreadthFirst
                                           usingBlock:block], @"Two traversal options should fail");
    
    [a enumerateDescendantsWithOptions:JTTreeTraversalChildrenOnly usingBlock:block];
    STAssertEqualObjects(results, (@[ b, c ]), @"Children-only traversal should visit B C");
    [results removeAllObjects];
    
    [a enumerateDescendantsWithOptions:JTTreeTraversalBreadthFirst usingBlock:block];
    STAssertEqualObjects(results, (@[ a, b, c, d, e ]), @"Breadth-first traversal should visit A B C D E");
    [results removeAllObjects];
    
    [a enumerateDescendantsWithOptions:JTTreeTraversalDepthFirstPreOrder usingBlock:block];
    STAssertEqualObjects(results, (@[ a, b, d, e, c ]), @"Depth-first pre-order traversal should visit A B D E C");
    [results removeAllObjects];

    [a enumerateDescendantsWithOptions:JTTreeTraversalDepthFirstPostOrder usingBlock:block];
    STAssertEqualObjects(results, (@[ d, e, b, c, a ]), @"Depth-first post-order traversal should visit D E B C A");
    [results removeAllObjects];
    
    [a enumerateDescendantsWithOptions:JTTreeTraversalBinaryInOrder usingBlock:block];
    STAssertEqualObjects(results, (@[ d, b, e, a, c ]), @"In-order traversal should visit D B E A C");
    [results removeAllObjects];

    [a insertChildObject:nil atIndex:2];
    STAssertThrows([a enumerateDescendantsWithOptions:JTTreeTraversalBinaryInOrder usingBlock:block],
                   @"Binary traversal should fail for non-binary tree");
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
