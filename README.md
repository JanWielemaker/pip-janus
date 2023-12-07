# pip-janus

## XSB conversion

    pandoc -f latex -t gfm janus-man.tex -o janus-xsb.md

## SWI conversion

Use `packages/swipy/janus.html` as produced by the normal build.

    pandoc -t gfm -o janus-swi.md janus.html
	sed -i 's/\\_/_/g' janus-swi.md

## Merging

Currently only for Prolog predicates.

    swipl tools/merge.pl --interleave janus-xsb.md janus-swi.md janus-merged.md
