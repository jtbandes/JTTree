//
//  JTTree.m
//  JTTree
//
//  Created by Jacob Bandes-Storch on 7/29/13.
//

#import "JTTree.h"


CF_INLINE CFTreeRef JT_CFTreeGetDescendantAtIndexPath(CFTreeRef tree, NSIndexPath *indexPath)
{
    NSUInteger numIndices = [indexPath length];
    NSUInteger *indices = malloc(numIndices * sizeof(NSUInteger));
    
    [indexPath getIndexes:indices];
    
    CFTreeRef current = tree;
    for (NSUInteger i = 0; i < numIndices; i++)
        current = CFTreeGetChildAtIndex(current, indices[i]);
    
    free(indices);
    return current;
}

CF_INLINE CFTreeRef JT_CFTreeCreateWithContextObject(id obj)
{
    return CFTreeCreate(NULL, &(CFTreeContext){
        .version = 0,
        .info = (__bridge void *)obj,
        .retain = obj ? CFRetain : NULL,
        .release = obj ? CFRelease : NULL,
        .copyDescription = CFCopyDescription
    });
}

CF_INLINE void JT_CFTreeSetContextObject(CFTreeRef tree, id obj)
{
    CFTreeSetContext(tree, &(CFTreeContext){
        .version = 0,
        .info = (__bridge void *)obj,
        .retain = obj ? CFRetain : NULL,
        .release = obj ? CFRelease : NULL,
        .copyDescription = CFCopyDescription
    });
}

CF_INLINE id JT_CFTreeGetContextObject(CFTreeRef tree)
{
    if (!tree) return nil;
    
    CFTreeContext context;
    CFTreeGetContext(tree, &context);
    return (__bridge id)context.info;
}

CF_INLINE CFIndex JT_CFTreeGetIndexInParent(CFTreeRef tree, CFTreeRef *outParent)
{
    if (!tree) return kCFNotFound;
    
    CFTreeRef parent = CFTreeGetParent(tree);
    if (outParent) *outParent = parent;
    
    if (!parent) return kCFNotFound;
    
    CFIndex numChildren = CFTreeGetChildCount(parent);
    CFTreeRef *children = malloc(numChildren * sizeof(CFTreeRef));
    
    CFTreeGetChildren(parent, children);
    
    CFIndex index = kCFNotFound;
    for (CFIndex i = 0; i < numChildren; i++)
    {
        if (children[i] == tree)
        {
            index = i;
            break;
        }
    }
    
    free(children);
    return index;
}


@implementation JTTree {
    CFTreeRef _tree;
}

/**
 * Creates a tree with the specified backing tree, or if it is nil, returns nil.
 * If @p passthrough is not nil, and its backing tree is equal to @p tree, returns @p passthrough itself.
 */
NS_INLINE JTTree *JTTreeWithCFTreeOrJTTree(CFTreeRef tree, JTTree *passthrough)
{
    if (passthrough && tree == passthrough->_tree) return passthrough;
    
    if (!tree) return nil;
    
    return [[JTTree alloc] _initWithCFTree:tree];
}

- (id)init
{
    if ((self = [super init]))
    {
        _tree = JT_CFTreeCreateWithContextObject(nil);
    }
    return self;
}

- (id)_initWithCFTree:(CFTreeRef)cfTree
{
    if ((self = [super init]))
    {
        _tree = (CFTreeRef)CFRetain(cfTree);
    }
    return self;
}

- (void)dealloc
{
    CFRelease(_tree);
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p>{children = %ld, object = %@}",
            [self class], self, CFTreeGetChildCount(_tree), JT_CFTreeGetContextObject(_tree)];
}

- (BOOL)isEqual:(JTTree *)object
{
    return object && CFEqual(_tree, object->_tree);
}
- (NSUInteger)hash
{
    return CFHash(_tree);
}

- (id)representedObject
{
    return JT_CFTreeGetContextObject(_tree);
}
- (void)setRepresentedObject:(id)obj
{
    JT_CFTreeSetContextObject(_tree, obj);
}


#pragma mark Structure

- (BOOL)isLeaf
{
    return CFTreeGetChildCount(_tree) == 0;
}

- (JTTree *)parent
{
    return JTTreeWithCFTreeOrJTTree(CFTreeGetParent(_tree), nil);
}
- (id)parentObject
{
    return JT_CFTreeGetContextObject(CFTreeGetParent(_tree));
}

- (NSUInteger)numberOfChildren
{
    return CFTreeGetChildCount(_tree);
}

- (JTTree *)childAtIndex:(NSUInteger)index
{
    return JTTreeWithCFTreeOrJTTree(CFTreeGetChildAtIndex(_tree, index), nil);
}
- (id)childObjectAtIndex:(NSUInteger)index
{
    return JT_CFTreeGetContextObject(CFTreeGetChildAtIndex(_tree, index));
}

