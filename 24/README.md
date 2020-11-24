* few bad attempts at this, trying to memoize sums (in case groups were repeated, which they probably wouldn't be a lot?), and only adding when necessary (kept this in), before realizing that only needed to check all groups of the same size, otherwise i could stop as soon as a found that at least one solution was found for a given smallest group...actually i could probably change that filter call to a find for more efficiency

* maybe how it was written, if so really cleverly directed, but because of how the problem description said that if multiple groups of the same size had equal weight, choose the one with the lowest quantum entanglement...i got into all sorts of contortions trying to keep track of when there were multiple groups of the size i was checking. but looking at the description for part two and seeing some of my results from the test made me realize that groupings would be checked twice (e.g. [[A, B], [C, D]] and [[C, D], [A, B]]) so every group of the size to be checked would be first in some iteration and so I could only track the first.

* i like the equation I came up for how deeply I had to check, realizing that going further would just mean checking things that had already been checked, and that I always start at the same size when going deeper in the tree. 

steps = total - (depth + 1) * size / (depth + 1)

2     2       2        24
3     3	      3	       21	...1
4     4	      4	       18	...2
5     5	      5	       15	...3
6     6	      6	       12	...4
7     7	      7	       9	...5

depth = 3, total = 30, size = 2
steps = 30 - (4 * 2) / 4 = 5

* need to clean up code and come up with better names
