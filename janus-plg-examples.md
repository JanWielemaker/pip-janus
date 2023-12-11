## Explanatory Examples

We discuss some of the core functionality of `janus-plg` via a series
of examples. As background, when `janus` is loaded, Python is also
loaded and initialized within the Prolog process, the core Prolog
modules of `janus` are loaded into Prolog, and paths to `janus` and its
sub-directories are added both to Prolog and to Python (the latter paths
are added by modifying Python’s `sys.path`). Later, Prolog calls Python,
Python will search for modules and packages in the same manner as if
they were stand-alone.

<div id="ex:janus-json" class="example">

**Example 1.1**. ***Calling a Python Function (I)** *

**The translation of JSON through `janus-plg` in this example works
well, but for most purposes we recommend using XSB’s native JSON
interface described in Chapter
<a href="#chap:json" data-reference-type="ref"
data-reference="chap:json">[chap:json]</a> of this manual.* *

*Suppose `janus` has been loaded by the command `?- [janus].` and
consider the call:*

    py_func(json,prolog_loads('{"name":"Demo term"
                                "created": {"day":null,
                                            "month":"December",
                                            "year":2007  },
                                "confirmed":true,
                                "members":[1,2,3]}'

*loads the Python `json` module and then calls the Python function*

*`json.loads()`*

*with the above JSON string as its argument. In Python the atom is
parsed and converted into a Python dictionary whose syntax is very close
to that of the JSON. Next, `janus` translates this dictionary to a
Prolog term that can be pretty printed as:*

    {name:'Demo term'),
     created:{day:@(none),
              month:'December',
              year:2007},
     confirmed:@(true),
     members:[1,2,3]}

*The syntactic flexibility of Prolog allows the Python dictionary to be
represented as a logical term whose syntax is very close to that of both
a Python dictionary and a JSON object. We call a term that maps to a
Python dictionary a *(Janus) dictionary term*. Such a term is simply a
Prolog term whose outer functor is `'{}'`/1, whose argument is a comma
list, where the elements of the comma list are attribute-value pairs
(sometimes called key-value pairs) using the predicate `:/2`, where the
attributes and values themselves may contain nested dictionaries, lists,
tuples or sets in accordance with the restrictions of Python
dictionaries.[^2]*

</div>

<div id="jns-examp:glue" class="example">

**Example 1.2**. ***Calling a Python Function (II): Where to Maintain
Python Objects?** *

*A slightly more complex call to Python is to load a JSON object from a
file as opposed to a string. For this, we may use the Python function*

*`json.load(Stream)`*

*which loads a JSON string from a file into a Python dictionary which
can then be translated to Prolog. A small problem arises in that the
input to `json.load()` is a Python input stream (sometimes called a file
pointer `fp` is Python documentation). Python input streams are of
course different than Prolog input streams. This can be handled in
several ways.*

- ***Maintain The Stream Reference in Python***

  *A straightforward solution to the problem is to write a small amount
  of glue code in Python as follows.*

      def prolog_load(File):
          with open(File) as fileptr:
              return(json.load(fileptr))

  *If this code were kept in the file `jns_json.py` the call*

      py_func(jns_json,prolog_load('sample.json'),Json)

  *would unify `Json` with a `janus` dictionary term as in the last
  example.*

- ***Maintain The Stream Reference in Prolog** `janus` also allows the
  user to obtain any Python object reference in Prolog. The goal*

      py_func(builtins,open('sample.json',r),Stream),
      py_func(json,load(Stream),Json),
      py_dot(Stream,close(),Return).

  *makes three calls to Python: one to obtain the Python stream as a
  Python object reference, a second to parse the JSON object from the
  file and load it into Prolog, and a third to close the stream. Note
  that closing a stream requires a method to be applied to a stream
  object rather than a function call, so the `janus` predicate
  ` py_dot/[3,4]` is called instead of `py_func/[3,4]`.*

*Each of these approaches has advantages. Maintaining the stream
reference in Prolog requires no glue code, but does require explicitly
opening and closing the file. Either works well from the viewpoint of
performance: the `janus` interface is so fast that making one call vs.
three calls to Python make no measurable difference (see
Section <a href="#sec:jns-perf" data-reference-type="ref"
data-reference="sec:jns-perf">2.4</a>). of whether to maintain object
references in Python or Prolog is a matter of taste.*

</div>

<div id="ex:jns-kewords" class="example">

**Example 1.3**. ***Calling a Python Function (III): Keyword Arguments**
*

