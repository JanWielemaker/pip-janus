  - **py_type**(`+ObjRef, -Type:atom`)<br>
    True when `Type` is the name of the type of `ObjRef`. This is the
    same as `type(ObjRef).__name__` in Python.

      - Compatibility
        PIP

  - **py_isinstance**(+ObjRef, +Type)<br>
    True if `ObjRef` is an instance of `Type` or an instance of one of
    the sub types of `Type`. This is the same as `isinstance(ObjRef)` in
    Python.

    |        |                                                                             |
    | ------ | --------------------------------------------------------------------------- |
    | `Type` | is either a term `Module:Type` or a plain atom to refer to a built-in type. |


      - Compatibility
        PIP

  - **py_module_exists**(+Module)<br>
    True if `Module` is a currently loaded Python module or it can be
    loaded.

      - Compatibility
        PIP

### Handling Python errors in Prolog

If <span id="idx:pycall2:11"></span>[py_call/2](#py_call/2) or one of
the other predicates that access Python causes Python to raise an
exception, this exception is translated into a Prolog exception of the
shape below. The library defines a rule for
<span id="idx:printmessage2:12"></span><span class="pred-ext">print_message/2</span>
to render these errors in a human readable way.

> `error(python_error(ErrorType, Value)`, _)

Here, `ErrorType` is the name of the error type, as an atom, e.g.,
`’TypeError'`. `Value` is the exception object represented by a Python
object reference. The `library(janus)` defines the message formatting,
which makes us end up with a message like below.

``` code
?- py_call(nomodule:noattr).
ERROR: Python 'ModuleNotFoundError':
ERROR:   No module named 'nomodule'
ERROR: In:
ERROR:   [10] janus:py_call(nomodule:noattr)
```

The Python *stack trace* is handed embedded into the second argument of
the `error(Formal, ImplementationDefined)`. If an exception is printed,
printing the Python backtrace, is controlled by the Prolog flags
`py_backtrace` (default `true`) and `py_backtrace_depth` (default `4`).

  - Compatibility
    PIP. The embedding of the Python backtrace is SWI-Prolog specific.

## Compatibility to the XSB Janus implementation

We aim to provide an interface that is close enough to allow developing
Prolog code that uses Python and visa versa. Differences between the two
Prolog implementation make this non-trivial. SWI-Prolog has native
support for *dicts*, *strings*, *unbounded integers*, *rational numbers*
and *blobs* that provide safe pointers to external objects that are
subject to (atom) garbage collection.

We try to find a compromise to make the data conversion as close as
possible while supporting both systems as good as possible. For this
reason we support creating a Python dict both from a SWI-Prolog dict and
from the Prolog term `py({k1:v1, k2:v2, ...})`. With `py` defined as a
prefix operator, this may be written without parenthesis and is thus
equivalent to the SWI-Prolog dict syntax. The `library(janus)` library
provides access predicates that are supported by both systems and where
the SWI-Prolog version supports both SWI-Prolog dicts and the above
Prolog representation. See
<span id="idx:items2:31"></span>[items/2](#items/2),
<span id="idx:values3:32"></span>[values/3](#values/3),
<span id="idx:key2:33"></span>[key/2](#key/2) and
<span id="idx:items2:34"></span>[items/2](#items/2).

Calling Python from Prolog provides a low-level and a more high level
interface. The high level interface is realized by
<span id="idx:pycall23:35"></span>[py_call/\[2,3\]](#py_call/2) and
<span id="idx:pyiter23:36"></span>[py_iter/\[2,3\]](#py_iter/2). We
realize the low level interfaces
<span id="idx:pyfunc34:37"></span>[py_func/\[3,4\]](#py_func/3) and
<span id="idx:pydot45:38"></span>[py_dot/\[4,5\]](#py_dot/4) on top of
<span id="idx:pycall2:39"></span>[py_call/2](#py_call/2). The interface
for calling Prolog from Python is settled on the five primitives
described in [section 5](#sec:5).

We are discussing to minimize the differences. Below we summarize the
known differences.

  - SWI-Prolog represents Phyton dicts as Prolog dicts. XSB uses a term
    py({k:v, ...}), where the `py()` wrapper is optional. The predicate
    <span id="idx:pyisdict1:40"></span>[py_is_dict/1](#py_is_dict/1)
    may be used to test that a Prolog term represents a Python dict. The
    predicates <span id="idx:values3:41"></span>[values/3](#values/3),
    <span id="idx:keys2:42"></span>[keys/2](#keys/2),
    <span id="idx:key2:43"></span>[key/2](#key/2) and
    <span id="idx:items2:44"></span>[items/2](#items/2) can be used to
    access either representation.
  - SWI-Prolog allows for `prolog(Term)` to be sent to Python, creating
    an instance of [janus.Term()](#janus.Term\(\)).
  - SWI-Prolog represents Python object references as a *blob*. XSB uses
    a term. The predicate
    <span id="idx:pyisobject1:45"></span>[py_is_object/1](#py_is_object/1)
    may be used to test that a Prolog term refers to a Python object. In
    XSB, the user *must* call
    <span id="idx:pyfree1:46"></span>[py_free/1](#py_free/1) when done
    with some object. In SWI-Prolog, either
    <span id="idx:pyfree1:47"></span>[py_free/1](#py_free/1) may be
    used or the object may be left to the Prolog (atom) garbage
    collector.
  - Prolog exceptions passed to Python are represented differently.
  - When calling Prolog from Python and relying on well founded
    semantics, only *plain truth values* (i.e., `janus.undefined` are
    supported in a portable way. *Delay lists*, providing details on why
    the result is undefined, are represented differently.
