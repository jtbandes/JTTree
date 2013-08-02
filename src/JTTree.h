//
//  JTTree.h
//  JTTree
//
//  Created by Jacob Bandes-Storch on 7/29/13.
//

#import <Foundation/Foundation.h>


/**
 * Options for tree traversal.
 *
 * Traversing the following example tree starting from node A
 * produces the following forward traversal orders:
 *
 *   Children only:          B C
 *   Breadth-first:          A B C D E
 *   In-order (binary only): D B E A C
 *   Depth-first pre-order:  A B D E C
 *   Depth-first post-order: D E B C A
 *
 *     A
 *    / \
 *   B   C
 *  / \
 * D   E
 *
 */
typedef NS_ENUM(NSUInteger, JTTreeTraversalOptions) {
    // Forward or reverse traversal
    JTTreeTraversalReverse             = 1 << 0,
    // Traversal order options (mutually exclusive)
    JTTreeTraversalChildrenOnly        = 1 << 1,
    JTTreeTraversalBreadthFirst        = 1 << 2,
    JTTreeTraversalDepthFirstPreOrder  = 1 << 3,
    JTTreeTraversalDepthFirstPostOrder = 1 << 4,
    JTTreeTraversalBinaryInOrder       = 1 << 5,
    JTTreeTraversalOrderMask = (JTTreeTraversalChildrenOnly
                                | JTTreeTraversalBreadthFirst
                                | JTTreeTraversalDepthFirstPreOrder
                                | JTTreeTraversalDepthFirstPostOrder
                                | JTTreeTraversalBinaryInOrder),
};

/**
 * A more useful wrapper around CFTree (with apologies to NSTreeNode).
 *
 * Each tree node can store a reference to an object.
 * Most methods come in pairs: one to act on tree nodes, and one to act on stored objects directly.
 * 
 * Two JTTree objects are equal (according to -isEqual:) iff they refer to the same underlying tree node.
 * (Pointer equality is not guaranteed.)
 *
 * All behavior not explicitly specified here (such as nil return values, tree lifetime, etc.)
 * should be assumed to be the same as CFTree, which, in many cases, also does not specify its behavior explicitly.
 */
@interface JTTree : NSObject

/** An object stored at the tree node. */
@property (strong) id object;

/**
 * Returns a new tree node storing the given object.
 * @param object The object to store at the tree node.
 */
+ (instancetype)treeWithObject:(id)object;
/**
 * Initializes a new tree node storing the given object.
 * @param object The object to store at the tree node.
 */
- (instancetype)initWithObject:(id)object;


#pragma mark Structure

/** @return Whether the node is a leaf (has no children). */
- (BOOL)isLeaf;

/**
 * Calculates the index path of the node relative to its root parent by traversing upwards through the tree.
 * @return The index path of the node in the tree.
 * @performance This operation is somewhat expensive due to the limitations of the CFTree API.
 */
- (NSIndexPath *)indexPath;

/** @return The receiver's immediate parent. */
- (JTTree *)parent;
/** @return The object stored at the receiver's immediate parent. */
- (id)parentObject;

/** @return The number of direct children of the receiver. */
- (NSUInteger)numberOfChildren;

/**
 * @return The receiver's child at the specified index.
 * @param index An index path specifying a child.
 */
- (JTTree *)childAtIndex:(NSUInteger)index;
/**
 * @return The object stored at the specified child.
 * @param index An index path specifying a child.
 */
- (id)childObjectAtIndex:(NSUInteger)index;


#pragma mark Traversal

/**
 * Finds the node's root (the ancestor with no parent) by traversing upwards through the tree.
 * @return The root of the tree.
 */
- (JTTree *)root;
/** @return The object stored at the root of the tree. */
- (id)rootObject;

/** @return The receiver's first child. */
- (JTTree *)firstChild;
/** @return The object stored at the receiver's first child. */
- (id)firstChildObject;

/** @return The receiver's last child. */
- (JTTree *)lastChild;
/** @return The object stored at the receiver's last child. */
- (id)lastChildObject;

/**
 * @return The receiver's previous adjacent sibling.
 * @performance This operation is somewhat expensive due to the limitations of the CFTree API.
 */
- (JTTree *)previousSibling;
/**
 * @return The object stored at the receiver's previous adjacent sibling.
 * @performance This operation is somewhat expensive due to the limitations of the CFTree API.
 */
- (id)previousSiblingObject;

/** @return The receiver's next adjacent sibling. */
- (JTTree *)nextSibling;
/** @return The object stored at the receiver's next adjacent sibling. */
- (id)nextSiblingObject;

/**
 * Finds a descendant by traversing downwards through the tree.
 * @return The descendant at the specified index path.
 * @param indexPath An index path specifying a descendant.
 */
- (JTTree *)descendantAtIndexPath:(NSIndexPath *)indexPath;
/**
 * @return The object stored at the specified index path.
 * @param indexPath An index path specifying a descendant.
 */
- (id)descendantObjectAtIndexPath:(NSIndexPath *)indexPath;

/**
 * Traverses the tree in the specified manner and executes the block for each descendant.
 * @note Mutating the tree during traversal will result in undefined behavior.
 * @param options A bitmask that specifies options for traversal.
 * @param block The block to apply to each descendant.
 */
- (void)enumerateDescendantsWithOptions:(JTTreeTraversalOptions)options
                             usingBlock:(void (^)(JTTree *descendant, BOOL *stop))block;


#pragma mark Manipulation

/**
 * Adds a child node to the receiver at the specified index.
 * If @p child is already a member of some tree, it will be removed.
 * @param child A node to insert.
 * @param index The index at which to insert the child.
 */
- (void)insertChild:(JTTree *)child atIndex:(NSUInteger)index;
/**
 * Adds a child object to the receiver at the specified index.
 * @param obj An object to store at the new node.
 * @param index The index at which to insert the child.
 */
- (void)insertChildObject:(id)obj atIndex:(NSUInteger)index;

/**
 * Removes a specific child from the receiver.
 * @param index The index of the child to remove.
 */
- (void)removeChildAtIndex:(NSUInteger)index;

/** Empties the receiver of all its children. */
- (void)removeAllChildren;

/** Removes the receiver from its parent. */
- (void)removeFromParent;

@end