*Python library functions often make heavy use of keyword arguments.
These are easily handled by `py_func/[3,4]` along with other `janus`
functions such as `py_dot/[3,4]` and `py_iter/[3,4]`. Suppose we want to
call the Python function*

*`json.dumps(Dict,indent=2)`*

*where `Dict` is a Python dictionary that is to be written out as a JSON
string. This can easily be called via*

*`py_func(json,dumps(PlgDict,indent=2),Ret)`*

*where `PlgDict` is a Prolog dictionary that is to be converted to the
Python dictionary `Dict`. Note that `py_func/[3,4]` handles keyword
arguments using the same syntax as Python: positional arguments must
occur first in a call followed by 0, 1 or more keyword arguments.*

</div>

The `janus` predicate `py_dot/3` was briefly introduced in
Example <a href="#jns-examp:glue" data-reference-type="ref"
data-reference="jns-examp:glue">1.2</a>. Let’s take a closer look at it.

<div id="jns-examp:method" class="example">

**Example 1.4**. ***Calling a Python Method** *

*Consider the following simple Python class:*

    class Person:
      def __init__(self, name, age, ice_cream=None):
        self.name = name
        self.age = age
        if favorite_ice_cream is None:
          favorite_ice_cream = 'chocolate'
        self.favorite_ice_cream = favorite_ice_cream

      def hello(self,mytype):
        return("Hello my name is " + self.name + " and I'm a " + mytype)

*The call*

        py_func('Person','Person'(john,35),Obj),

*creates a new instance of the `Person` class, and returns a reference
to this instance that can later be used to call a method. We refer to
this reference abstractly as $<obj>$ as the form of a Python object
reference can differ between Prologs that support `janus`. Using this
reference, the goal*

*`py_dot(`$<obj>$`,hello(programmer),Ret2).`*

*returns the Prolog atom:*

*`’Hello my name is john and I’m a programmer’`*

*Note that unlike `py_func/[3,4]` which requires a module as its first
argument, the module is not needed in `py_dot/[3,4]` as the module is
implicit in the object reference.*

</div>

<div id="jns-examp:exam-object" class="example">

**Example 1.5**. ***Examining a Python Object** *

*Example <a href="#jns-examp:method" data-reference-type="ref"
data-reference="jns-examp:method">1.4</a> showed how to create a Python
object, pass it back to Prolog and apply a method to it. Suppose we
create another `Person` instance:*

        py_func('Person','Person'(bob,34),Obj),

*and later want to find out all attributes of `bob` both explicitly
assigned, and default. This is easily done by ` janus:obj_dict/2`:*

*`obj_dict(Obj ,ObjDict ).`*

*returns*

        ObjDict = {name:bob,age:34,favorite_ice_cream:chocolate}

*There are times when using the dictionary associated with a class is
either not possible or not appropriate. For instance, not all Python
classes have `__dict__` methods defined for them, or only a single
attribute of an object might be required. In these cases, ` py_dot/4`
can be used:*

*`py_dot(`$<obj>$`,favorite_ice_cream,I)`*

*returns `I = chocolate`.*

*Summarizing from the previous two examples, `py_dot/[3,4]` can be used
in two ways. If the second argument of a call to `py_dot/4` is a Prolog
structure, the structure is interpreted as a method. In this case, a
Python method is applied to the object, and its return is unified with
the last argument of `py_dot/4`. If the second argument is a Prolog
atom, it is interpreted as attribute of the object. In this case, the
attribute is accessed and returned to Prolog. Note that the
functionality of `py_dot/4` is overloaded in direct analogy to the
functionality of the `’.’` connector in Python.*

</div>

<div id="jns-examp:lazy-ret" class="example">

**Example 1.6**. ***Eager and Lazy Returns** Prolog can either “lazily”
backtrack through solutions to a goal $G$ or “eagerly” return all
solutions to $G$ as a list via ` findall/3` or similar predicates. In an
analogous manner, Python can either 1) return a list or set of returns
via a mechanism such as comprehension; or 2) return solutions one at a
time through the `yield` statement or similar framework¡. `janus`
provides full flexibility in handling both lazy and eager returns.*

*Consider a file `range.py` that contains the following functions:*

      def demo_yield():
        for i in range(10):
            yield i

      def demo_comp():
        return [i for i in range(10)]

*To improve performance, many Python libraries, such as SpaCy and the
RDF-HDT interface to Wikidata, use `yield` to return generators rather
than returning lists or other data structures. ` demo_yield()` may be
considered a function with lazy returns. while ` demo_comp()` may be
considered a function with eager returns.*

