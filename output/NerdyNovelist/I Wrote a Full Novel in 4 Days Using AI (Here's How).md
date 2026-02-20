---
url: https://www.youtube.com/watch?v=wDsemy0YhEs
title: I Wrote a Full Novel in 4 Days Using AI (Here's How)
channel: The Nerdy Novelist
created: 2025-11-05
uploader: The Nerdy Novelist
view_count: 21761
like_count: 851
comment_count: 139
tags: storytelling, how to write a novel, how to plot a novel, worldbuilding, chat gpt, chatgpt, claude, sudowrite, ai writing, writing with artificial intelligence, anthropic, open ai, openai, sudo write
description: Write more books with AI (12+ in a year). Join the Story Hacker waitlist and get the actual prompts I use for FREE while you wait: https://www.skool.com/story-hacker/about

My Favorite Tools for Authors (UPDATED):

N8N (via Hostinger) for Automations: https://storytellingdb.com/go/n8n-hostinger
Novelcrafter (for hands-on authors): https://storytellingdb.com/go/novelcrafter
RaptorWrite (for authors on a budget): https://storytellingdb.com/go/raptorwrite
Autocrit (best editing program): https://storytellingdb.com/go/autocritlifetime
Perplexity (best chatbot): https://storytellingdb.com/go/perplexity
---

The single biggest bottleneck for most
authors is time. We have the ideas, we
have the outlines, but turning that into
a polished book is a marathon that can
take years. What if I told you you could
turn that marathon into a 4-day sprint?
Hi guys, my name is Jason. I'm the nerdy
novelist. I used to work for Kindle
Prneer, one of the largest author
training websites, which taught me a
whole lot of things about the author
process. And uh now I teach authors how
to write with AI in order to get their
ideas onto the page using it as a
productivity tool without compromising
your creativity or your ethics. And um I
ran an experiment on my own novel. And
in this video I'm going to show you how
I used AI to create a genuinely clean,
well-written first draft in just a few
days. And why I believe this could allow
me to publish a new book based on my own
ideas every 2 weeks or so. Now, when I
say I wrote a novel in four days, I need
to be completely honest. I did cheat a
little bit. Uh the foundation of the
book, meaning the detailed outline, was
something I had written a long time ago.
So, I've had that in my back pocket for
a while. Um this wasn't just a throwaway
story. This was book five in one of my
established fantasy series. It's
actually this fantasy series right here.
Uh this fantasy series is really
important to me because this is the
fantasy series that I burned out on. I
wrote the first two books. Uh I was
halfway through the third when I
released the first two books and it
absolutely tanked. Um and the reason was
it was I had not targeted the genre very
well and uh the cover that you see and
the title uh that you see here is
actually different than what I initially
published. Um but I was expecting a lot
from it. I was expecting to make a lot
of money from it and it ended up doing
worse than the previous series that I
had published which was my first and so
writing book five it's actually the
first one I've completed in years and I
used AI to do it and because it was book
five in a series it was very important
that it feel like my story and that it
sounded like me. So that was a priority
for me as I was going into this project.
Now the engine behind this entire
operation is an automation that I built
in a tool called N8N. Think of it like a
digital assembly line. You create a
series of steps that take information
from one place, process it and send it
somewhere else all automatically. And
for this project, its job was to feed
the AI into a variety of different
models u in different steps getting
everything it needed to write one
chapter at a time exactly to my
specifications. And for every single
chapter it wrote, it was given the
detailed scene by scene outline, full
character sheets for everyone involved,
a worldbuing bible, and even samples of
my writing from my previous four books
to use as a stylistic guide. It was a
massive amount of information, but it
was necessary to ensure that Claude and
the other models didn't just write a
generic fantasy scene, but a scene that
belonged in my universe and sounded like
it came from me. I want to quickly show
you what this automation looks like.
It's the kind of thing that looks
complicated at first glance, but the
logic is pretty simple once you break it
down. So, this is the automation right
here. There are a number of steps here.
The first few, you can see these are all
just grabbing documents from Google
Docs. Uh, I use Google Docs for all my
automations. I find it's the simplest
and easiest and, uh, most people have
Google Docs, so they're able to do this.
Um, but basically what happens is I just
click a button uh, this one right here.
It says execute workflow and it will run
through this process and uh I
specifically give it my outline, my
characters, my world building, sample
pros, a stylesheet based on that sample
pros, a list of forbidden words that I
don't want it to be using and so words
that AI uses quite a bit. Uh as well as
I I bring in the document where I want
the finished text to go. So, if you're
just starting on this project, this
document will be one that you create and
is blank when you start. But you'll need
that. And the re the way I'm able to
call all of these things is if you click
on one of these, it has the document ID,
which you can just get in the URL of
whatever document you're doing. U you do
also have to connect NADN to your Google
Docs account. And this this overview is
I'm not going to tell you how to set up
NADN. We do have resources for that in
my story hacker gold group. And I'll
make more videos about uh n and
everything. That's not really the
purpose of this video. I'm just sort of
showing you the workflow. So, we pull in
all of these documents. And then I use
this node. Uh it has a prompt here that
says, "You are a parser. Given the above
book outline text, return a JSON array
named chapters containing each chapter
title exactly as it appears, one element
per title, including those without
numbers like prologue or epilogue. Make
sure the chapter numbers are also
present where listed. do not include any
additional keys only output valid JSON
and sometimes I'll say actually I
specifically want you to do these
specific chapters not all of the
chapters what that does is it then makes
a list of chapters and from there they
get parsed in this node right here and
we start a loop so this this thing right
here uh goes through each of those
chapters that were listed in the
previous step that were parsed out and
it creates a loop that then goes goes
chapter by chapter through each of them
and writes the whole thing. So, in
theory, you could give it an outline and
let this go and it would go through your
entire book and write the whole thing
all at once in uh and yeah, I found that
that took me about 2 hours for it to go
through a 40 chapter outline and
actually write all 40 chapters. That was
expensive. I don't actually recommend
doing it all at once like that, but it
was uh you know, it was for science. Um,
so then, um, if you're writing the first
chapter, these two steps won't matter,
but, uh, I like it to be able to read
the previous 2,000 words or so. Uh, you
could also change this to be three,
four, 5,000 words, however many you
want. Um, but I just like it to know
basically what happened in the last
chapter, so it can continue off of the
end of that last chapter in a way that
is uh that makes sense, that is
seamless. Uh so we grab the last 2,000
words of the chapter and then we run
through these four steps uh four AI
uh models different models for each of
these except these last two are the
same. Uh and once it goes through those
four steps it then takes that chapter
that it has written and it plops it into
your document that you pulled in
earlier. So we this note is just called
add chapter to document. uh and then it
goes to this and replays the loop. But
on the next loop, it if you started with
chapter one, it will go on to chapter
two and so on. Uh so it's a very handy
loop. Uh you can kind of just press
execute and don't worry about it until
it's finished the number of chapters you
want. Uh but these four steps, there's
four of them. There's um the first one
is creating a scene brief. So I'll show
you a little bit of what that prompt
looks like. So, we pull in the outline,
the characters, the world building, the
previous chapter text, and then I have
it create a scene brief to sort of spell
out what should happen in this specific
scene, and uh who are the characters
involved, what are they doing, how are
they, what's their mood in this
particular chapter, what are they
wearing in this particular chapter,
because their physical appearance might
be slightly different from one chapter
to another. And this was actually useful
because I had like a character that got
injured in one chapter. And because I
was doing the scene brief and it was
able to look at the last 2,000 words, it
knew that the character was injured um
and it was also looking at the outline.
So, it was able to derive from that that
the character was injured and it was
able to pass that information on into
the next chapter it was writing. Had it
not done that, um it would have just
like he would have been injured in the
previous chapter and in the next chapter
he would have just been fine. Um, so,
uh, it's important to be able to let it
have that level of awareness of the
chapter. So, it creates the scene brief,
uh, to give it all of the details that
it needs for that specific scene. And
then we move on to the most important
step, which is the first draft. Uh, by
the way, the I'm using Sonnet 4.5 for
the scene brief right now, but for the
first draft, I'm using Opus 4.1. Um, it
opus is an expensive model and I
literally throw the entire kitchen sink
at it in this particular prompt. So, it
is this is not an this is an expensive
step. It would cost me about 75 cents
per chapter for just this step.
Everything altogether was costing me
about a dollar per chapter. U, but it's
worth it to me because I get good pros
out of Opus, better than than Sonet 4.5
and a lot of any other model that I've
tested. Um, so first I give it the style
sheet and the style pros examples from
my text. I also give it the prohibited
words that I don't want it to use. I
give it full context including the
entire outline, the characters, and the
world building. I give it the previous
2,000 words of text so it knows where to
start off from. And I give it the scene
brief that was generated in the previous
step. I then go through a couple of
instructions here on what to do and let
it go. And then from there
it writes the first chapter. Now, as we
all know, if we've worked with AI a lot,
there's all kinds of little AISMs and
little quirks and cliches and uh things
that are a little bit dull about uh AI
writing. And while Opus 4.1 is very
good, it's got better like scene
cohesion and everything that I've seen
from any other model, it still has some
of those things in it. And so these next
two steps are meant to polish that out a
little bit just to make it a little bit
better for when I then go through it.
Um, so it would go through this
improvement plan and then it would go
through and using that improvement plan,
it does a rewrite. The improvement plan
looks something like this. It's uh I've
got a list of things I wanted to look
for. So like metaphors, identify any
metaphors and instruct them to be
removed. Adverbs. Identify any over
reliance on adverbs. Dialogue tags.
Identify dialogue tags that are not said
or asked. Make suggestions for which
ones should be changed to said or asked.
Um, flag instances of passive voice. So,
stuff like that. I'm just having it go
through and polishing this up just a
little bit so that I don't have to do it
later. And so, it goes through and this
step crucially does not do any rewrite
rewrites. All it does is it highlights
the problems and then in the next step
I'm also not having it do a rewrite. I
ask it to simply implement the suggested
changes but do not in change anything
else about the original chapter. Uh re
reproduce the entire chapter with the
suggested changes. I found that if you
use the word rewrite it will rewrite the
whole thing and it's often worse uh
depending on which model you're using
than the original draft. So instead of
asking for a rewrite, I ask it to just
implement the the changes and not change
anything else. Um, so that's all this
prompt does. And it so it goes through
those and it reproduces the chapter at
the end with all of those changes made
and then adds that chapter to the
document. And then it loops back around
and starts on the next chapter and it
continues to do that. So you could do
this for the entire book all at once.
Um, the reason I don't recommend that is
because I found that uh if it got a
little off on one chapter, and there
were actually instances where it
actually wrote the wrong chapter, I've
since corrected that, but um that was an
issue as I was going through this
project. Um, if it does get a little
off, like even if it's off by one degree
in the next it might be off by two
degrees and then three degrees and then
it just gets worse and worse as it goes
along. Uh, and so I find it's good to
write um, you could go one chapter at a
time and uh, and do that. Uh, that would
take a while though and then you'd have
to wait for the generation to happen in
between each each chapter. So, I found
the sweet spot for me was two to three
chapters where I would have it generate
all three uh while I'm doing something
else and then I'll go through and revise
those chapters and then after I've re
revised those chapters, I have it do the
next two or three chapters and I'll go
to do something else and then I'll come
back and revise those chapters and that
way I was able to get through a bunch of
different chapters all at once. Of
course, every one of these chapters,
especially the ones that I had to
regenerate, came with a literal cost.
The Claude Opus model is not cheap and
it's the best large language model for
creative writing on the market right now
in my opinion, but you pay for that
quality and each chapter cost me on
average about a dollar to generate as I
mentioned. And so for a 40 chapter book,
that's 40 bucks. Factoring in the
handful of chapters I had to regenerate
due to mistakes, the total cost for the
raw first draft was probably closer to
50 or 60. Now people might b at that,
but let's put it in perspective. Would
you pay 60 bucks to have a complete
80,000word first draft of your novel
appear on your computer tomorrow? Like I
have worked with ghost writers and paid
them four $5,000 for a good draft. Now
granted, it is a little bit cleaner and
I can expect more from a ghost rider and
have to guide them a little less than I
do with AI, but at the same time,
[snorts] $40 versus $4,000 is a big
thing for most people. Most people are
not going to be hiring ghostriters,
right? um you're either going to be
writing it yourself or you're going to
be using AI to do it. And so for me, $40
is nothing. $40 is absolutely worth a
clean first draft. And you're going to
get a lot cleaner first draft using Opus
than another model. I've tried this with
uh using Sonet 4.5 for the actual pros
generation, and it just isn't the same.
It's not as good. It's not bad. Uh, but
you're going to be paying for it later
with more time to clean up those drafts
than if you used Opus. At least that's
been my experience. By the way, if you'd
like to learn more about how to use AI
as an author-led productivity tool to
write uh at least 12 books per year, if
not more, and without compromising your
creativity or ethics, go check out the
Story Hacker Gold link down below. You
can also get this exact model that I'm
using uh to use on your own and uh
implement into your own books. So, with
the raw manuscript complete, it was time
for the part of the process that most
authors dread, and that's the first big
edit. But this is also where the title
of this video comes from, because the
actual writing, the generation of the
text only took a few hours of total
processing time spread out over a day or
so. And the human part of the work, the
editing, only took me 4 days. Uh, I had
a simple process. This was a 40 chapter
book. And so, I set a goal of editing
roughly 10 chapters a day. That didn't
take me that long. Um, and it usually
took me between two and two and a half,
maybe three hours for some of the more
complicated parts where the AI really
messed up. But in that amount of time, I
was able to get through 10 chapters and
a lot of it was really good. And there
are actually quite a few moments that I
thought were actually excellent inside
of the book. And and uh I can attribute
this to Opus because Opus is the only
one that does this sort of thing. For
one, I had a moment when two of the
characters were having this quiet
philosophical debate between the merits
of justice versus mercy. And I looked at
the text that it gave me and it was
actually a genuinely thoughtful
philosophical debate. A lot of which was
not provided by me, at least not beat
forbeat, right? Uh I just said they they
debate justice and mercy and this person
has this view and this person has that
view. But then when they came together
um it it was actually a genuinely good
conversation. There was another moment
also when my main character uh she has
this magical ability to uh mirror the
abilities of others and she comes in uh
into contact with this kind of
Lovecraftian entity that's really
horrifying
and she tries to mirror its ability and
it it just uh it just uh it it does not
go well for her and she starts to
transform into this mass of ugly things
and it did this layered
uh really strong showing instead of
telling scene where it just described
her transformation. And it also layered
in like the uh the reactions of other
characters around her because it was
from one of their perspectives watching
her make this transformation. And um and
there are other characters who don't
realize what's going on and they're just
kind of like laughing until they figure
out what's going on and then then they
like start freaking out. And all of the
reactions from each of the characters
cuz there were villains there and allies
there. They were all unique and separate
to each other. Um and not just like the
same reaction from each one. And so I
got moments like that that I was just
like flying through it. I was just like
this is amazing. And then there were
others that where it was not so good and
I had to really uh tighten it up and
spend more time on it. Uh and as I
mentioned there were a couple of times
one of the one of the problems that I
noticed is that sometimes it would write
the wrong chapter. Uh and that's because
in the scene brief steps sometimes it
would get the wrong one and so it would
say okay we're writing this scene and in
fact I wanted a scene that was like
three chapters earlier. That seems to
have been solved with a tweak of the
prompt. But I haven't had a problem with
it since. Uh, but that was something
that happened that caused me to have to
regenerate huge sections of the novel in
order to get it right. And it was
through that process that I figured out
that going two or three chapters at a
time might actually be better than
trying to do uh huge sections at a time.
So, the only real downside to that is
that you you can't like edit 10 chapters
at once because you have to edit a few
then generate more then edit a few then
generate more. And so you're going back
and forth between
um editing a text and then you have to
go do something else for a while while
it's generating the next few because it
does take a little while. It's not like
something where you're going to be um
sitting around for just a few minutes
and then you get the next chapter. Like
it takes for for like three chapters it
would probably take uh 15 20 minutes.
Um, I'd say probably for each chapter it
took about five minutes to go through
all of those steps. [snorts] Um, that's
my that's my rough estimate. Maybe maybe
more. Uh, but yeah. So, I don't like to
be constantly bouncing between things uh
to try and multitask because humans
actually can't multitask properly. So,
uh, I, you know, if I'm going to be
editing text, I'd like to just sit down
and edit all 10 chapters, but that
wasn't really ideal with the way this
worked. But regardless, I was still able
to get it done in four days. 10 chapters
a day. Didn't take me that long overall.
The only reason I couldn't do more was
because I also like I film YouTube
videos and I'm doing other marketing
things and I'm uh administrating in my
group and like all this stuff that I do
in addition to this. Um, but this, you
know, it it was totally doable. And I
think anybody, even if you have a
full-time job or something like that,
you could probably, if you could spare
an hour a day, you could get through
this in a week or so. And if I were to
factor in the cost, uh, the time cost of
creating an outline,
uh, as well as doing like secondary
edits and, uh, formatting and
publishing, I think this would probably
take me about two weeks. Now, I have
sent this manuscript over to a line
editor just to do a second pass on it.
Uh, if you don't have the budget for a
line editor, then uh you would want to
do at least two more passes, I think, on
on it. So, that would take extra time.
Um, but I already knew just from having
read through it uh that I would probably
glaze over a lot of the problems uh that
were that were left in the manuscript.
So, I wanted to get a uh objective third
party to come in and and do a pass on
it. Um, and that's just more for my own
peace of mind that I know that the the
text is going to be decent. So, if this
process sounds exciting to you and you
want to learn my entire framework for
going from a blank page to a finished
book in hand, including how to market
it, you should check out my school
group, Story Hacker Gold. And in there,
we dive deep into how to use AI and
other tools to enhance your process
without ever compromising your
creativity as an author. The group also
includes weekly live calls with me, all
of my ebooks and audiobooks for authors,
and a community of writers who are all
pushing the boundaries of what's
possible. So, if that's interesting to
you, the link is in the description and
I will see you in the next
