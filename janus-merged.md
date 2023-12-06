

# Contents

  - [Predicate py_func/3, py_func/4](#-predicate-pyfunc3-pyfunc4)
  - [Predicate py_dot/3, py_dot/4, py_dot/5](#-predicate-pydot3-pydot4-pydot5)
  - [Predicate py_call/1, py_call/2, py_call/3](#-predicate-pycall1-pycall2-pycall3)
  - [Predicate py_free/1](#-predicate-pyfree1)
  - [Predicate py_pp/1, py_pp/2, py_pp/3](#-predicate-pypp1-pypp2-pypp3)
  - [Predicate py_add_lib_dir/1, py_add_lib_dir/2](#-predicate-pyaddlibdir1-pyaddlibdir2)
  - [Predicate py_lib_dirs/1](#-predicate-pylibdirs1)
  - [Predicate values/3](#-predicate-values3)
  - [Predicate py_is_object/1](#-predicate-pyisobject1)
  - [Predicate items/2, key/2, keys/2](#-predicate-items2-key2-keys2)

## Predicate py_func/3, py_func/4

### XSB version

  - **py_func**(+Module, +Function, ?Return)<br>
  - **py_func**(+Module, +Function, ?Return, +Options)<br>
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

### SWI-Prolog version

  - **py_func**(+Module, +Function, -Return)<br>
  - **py_func**(+Module, +Function, -Return, +Options)<br>
    Call Python `Function` in `Module`. The SWI-Prolog implementation is
    equivalent to `py_call(Module:Function, Return)`. See
    `py_call/2` for details.

      - Compatibility
        PIP. See `py_call/2` for notes. Note that, as this
        implementation is based on `py_call/2`, `Function`
        can use changing, e.g., `py_func(sys, path:append(dir), Return)`
        is accepted by this implementation, but not portable.

## Predicate py_dot/3, py_dot/4, py_dot/5

### XSB version

  - **py_dot**(+ObjRef, +MethAttr, ?Ret, +Prolog_Opts)<br>
  - **py_dot**(+ObjRef, +MethAttr, ?Ret)<br>
Applies a method to `ObjRef` or obtains an attribute value for `ObjRef`.
As with `py_func/[3,4]`, `ObjRef` is a Python object reference in term
form or a Python module. A Python object reference may be returned by
various calls, such as initializing an instance of a class: [^4]

- If `MethAttr` is a Prolog compound term corresponding to a Python
  method for `ObjRef`, the method is called and its return unified with
  `Ret`.

- If `MethAttr` is a Prolog atom corresponding to the name of an
  attribute of `ObjRef`, the attribute value (for `ObjRef`) is accessed
  and unified with `Ret`.

Both the Prolog options (`Prolog_Opts`) and the handling of Python paths
is as with `py_func/[3,4]`.

**Error Cases**

- `py_dot/4` is called with an uninstantiated option list

  - `instantiation_error`

- The option list `py_dot/4` contains an improper element, or
  combination of elements.

  - `domain_error`

- `Obj` is not a Prolog atom or Python object reference

  - `type_error`

- `MethAttr` is not a callable term or atom.

  - `type_error`

- `MethAttr` does not correspond to a Python method or attribute for
  `PyObj`

  - `misc_error`

- If an error occurs when translating an argument of ` MethAttr` to
  Python the actions are as described for ` py_func/[3,4]`.

In addition, errors thrown by Python are caught by XSB and re-thrown as
`misc_error` errors.

### SWI-Prolog version

  - **py_dot**(+Module, +ObjRef, +MethAttr, -Ret)<br>
  - **py_dot**(+Module, +ObjRef, +MethAttr, -Ret, +Options)<br>
    Call a method or access an attribute on the object `ObjRef`. The
    SWI-Prolog implementation is equivalent to `py_call(ObjRef:MethAttr,
    Return)`. See `py_call/2` for details.

    |          |                                                       |
    | -------- | ----------------------------------------------------- |
    | `Module` | is ignored (why do we need that if we have `ObjRef`?) |


      - Compatibility
        PIP. See `py_func/3` for details.

## Predicate py_call/1, py_call/2, py_call/3

### XSB version

  - **py_call**(+Form, -Ret, +Opts)<br>
  - **py_call**(+Form, -Ret)<br>
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

### SWI-Prolog version

  - **py_call**(+Call)<br>
  - **py_call**(+Call, -Return)<br>
  - **py_call**(+Call, -Return, +Options)<br>
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
        `values/3`, `keys/2`, etc. provide portable
        access to the data in the dict.

## Predicate py_free/1

### XSB version

  - **py_free**(+ObjRef)<br>
In general when `janus` bi-translates between Python objects and Prolog
terms it performs a copy: this has the advantage that each system can
perform its own memory management independently of the other. The
exception is when a reference to a Python object is passed to XSB. In
this case, Python must explicitly be told that the Python object can be
reclaimed, and this is done through ` py_free/1`.

**Error Cases**

- `ObjRef` is not a Python object reference. (Only a syntax check is
  performed, so no determination is made that `ObjRef` is a *valid*
  Python object reference

  - `type_error`

### SWI-Prolog version

  - **py_free**(+Obj)<br>
    Immediately free (decrement the reference count) for the Python
    object `Obj`. Further reference to `Obj` using e.g.,
    `py_call/2` or `py_free/1` raises an
    `existence_error`. Note that by decrementing the reference count, we
    make the reference invalid from Prolog. This may not actually delete
    the object because the object may have references inside Python.

    Prolog references to Python objects are subject to atom garbage
    collection and thus normally do not need to be freed explicitly.

      - Compatibility
        PIP. The SWI-Prolog implementation is safe and normally
        reclaiming Python object can be left to the garbage collector.
        Portable applications may not assume garbage collection of
        Python objects and must ensure to call `py_free/1`
        exactly once on any Python object reference. Not calling
        `py_free/1` leaks the Python object. Calling it
        twice may lead to undefined behavior.

## Predicate py_pp/1, py_pp/2, py_pp/3

### XSB version

  - **py_pp**(+Stream, +Term, +Options)<br>
  - **py_pp**(+Stream, +Term)<br>
  - **py_pp**(+Term)<br>
Pretty prints a `janus` Python term. By default, the term is translated
to Python and makes use of Python’s `pprint.pformat()`, which produces a
string that is then returned to Prolog and written out. If the option
`prolog_pp(true)` is given, the term is pretty printed directly in
Prolog. As an example

    pydict([''(name,'Bob'),''(languages,['English','French','GERMAN'])]).

is pretty-printed as

    {
      name:'Bob',
      languages:[
       'English','
       'French',
       'GERMAN'
      ]
    }

Such pretty printing can be useful for developing applications such as
with `jns_elastic`, the `janus` Elasticsearch interface which
communicates with Elasticsearch via (sometimes large) JSON terms.

### SWI-Prolog version

  - **py_pp**(+Term)<br>
  - **py_pp**(+Term, +Options)<br>
  - **py_pp**(+Stream, +Term, +Options)<br>
    Pretty prints the Prolog translation of a Python data structure in
    Python syntax. This exploits `pformat()` from the Python module
    `pprint` to do the actual formatting. `Options` is translated into
    keyword arguments passed to pprint.`pformat()`. In addition, the
    option `nl(Bool)` is processed. When `true` (default), we use
    pprint.`pp()`, which makes the output followed by a newline. For
    example:

    ``` code
    ?- py_pp(py{a:1, l:[1,2,3], size:1000000},
             [underscore_numbers(true)]).
    {'a': 1, 'l': [1, 2, 3], 'size': 1_000_000}
    ```

      - Compatibility
        PIP

## Predicate py_add_lib_dir/1, py_add_lib_dir/2

### XSB version

  - **py_add_lib_dir**(+Path, +FirstLast)<br>
  - **py_add_lib_dir**(+Path)<br>
The convenience and compatibility predicate `py_add_lib_dir/2` allows
the user to add a path to the end of `sys.path` (if ` FirstLast = last`
or the beginning (if `FirstLast = fiast`. `py_add_lib_dir/1` acts as
`py_add_lib_dir/2` where ` FirstLast = last`.

When adding to the end `sys.path` this predicate acts similarly to XSB’s
`add_lib_dir/1`, which adds Prolog library directories.

### SWI-Prolog version

  - **py_add_lib_dir**(+Dir)<br>
  - **py_add_lib_dir**(+Dir, +Where)<br>
    Add a directory to the Python module search path. In the second
    form, `Where` is one of `first` or `last`.
    `py_add_lib_dir/1` adds the directory as
    first. The property `sys:path` is not modified if it already
    contains `Dir`.

    `Dir` is in Prolog notation. The added directory is converted to an
    absolute path using the OS notation.

    The form <span class="pred-ext">py_add_lib_dir/0</span> may only
    be used as a *directive*, adding the directory from which the
    current Prolog source is loaded at the head of the Python search
    path. If `py_add_lib_dir/1` or
    `py_add_lib_dir/2` are used in a directive and
    the given directory is not absolute, it is resolved against the
    directory holding the current Prolog source.

      - Compatibility
        PIP. PIP only describes
        `py_add_lib_dir/1`.

## Predicate py_lib_dirs/1

### XSB version

  - **py_lib_dirs**(?Path)<br>
This convenience and compatibility predicate returns the current Python
library directories as a Prolog list.

### SWI-Prolog version

  - **py_lib_dirs**(-Dirs)<br>
    True when `Dirs` is a list of directories searched for Python
    modules. The elements of `Dirs` are in Prolog canonical notation.

      - Compatibility
        PIP

## Predicate values/3

### XSB version

  - **values**(+Dict, +Path, ?Val)<br>
Convenience predicate and compatibility to obtain a value from a
(possibly nested) Prolog dictionary. The goal

`values(D,key1,V)`

is equivalent to the Python expression `D[key1]` while

`values(D,[key1,key2,key3],V)` v is equivalent to the Python expression

`D[key1][key2][key3]`

There are no error conditions associated with this predicate.

### SWI-Prolog version

  - **values**(+Dict, +Path, ?Val)<br>
    Get the value associated with `Dict` at `Path`. `Path` is either a
    single key or a list of keys.

      - Compatibility
        PIP. Note that this predicate handle a SWI-Prolog dict, a {k:v,
        ...} term as well as py({k:v, ...}.

## Predicate py_is_object/1

### XSB version

  - **py_is_object**(+Obj)<br>
Succeeds if `Obj` is a Python object reference and fails otherwise.
Different Prologs that implement Janus will have different
representations of Python objects, so this predicate should be used to
determine whether a term is a Python Object.

### SWI-Prolog version

  - **py_is_object**(@Term)<br>
    True when `Term` is a Python object reference. Fails silently if
    `Term` is any other Prolog term.

      - Errors
        `existence_error(py_object, Term)` is raised of `Term` is a
        Python object, but it has been freed using
        `py_free/1`.
      - Compatibility
        PIP. The SWI-Prolog implementation is safe in the sense that an
        arbitrary term cannot be confused with a Python object and a
        reliable error is generated if the references has been freed.
        Portable applications can not rely on this.

## Predicate items/2, key/2, keys/2

### XSB version

  - **keys**(+Dict, ?Keys)<br>
  - **key**(+Dict, ?Keys)<br>
  - **items**(+Dict, ?Items)<br>
Convenience predicates (for the inveterate Python programmer) to obtain
a list of keys or items from a Prolog dictionary. There are no error
conditions associated with these predicates.

The predicate `key/2` returns each key of a dictionary on backtracking,
rather than returning all keys as one list, as in `keys/2`.

### SWI-Prolog version

  - **keys**(+Dict, ?Keys)<br>
    True when `Keys` is a list of keys that appear in `Dict`.

      - Compatibility
        PIP. Note that this predicate handle a SWI-Prolog dict, a {k:v,
        ...} term as well as py({k:v, ...}.

  - **key**(+Dict, ?Key)<br>
    True when `Key` is a key in `Dict`. Backtracking enumerates all
    known keys.

      - Compatibility
        PIP. Note that this predicate handle a SWI-Prolog dict, a {k:v,
        ...} term as well as py({k:v, ...}.

  - **items**(+Dict, ?Items)<br>
    True when `Items` is a list of Key:Value that appear in `Dict`.

      - Compatibility
        PIP. Note that this predicate handle a SWI-Prolog dict, a {k:v,
        ...} term as well as py({k:v, ...}.