- (NSIndexPath *)indexPath
{
    NSUInteger pathLength = 0;
    
    // Store a reverse linked list allowing us to build up the index path in linear time.
    typedef struct _indexList {
        NSUInteger index;
        struct _indexList *prev;
    } indexList;
    
    indexList *node = NULL;
    
    CFTreeRef current = _tree;
    while (current != nil)
    {
        CFTreeRef parent = NULL;
        
        NSUInteger indexInParent = JT_CFTreeGetIndexInParent(current, &parent);
        
        if (!parent) break;
        
        indexList *newNode = malloc(sizeof(indexList));
        newNode->index = indexInParent;
        newNode->prev = node;
        node = newNode;
        pathLength++;
        
        current = parent;
    }
    
    // Convert the linked list into a contiguous array.
    NSUInteger *indices = malloc(pathLength * sizeof(NSUInteger));
    for (NSUInteger i = 0; i < pathLength; i++) {
        indices[i] = node->index;
        
        indexList *oldNode = node;
        node = oldNode->prev;
        free(oldNode);
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:indices length:pathLength];
    
    free(indices);
    return indexPath;
}


#pragma mark Traversal

- (JTTree *)root
{
    return JTTreeWithCFTreeOrJTTree(CFTreeFindRoot(_tree), self);
}
- (id)rootObject
{
    return JT_CFTreeGetContextObject(CFTreeFindRoot(_tree));
}

- (JTTree *)firstChild
{
    return JTTreeWithCFTreeOrJTTree(CFTreeGetFirstChild(_tree), nil);
}
- (id)firstChildObject
{
    return JT_CFTreeGetContextObject(CFTreeGetFirstChild(_tree));
}

- (JTTree *)lastChild
{
    return JTTreeWithCFTreeOrJTTree(CFTreeGetChildAtIndex(_tree, CFTreeGetChildCount(_tree)-1), nil);
}
- (id)lastChildObject
{
    return JT_CFTreeGetContextObject(CFTreeGetChildAtIndex(_tree, CFTreeGetChildCount(_tree)-1));
}

- (JTTree *)previousSibling
{
    CFTreeRef parent = NULL;
    
    NSUInteger indexInParent = JT_CFTreeGetIndexInParent(_tree, &parent);
    
    if (!parent) return nil;
    
    return JTTreeWithCFTreeOrJTTree(CFTreeGetChildAtIndex(CFTreeGetParent(_tree), (CFIndex)indexInParent-1), nil);
}
- (id)previousSiblingObject
{
    CFTreeRef parent = NULL;
    
    NSUInteger indexInParent = JT_CFTreeGetIndexInParent(_tree, &parent);
    
    if (!parent) return nil;
    
    return JT_CFTreeGetContextObject(CFTreeGetChildAtIndex(CFTreeGetParent(_tree), (CFIndex)indexInParent-1));
}

- (JTTree *)nextSibling
{
    return JTTreeWithCFTreeOrJTTree(CFTreeGetNextSibling(_tree), nil);
}
- (id)nextSiblingObject
{
    return JT_CFTreeGetContextObject(CFTreeGetNextSibling(_tree));
}

- (JTTree *)descendantAtIndexPath:(NSIndexPath *)indexPath
{
    return JTTreeWithCFTreeOrJTTree(JT_CFTreeGetDescendantAtIndexPath(_tree, indexPath), self);
}
- (id)descendantObjectAtIndexPath:(NSIndexPath *)indexPath
{
    return JT_CFTreeGetContextObject(JT_CFTreeGetDescendantAtIndexPath(_tree, indexPath));
}


#pragma mark Manipulation

- (void)insertChild:(JTTree *)child atIndex:(NSUInteger)index
{
    [child removeFromParent];
    
    if (index == 0)
        CFTreePrependChild(_tree, child->_tree);
    else
        CFTreeInsertSibling(CFTreeGetChildAtIndex(_tree, index-1), child->_tree);
}
- (void)insertChildObject:(id)obj atIndex:(NSUInteger)index
{
    CFTreeRef child = JT_CFTreeCreateWithContextObject(obj);
    
    if (index == 0)
        CFTreePrependChild(_tree, child);
    else
        CFTreeInsertSibling(CFTreeGetChildAtIndex(_tree, index-1), child);
    
    CFRelease(child);
}

- (void)removeChildAtIndex:(NSUInteger)index
{
    CFTreeRemove(CFTreeGetChildAtIndex(_tree, index));
}

- (void)removeAllChildren
{
    CFTreeRemoveAllChildren(_tree);
}

- (void)removeFromParent
{
    CFTreeRemove(_tree);
}

@end
