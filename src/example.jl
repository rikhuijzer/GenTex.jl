example_text() = raw"""
---
title: LaTeX demo
---
# Demo
This is an example text with $x$, $x_2$, $x^3$ and $u \cdot v$.

$$ y = \frac{a + 1}{b + 1^2} $$

We could also write $\frac{z}{2}$ where $z = \{ 1, 2, ..., u \}$.
"""

comment = raw"""
From 'Introduction to Mathematical Statistics':

**Example 1.1.3.** Let $C$ denote the sample space of Example 1.1.2 and let $B$ be the collection of every ordered pair of $C$ for which the sum of the pair is equal to seven. Thus $B = \{ (1,6), (2,5), (3,4), (4,3), (5,2), (6,1) \}$. Suppose that the dice are cast $N = 400$ times and let $f$ denote the frequency of a sum of seven. Suppose that $400$ casts result in $f = 60$. Then the relative frequency with which the outcome was $B$ is $f / N = \frac{60}{400} = 0.15$. Thus we might associate with $B$ a number $p$ that is close to $0.15$, and $p$ would be called the probability of the event $B$. $\blacksquare$
"""

"""
Writes an example Markdown file containing LaTeX to a folder observed by Hugo.
This is useful for debugging.
"""
function show_example!() 
	example = example_text()
	out_path = joinpath(homedir(), "git", "notes", "content", "docs", "jmd", "example.md")
	tmpdir = tempname(cleanup=false) * '/'
	mkdir(tmpdir)
	temp = joinpath(tmpdir, "example.md")
	open(temp, "w") do io
		write(io, example)
	end
	substitute_latex!(temp, out_path, scale=1.6)
	rm(tmpdir, recursive=true)
	println("File written - $(Dates.Time(Dates.now()))"[1:end-4])
end
export show_example!
