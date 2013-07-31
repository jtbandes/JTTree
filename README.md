## JTTree

A more useful wrapper around [CFTree](https://developer.apple.com/documentation/CoreFoundation/Reference/CFTreeRef/) (with apologies to [NSTreeNode](https://developer.apple.com/library/mac/documentation/cocoa/reference/NSTreeNode_class/)).

Born out of a desire to not work with CFTree objects.

## Documentation

See [`JTTree.h`](src/JTTree.h) for API. To quote the overview:

> Each tree node can store a reference to an object. Most methods come in pairs: one to act on tree nodes, and one to act on stored objects directly.

> Two JTTree objects are equal (according to `-isEqual:`) iff they refer to the same underlying tree node. (Pointer equality is not guaranteed.)

> All behavior not explicitly specified here (such as nil return values, tree lifetime, etc.) should be assumed to be the same as CFTree, which, in many cases, also does not specify its behavior explicitly.

## Contributing

Submit a [pull request](http://github.com/jtbandes/JTTree/pulls)!

## License

JTTree is released under the [Unlicense](http://unlicense.org/):

> This is free and unencumbered software released into the public domain.

> Anyone is free to copy, modify, publish, use, compile, sell, or distribute this software, either in source code form or as a compiled binary, for any purpose, commercial or non-commercial, and by any means.

> In jurisdictions that recognize copyright laws, the author or authors of this software dedicate any and all copyright interest in the software to the public domain. We make this dedication for the benefit of the public at large and to the detriment of our heirs and successors. We intend this dedication to be an overt act of relinquishment in perpetuity of all present and future rights to this software under copyright law.

> THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
