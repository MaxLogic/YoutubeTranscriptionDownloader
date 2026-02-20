---
url: https://www.youtube.com/watch?v=MhN9KgaHUMY
title: New EASY Button for Publishing Public Domain
channel: The Nerdy Novelist
created: 2026-01-09
uploader: The Nerdy Novelist
view_count: 2098
like_count: 90
comment_count: 4
tags: storytelling, how to write a novel, how to plot a novel, worldbuilding, chat gpt, chatgpt, claude, sudowrite, ai writing, writing with artificial intelligence, anthropic, open ai, openai, sudo write
description: Write more books with AI (12+ in a year). Join the Story Hacker waitlist and get the actual prompts I use for FREE while you wait: https://www.skool.com/story-hacker/about

My Favorite Tools for Authors (UPDATED):

N8N (via Hostinger) for Automations: https://storytellingdb.com/go/n8n-hostinger
Novelcrafter (for hands-on authors): https://storytellingdb.com/go/novelcrafter
RaptorWrite (for authors on a budget): https://storytellingdb.com/go/raptorwrite
Autocrit (best editing program): https://storytellingdb.com/go/autocritlifetime
Perplexity (best chatbot): https://storytellingdb.com/go/perplexity
---

All right. Today we're showing off
another automation that I've put
together. And this one will be a little
bit interesting because it's not the
kind of thing that a lot of people would
think about, but it's actually extremely
useful if you are interested in
publishing any kind of public domain
content. I've had a fair amount of
success with public domain content. At
least, you know, nothing huge, but I
usually get a couple hundred dollars a
month from it. And it's a relatively
simple thing to be able to create. But
there are a few little parts of the
process that are actually really
difficult. And the biggest of these is
kind of creating a clean version of your
text. Because if you go online looking
for a public domain text to publish, you
will find a number of different
versions. But there are often a lot of
problems with the manuscript, especially
if you're trying to copy and paste it
into a formatter like Vellum or Attacus
because there's often like little
footnotes and things or misspelled
words. Sometimes it was created using
OCR software uh where it was looking at
literally scanning a physical page and
then trying to come up with the text
from that. and there's all kinds of
errors in it. Regardless, there are a
ton of reasons why it's difficult to
have a clean version of the manuscript.
And so, I created this automation to
essentially negate that problem and make
the public domain text perfectly suited
and ready for formatting. So, let me
show you exactly what that looks like.
All right, so this is the automation
here. Fairly very fairly simple looking.
Um, but the way this works is we grab
two documents. First is going to be the
document where the clean version, the
cleaned up version is going to go. And
when I say clean, I mean clean of little
artifacts and footnotes and other things
that we don't want in there, not like a
clean like content clean uh type of
document. And uh and then we grab the
original public domain document. So,
what I do is I go out and I grab a I
just kind of copy and paste the whatever
I can find out there for the public
domain book that I'm wanting to publish.
I just sort of copy and paste it into a
Google doc. And I don't worry about it
too much. The only sort of
post-processing that I will do manually
is I will go through the chapter
headings for these and I will often give
it an H1 or H2 heading. However, you
don't really have to do that with this
particular automation because it's not
going to be going chapter by chapter.
It's going to be going by every thousand
words. Sometimes chapters are so big
that I actually don't trust the AI to be
able to handle the whole thing at once
and be able to reproduce it verbatim uh
with everything I need it to. I'm I'm
worried that it might like accidentally
shorten it or something like that. So, I
go by a thousand word chunks instead.
And this is for this particular public
domain book. This is one that I've
already published. Uh I published an
annotated version of it and I published
a modern pros version of it. All of
which was achieved with the help of AI.
U but as you can see this is a this is
an epic poem that was written in uh I
think the 16th century or or maybe early
17th century. Um, and uh, so it's been
about 400 years since and there's a lot
of really weird
spellings and stuff. Uh, like if you see
here, unfitter task, but the the U is a
V. And this was pretty common in a lot
of, uh, older texts like that, you have
U's and V's are a little bit
interchangeable. You also see Fs and S's
um, often interchangeable. And so I
wanted to clean this up, not to change
the words because I want the words to
say the same, but just to update the
spelling so it's a little less
confusing. Um, as well as remove any
kind of artifacts. I mean, it was mostly
spelling for this one. Uh but sometimes
you do get a lot of things that you
don't want in there like um like page
numbers uh which sometimes get in there
uh or or paragraph symbols or footnotes
uh endotes that kind of thing. We want
to strip all of that out so we just have
the text itself very nicely formatted.
And so this automation, what it does is
it pulls in those two documents, the the
original public domain document that I
just showed you and a blank document
where the cleaned up version is going to
go. And then this is a little bit of
code that splits the original document
into 1,00 word chunks. Okay, so this is
a really handy thing to have um because
it makes it into a little bit more of a
manageable thing that we can then
process through an AI text. However, I
didn't want this to just split into
random uh thousandword chunks because
what if that ends up in the middle of a
sentence, right? So, what this code
does, and once again, I am not a coder,
but I use tools like Perplexity to vibe
code a little bit of what I need here.
This is what the code looks like. Um,
it's fairly simple. Not too much to it.
Um, but what this does, it is it divides
it into a thousand word chunks, but then
it searches for the next period. so that
it actually divides it a few words after
the thousand words at the end of the the
next sentence. That way it kind of keeps
everything together. So we're not
dividing the chunks in the middle of a
sentence cuz that would be kind of
confusing for the AI later. So I have it
do that and then it runs this loop on
each of the thousandword chunks. And we
have just one thing here um which
currently is being done by Gemini 2.5
Flash. Although now I could probably uh
update this to Gemini 3 flash because
that is out now. That's going to be a
little bit more effective. And the
prompt looks something like this. Here's
the section of public domain text you
will analyze and it pulls in the text
here. Your task is to create a cleaned
up version of the above text. Here are
some things to watch out for. Number
one, look for spellings that are
different than modern English. Change
these spellings to more modern English
spellings, but do not change the word
itself. Make sure the original text is
still outputed just with more modern
spellings so as not to confuse the
readers. Number two, remove any
footnotes or references to footnotes
within the text. Number three, format
grammar appropriately according to
modern Chicago manual of style. However,
do not change the sentence structure or
change the meaning of the original text
in any way. If there is a conflict, air
on the side of sticking to the original
style or grammar. Number four, if
formatting poetry, use the same line
breaks and original stanza length. Uh,
always utilize the same line breaks,
paragraph breaks, etc. as the original.
Number five, make sure to maintain the
same capitalization used in the original
text. Number six, the text you receive
may be poorly transcribed text from OCR
software. Like the [snorts] older text,
make sure the spellings and grammar
match the original intended words,
fixing the errors from the OCR software.
Uh, just in case that's what we're
running into. Note, if your text
includes a chapter or section title,
examples include, but are not limited
to, chapter, blank, prologue, epilog,
preface, kanto, etc. then format these
on a separate line using markdown for an
H1 header examples here. So that's where
I tell it to basically if it finds a
chapter header at some point in the in
the story in the um the text to make
that a heading and that's going to be
important. Uh, so then I just give it
this information about how to format the
thing. And it will now run this on each
of the thousandword chunks. And then
once it's done that, it will add it to
the um cleaned up document that we
pulled in here. It will add it to that
and then continue the loop and continue
the process for the whole thing. And so
to give you an idea of what this looks
like, here is the cleaned up version of
that same text. Um, so you'll notice
there were a couple of things in here
that it was getting wrong, uh, or that
just had weird spelling like containing
with a Y. That is now just containing.
Um, we have shepherds.
Um, but this unfitter task here is what
I'd like to look at. Let's look at where
that is. And yep, we now it now says
unfitter task. So the words are still
accurate words, but it's now cleaned up
and looking a little bit now. it will
sometimes leave certain words in there
if it kind of if there's not really a
good real world equivalent like if it
would have to change the word it leaves
the word there. So, you'll see a few of
those in here, but on the whole, this is
a much more cleaned up version that is
really useful. And you'll notice that
the uh title here is an H1 heading. And
if I move on to Kanto one, uh that is an
H1 heading. And this makes it super easy
for me to just download this Google Doc
and as a as a docs file and then upload
it to a formatting tool like Attekus.
Makes it so much easier to just go
through and go through that process. And
I'll actually show you what this uh what
it looks like in Attekus or rather I
will show you what it looks like in its
fully formatted PDF version. So here I
have it all with the table of contents
and everything. And here we have the
preface, the first book of the fairy
queen containing the legend of the night
of the red cross at war of holiness.
There's the unfitter task right there.
So it just puts everything here. And
then I actually have some
um notes and annotations and things that
I added in there myself. But that's a
separate automation. Uh, so you can see
it looks very nice and I was very happy
with this. So this is this saved me so
much time having to rather than having
to do a lot of this work myself, just
being able to clean everything up. And
if you know, you know, like if you've
tried to do any uh public domain
publishing in the past, getting that
manuscript from a random place on the
internet to the point where it is
publishable and clean and looking nice
is a bit of a headache. So, this really
has been a extremely helpful automation
for me personally. Now, I realize not
everybody's going to be into this, but I
have found it to be a really good time.
So hopefully this has been a useful
video for you and I will see you in the
in the next
