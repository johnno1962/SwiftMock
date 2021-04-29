# SwiftMock

### Mock structs and classes without code modification for testing.

SwiftMock is an experimental package which allows you to interpose a struct 
or class in the place of an existing one used in your application so you can,
for example, provide mocked data for testing or development. The api is simple:

```
SwiftMock.pose(MockedStruct.self, as: OriginalStruct.self)
```
The mocking struct must have the same memory layout as the original 
and mocking classes should inherit from the class being mocked.

To be able to do this, you need to have added "Other Linker Flags" of
"-Xlinker -interposable" (without the quotes) to make symbol references
"indirect" so they can be redirected. This package also patches a class'
vtables. It doesn't currently work with generics.

$Date: 2021/04/29 $