*We first address the case of `demo_yield()`.*

***Eager return to Prolog of a eager Python function** This case
reflects the usual behavior of `janus` with most Python functions. An
example is*

*`py_func(range,demo_comp(),Ret).`*

*which unifies `Ret` with the list `[0,1,2,3,4,5,6,7,8,9]`. Such goals
can be extremely efficient in `janus` due to its high-speed translation
of Python data structures.*

***Eager return to Prolog of a lazy Python function** The goal*

*`py_func(range,demo_yield(),YieldObj).`*

*in fact returns the same ten element list as in the previous case that
used `demo_comp()`. The default behavior of `py_func/[3,4]` is that if a
function returns a Python object $O$ that is not of a type directly
handled by bi-translation, $O$ is checked to see whether it is a
generator or has an associated iterator $I_O$. If so the generator or
iterator traversed to return all answers eagerly to Prolog.*

***Lazy return to Prolog of an lazy Python function** If, rather than
using `py_func()` with its default behavior, the goal*

*`py_iter(range,demo_yield(),Return).`*

*is set, `Return` will be unified with the first list element,` 0`,
while the rest of its answers can be returned via backtracking.*

*An alternate approach is to call*

*`py_func(range,demo_yield(),Return,[py_object(true)]).`*

*In this case, `Return` will be unified with a Python object if the
Python function returns any non-base Python data type. Returning an
explicit object through which to iterate may be useful of the object is
needed in Prolog for other purposes. Otherwise it is better to use
`py_iter()` which does not create an explicit Python object reference
that should be freed.*

***Lazy return to Prolog of a eager Python function** If the goal*

*`py_iter(range,demo_comp(),Return).`*

*were called, `py_iter/3` would lazily backtrack through the list
returned by `demo_comp()`, rather than eagerly returning the list.
Similarly*

*`py_func(range,demo_comp(),Return,[py_object(true)]).`*

*will return a Python object reference as in the immediately previous
case.*

</div>

<div id="jns-examp:pycall" class="example">

**Example 1.7**. ***py_call/\[2,3\]** *

*`py_call/[2,3]` provides an alternate syntax for ` py_dot/[3,4]` and
`py_func/[3,4]` (and vice-versa). Rather than calling*

*`py_func(Module,Function,Return)`*

*one may equivalently call*

*`py_call(Module:Function,Return)`*

*and rather than calling*

*`py_dot(Object,Function,Return)`*

*one may equivalently call*

*`py_call(Object:Function,Return)`*

*These equivalences also hold when options are provided for a call.*

</div>

The syntax of `py_func/[3,4]` and `py_dot/[3,4]` is arguably slightly
more “Pythonic” than `py_call/[2,3]`. Python distinguishes between
calling a function and applying a method or obtaining an attribute and
this distinction is maintained when using `py_func/[3,4]` and
`py_dot/[3,4]`. On the other hand, ` py_call/[2,3]` is arguably slightly
more “Prologic”, since it treats module qualification in the same manner
as with Prolog goals, and does not require the user to distinguish
between Python methods and functions. The following example shows how
`py_call/[3.4]` can write concise code.

<div class="example">

**Example 1.8**. *Like many languages, Python allows simple functional
composition – a simple case might be*

    >>> make_squares(make_list(4))

*which makes a list of the first four integers and then squares each
integer in the list producing*

    >>> [1,4,9,25]

*`py_call/2` supports a similar form of recursion, by clothing arguments
in `eval/1`, for instance:*

    ?- py_call(test_janus:squares(eval(test_janus:makelist(4))),Res).

*unifies `Res` with the expected result.*

*Compositions of method application to objects is similar. The goal*

    py_call(returnVal:returnVal({a:b,c:d}),Obj,[py_object(true)]).

*unifies `Obj` with a reference to the Python dictionary object for
`{a:b,c:d}`. Using this binding, the goal*

    py_call(Obj:'__class__':'__name__', Name),

*first finds the Python class for `Obj` and then unifies `Name` with its
string representation.*

</div>

There is no deep difference between `py_call/[2,3]` and the mixture of
`py_func/[3,4]` and `py_dot/[3,4]`. They are merely alternate syntaxes.
In XSB, `py_call/[2,3]` is defined in terms of `py_func/[3,4]` and
`py_dot/[3,4]` and so ` py_func/[3,4]` and `py_dot/[3,4]` are slightly
faster; in SWI it is the reverse. Which form to use is a matter of
taste.
