# Interleaved Janus documentation


## Prolog calling Python

### py_func/3,4

#### SWI

  - <span class="pred-tag">\[det\]</span><span id="py_func/3">**py_func**(`+Module,
    +Function, -Return`)</span>
    <span class="pred-tag">\[det\]</span><span id="py_func/4">**py_func**(`+Module,
    +Function, -Return, +Options`)</span>
    Call Python `Function` in `Module`. The SWI-Prolog implementation is
    equivalent to `py_call(Module:Function, Return)`. See
    [py_call/2](#py_call/2) for details.

      - Compatibility
        PIP. See [py_call/2](#py_call/2) for notes. Note that, as this
        implementation is based on [py_call/2](#py_call/2), `Function`
        can use changing, e.g., `py_func(sys, path:append(dir), Return)`
        is accepted by this implementation, but not portable.

#### XSB


`py_func(+Module,+Function,?Return)`


`py_func(+Module,+Function,?Return,+Options)`

Ensures that the Python module `Module` is loaded, and calls
` Module.Function` unifying the return of `Function` with ` Return`. As
in Python, the arguments of `Function` may contain keywords but
positional arguments must occur before keywords. For example the goal

    py_func(jns_rdflib,rdflib_write_file(Triples,'out.ttl',format=turtle),Ret).

calls the Python function `jns_rdflib.rdflib_write_file()` to write
`Triples`, a list of triples in Prolog format, to the file
`new_sample.ttl` using the RDF `turtle` format.

In general, `Module` must be the name of a Python module or path
represented as a Prolog atom. Python built-in functions can be called
using the “pseudo-module” `builtins`, for instance

`py_func(builtins, float(’+1E6’),F).`

produces the expected result:

`F = 1000000.0`

If `Module` has not already been loaded, it will be automatically loaded
during the call. Python modules are searched for in the paths maintained
in Python’s `sys.path` list and these Python paths can be queried from
Prolog via ` py_lib_dir/1` and modified via `py_add_lib_dir/1`.

`Function` is the invocation of a Python function in `Module`, where
`Function` is a compound Prolog structure in which arguments with the
outer functor `=/2` are treated as Python keyword arguments.

Currently supported options are:

- `py_object(true)` This option returns most Python data structures as
  object references, so that attributes of the data structures can be
  queried if needed. The only data returned *not* as an object reference
  are

  - Objects of `boolean` type

  - Objects of `none` type

  - Objects of exactly the class `long`, `float` or ` string`. Objects
    that are proper subclasses of these types are returned as object
    references.

**Error Cases**

- `py_func/4` is called with an uninstantiated option list

  - `instantiation_error`

- The option list `py_func/4` contains an improper element, or
  combination of elements.

  - `domain_error`

- `Module` is not a Prolog atom:

  - `type_error`

- `Module` cannot be found in the current Python search paths:

  - `existence_error`

- `Function` is not a callable term

  - `type_error`

- `Function` does not correspond to a Python function in `Module`

  - `existence_error`

- When translating an argument of function:

  - A set (`py_set/1`) term has an argument that is not a list

    - `type_error`

  - The list in a set term (`py_set/1` contains a non-hashable term

    - `type_error`

  - A dictionary (`/1`) term has an argument that is not a comma-list

    - `type_error`

  - An element of a dictionary comma-list is not of the form ` :/2` or
    the structure contains a non-hashable key (first argument)

    - `type_error`

  - An argument of `Function` is otherwise non-translatable to Python

    - `misc_error`

In addition, errors thrown by Python are caught by XSB and re-thrown as
`misc_error` errors.

### py_call/1-3

#### SWI

  - <span class="pred-tag">\[det\]</span><span id="py_call/1">**py_call**(`+Call`)</span>
    <span class="pred-tag">\[det\]</span><span id="py_call/2">**py_call**(`+Call,
    -Return`)</span>
    <span class="pred-tag">\[det\]</span><span id="py_call/3">**py_call**(`+Call,
    -Return, +Options`)</span>
    `Call` Python and return the result of the called function. `Call`
    has the shape‘\[Target\]\[:Action\]\*\`, where `Target` is either a
    Python module name or a Python object reference. Each `Action` is
    either an atom to get the denoted attribute from current `Target` or
    it is a compound term where the first argument is the function or
    method name and the arguments provide the parameters to the Python
    function. On success, the returned Python object is translated to
    Prolog. `Action` without a `Target` denotes a buit-in function.

    Arguments to Python functions use the Python conventions. Both
    *positional* and *keyword* arguments are supported. Keyword
    arguments are written as `Name = Value` and must appear after the
    positional arguments.

    Below are some examples.

    ``` code
    % call a built-in
    ?- py_call(print("Hello World!\n")).
    true.

    % call a built-in (alternative)
    ?- py_call(builtins:print("Hello World!\n")).
    true.

    % call function in a module
    ?- py_call(sys:getsizeof([1,2,3]), Size).
    Size = 80.

    % call function on an attribute of a module
    ?- py_call(sys:path:append("/home/bob/janus")).
    true

    % get attribute from a module
    ?- py_call(sys:path, Path)
    Path = ["dir1", "dir2", ...]
    ```

    Given a class in a file `dog.py` such as the following example from
    the Python documentation

    ``` code
    class Dog:
        tricks = []

        def __init__(self, name):
            self.name = name

        def add_trick(self, trick):
            self.tricks.append(trick)
    ```

    We can interact with this class as below. Note that `$Doc` in the
    SWI-Prolog toplevel refers to the last toplevel binding for the
    variable `Dog`.

    ``` code
    ?- py_call(dog:'Dog'("Fido"), Dog).
    Dog = <py_Dog>(0x7f095c9d02e0).

    ?- py_call($Dog:add_trick("roll_over")).
    Dog = <py_Dog>(0x7f095c9d02e0).

    ?- py_call($Dog:tricks, Tricks).
    Dog = <py_Dog>(0x7f095c9d02e0),
    Tricks = ["roll_over"]
    ```

    If the principal term of the first argument is not `Target:Func`,
    The argument is evaluated as the initial target, i.e., it must be an
    object reference or a module. For example:

    ``` code
    ?- py_call(dog:'Dog'("Fido"), Dog),
       py_call(Dog, X).
       Dog = X, X = <py_Dog>(0x7fa8cbd12050).
    ?- py_call(sys, S).
       S = <py_module>(0x7fa8cd582390).
    ```

    `Options` processed:

      - **py_object**(`Boolean`)
        If `true` (default `false`), translate the return as a Python
        object reference. Some objects are *always* translated to
        Prolog, regardless of this flag. These are the Python constants
        `None`, `True` and `False` as well as instances of the Python
        base classes `int`, `float`, `str` or `tuple`. Instances of sub
        classes of these base classes are controlled by this option.
      - **py_string_as**(`+Type`)
        If `Type` is `atom` (default), translate a Python String into a
        Prolog atom. If `Type` is `string`, translate into a Prolog
        string. Strings are more efficient if they are short lived.
      - **py_dict_as**(`+Type`)
        One of `dict` (default) to map a Python dict to a SWI-Prolog
        dict if all keys can be represented. If `{}` or not all keys can
        be represented, `Return` is unified to a term `{k:v, ...}` or
        `py({})` if the Python dict is empty.

    <!-- end list -->

      - Compatibility
        PIP. The options `py_string_as` and `py_dict_as` are SWI-Prolog
        specific, where SWI-Prolog Janus represents Python strings as
        atoms as required by the PIP and it represents Python dicts by
        default as SWI-Prolog dicts. The predicates
        [values/3](#values/3), [keys/2](#keys/2), etc. provide portable
        access to the data in the dict.

#### XSB


`py_call(+Form,-Ret,+Opts)`


`py_call(+Form,Ret)`

`py_call/[2,3]` is alternate syntax for `py_func/[3,4]` and
`py_dot/[3,4]`. Or perhaps it is the other way around.

`py_call(Mod:Func,Ret,Opts)`

emulates `py_func(Mod,Func,Ret,Opts)`, while

`py_call(Obj:Func,Ret,Opts)`

emulates `py_dot(Obj,Func,Ret,Opts)`. Within ` py_call/[2,3]` function
composition can be performed via the use of the `eval/1` term and via
nested use of `:/2` as indicated in
Example <a href="#jns-examp:pycall" data-reference-type="ref"
data-reference="jns-examp:pycall">1.7</a>.

Options and Error cases are the same as for `py_func/[3,4]` and
`py_dot/[3,4]`.



## Python calling Prolog
