---
url: https://www.youtube.com/watch?v=pZs0Ichhl1E
title: This Advanced AI Writing System Writes ENTIRE Books (Step by Step Tutorial)
channel: The Nerdy Novelist
created: 2026-02-04
uploader: The Nerdy Novelist
view_count: 8821
like_count: 403
comment_count: 66
tags: how to write a good book with ai, how to write books using ai, how to write a novel with ai, how to use ai to write a novel, AI novel writing, AI tools for authors, best AI tools for writers, writing fiction with AI, writing nonfiction with AI, book writing techniques, writing automation, n8n automation tutorial, n8n automation ideas, ai tools for content creation, best ai tools for book writing, ai writing, ai writing tool, ai in writing, ai for writing, ai writing tips
description: 🤩 Learn How to Use AI to Write 12+ Successful Books a Year! 
📌 Join the Story Hacker Waitlist & Get FREE AI Prompts today: 
👉 https://www.skool.com/story-hacker/about

Want to write a book but don't have months to spare? I just wrote three full chapters in under an hour using AI automation. In this tutorial, I'm showing you the exact N8N workflow that takes your story outline and automatically generates professional book chapters without any manual writing.

I've been testing this system for years, and it still works. This workflow handles everything from character consistency to world building. But it still keeps everything authentic with your guidance. Watch the video now and learn how AI automation & human creativity can help you write books faster.
_________
🔔 Subscribe for more: https://www.youtube.com/@TheNerdyNovelist?sub_confirmation=1
_________
🌐 Connect on Social Media:

▶ LinkedIn: https://www.linkedin.com/in/jason-hamilton-61bbb526
▶ Instagram: https://www.instagram.com/nerdy.novelist
▶ Facebook: https://www.facebook.com/nerdynovelist
▶ Website: https://storytellingdb.com/
_________
This Advanced AI Writing System Writes ENTIRE Books (Step by Step Tutorial)

#aiwriting #bookwriting #aiworkflow #novelwriting #aiautomation
---

Welcome everybody to another video going
over another N8 automation. And this is
the big one. This is the one I've been
building up to for a number of the last
videos that I've done on automations.
And this is the one that can essentially
create an entire book in just minutes.
Usually about an hour to actually go
through the whole book depending on the
length of your book. Now, I wouldn't
necessarily recommend you do it that
fast, uh, because usually there's some
errors that come in and I tend to go a
chapter at a time or maybe two or three
chapters at a time at most. So,
reviewing it as I go through this
automation, but technically speaking,
you can give it all of your info and
just push a button and it will go
through chapter by chapter and write the
entire thing. If you trust it enough to
be able to do that all the way through
and then you go back through and edit
it, that's fine. Uh, I personally don't
do that. I just go through a couple of
chapters at a time, but I still use this
automation because it still saves me a
huge amount of time. So, let's dive in.
So, the automation in question here is
this particular automation that I've
built. I call it full book automation
colon outline to chapters. And, uh, it's
a great automation. Uh, I have mentioned
it here on the channel before, but I
have updated it a little bit so that it
works a little better. Now, in the past,
I have also shown you these automations.
This one takes all of your brain dump
information and constructs a more
structured dossier for your story about
all the different elements that you
need. And it it's a fun one. I did a
whole video about this one. I did also
another video about this one where you
take that dossier that was just created
in the previous automation. And you run
it through this and it creates some
characters and fully fleshes those out
as well as all of your world world
building elements. Those get all fleshed
out as well. And then you can create a
full outline in this automation as well.
So this is kind of like step one and
step two, right? We go this far and by
the end of this you have a dossier, you
have a character sheet, a world building
sheet and an outline. And for this
automation, this is the natural
continuation of this process where you
take all of those documents and you
create your full book. Okay, so let's
walk through exactly how this works.
First of all, it starts with a form
submission where I just input the name
of the book as well as any additional
notes that I might have, which can be
random. Uh, you know, I don't know
exactly what your needs are going to be.
So, it can be any number of things. So,
I just have a space there for author
notes. And then I have a couple of
documents that we pull in. We get the
pros style guide. And uh I've done
videos about style guides before, but
essentially this is just examples of
your work and uh perhaps even a
structured like you can take samples of
your work and give it to AI and say
develop a style guide based on this pros
that you see and it'll do that. And so I
usually put all of those things together
in one document. And that's my pros
style guide that I pull in here. I also
have a list of forbidden words uh AISMs
and things like that that I wanted to
cut out. So, I have that list that I
pull in. And then we have the three
lists that were created in the previous
step. The character sheet, the world
building sheet, and the outline. And and
so here you can actually see some of
those documents right here. Uh I have uh
for one book that I'm working on. Um
this is my world building document. So
it's uh this was created by AI with a
lot of input from me. So it's basically
just taking what I gave it and sort of
structuring it in a little bit more
organized fashion. and uh it gives me
all of this information. And the same
goes is true for the characters here. So
here's like one character. This is my
main character. This is all the
information we need to know about this
character. Quite a bit of information.
And then I also have an outline. So
here's chapter 1, chapter 2, etc. So
that's what the outline looks like. So
those documents, all three of those are
pulled into this automation via these
nodes right here. And then I have this
node that says get blank first draft
doc. This means that before you start
using this automation, you want to come
in here and actually create a doc where
the first draft is going to go. And it
needs to be blank just to start with
because, you know, obviously we haven't
written the book yet, but we're going to
actually have this one created here. So
now we've got that. We are then ready to
go into the very next step, which is to
find the chapter names in the outline.
So what this one does is it takes a
really low inensity model, looks through
your entire outline, and makes a list of
all of the chapters. The prompt goes
something like this. You are a parser.
Given the above book outline text,
return a JSON array named chapters
containing each chapter title exactly as
it appears, one element per title,
including those without numbers like
prologue and epilog. Make sure the
chapter numbers are also present where
listed, and do not include any
additional keys. Only output valid JSON.
And then you can just leave it at that
if you wanted to do the entire book at
once. But I also add this additional
sentence if I only wanted to work on a
couple of chapters at a time. So I say
in this specific instance, I only want
you to do chapters 1 through three.
Okay. Uh you could also potentially put
this in the initial form and then have
it autopop populate here. That might be
easier for some, but I I don't see that
as being any easier than just coming in
here and modifying this. So in this
case, it will only return chapters one
and through three. But if I remove the
sentence, it would do everything for the
entire book, uh, the entire outline. So
once it has that list of chapters that
it's going to be working on, it parses
[clears throat] them out with this
little code node and then starts a loop
where the first thing that happens in
the loop is it gets the last 2,000 words
from the first draft document. Now, if
we're writing chapter 1, there is no
past 2,000 words. So, it'll just bring
in nothing here. But assuming we're
writing chapter 2 or chapter 3, I want
it to have the context of the last 2,000
words or so, so it knows where it left
off and where to begin. I don't do more
than 2,000 words because that
overextends the AI a little bit. It
already knows from the outline. it'll
have access to the full outline so it
knows what the story is that happened
before. I really only want it to know
the last 2,000 words or so. And even
that might be generous just to pick up
where it left off. And the reason I
don't do more is because when you have
too many words in a prompt, it sort of
waters down the prompt and makes it less
effective. And so I only put 2,000 words
in there. AI models are getting better
every day. There was a time when putting
2,000 words would have been too much.
And now it can handle 2,000 words. So
maybe at some point we'll get to a point
where you can have it read your entire
book and still be able to write a really
good next chapter, but I don't think
we're quite there yet. All right, so it
analyzes those last 2,000 words.
Actually, what this does, what this node
does is it gets the entirety of your
document, and then this code node just
selects the last 2,000 words, the most
recent 2,000 words. All right. Then we
have these four steps, and these are
where the majority of the work happens.
to give you a highle overview. What it
does is it creates a scene brief of
based on your outline. It'll create a
more fleshed out outline essentially of
what that specific scene should look
like and then it moves on to a first
draft and writes that first draft. Then
it looks at the that first draft and
says, "Okay, there are a couple of
things wrong with this. I have it make
some critiques." Uh but it doesn't
rewrite anything. It just goes through
and makes the critiques and then it
rewrites. And all of these are using uh
I believe most of them at the moment are
using Gemini 3 except for this last one
which is actually I believe it's Gemini
2.5 Flash. I can actually update that
now to Gemini 3 Flash. It'll be a little
bit better because the the rewrite
doesn't actually need to be that
intensive oddly because the work has
already been done in writing the first
draft and creating the improvement plan.
All that needs to happen is it needs to
rewrite and implement that improvement
plan, but it's not really making any
decisions, which is why I'm able to have
it be a lower model and save a little
bit of money that way. All right, so
let's actually look at the prompts for
this. Uh, they're very lengthy prompts,
so I'm not going to read out the whole
thing, but just to give you an idea,
this is the prompt for the for the scene
brief. I have it pulling the outline,
the characters, the world building, and
the previous chapter text. This is the
last 2,000 words here. Uh, and it's all
contained in these little XML boxes to
sort of help the AI be able to parse
through all of that data. And then in an
instruction XML box, I say given the
above outline and
characters/worldbuilding information,
your task is to flesh out a scene brief
for. And then it pulls in the name of
the chapter that it's working on in this
specific loop. Make sure that the
chapter is clearly labeled with the
words, you know, name of the chapter. Do
not name the chapter anything besides
this. The scene brief should include the
following. Uh I have it pull in the POV.
So in this case, I uh give it specific
instructions because sometimes it gives
me the wrong thing. So in this case, I
wanted first person past tense from the
perspective of Elaine. So I added this
in myself because this is the the story
that we're doing right now. U but you
could in theory change this to whoever
your character is. But I know for this
book that I'm writing, I always wanted
to be first person past tense from the
perspective of Elaine. Okay. [snorts]
Then I pull in the genre, which it pulls
in. Uh, here's the plot verbatim where I
ask it to extract the exact section of
the outline that it's doing. And then it
fleshes that out with additional beats
and blocking. And then I have it
describe what the scene function is, as
well as make sure the plot for this
scene picks up appropriately after the
end of the previous chapter text.
Disregard if this is the first chapter
and there is no data for the previous
chapter text. uh characters, list all
the characters appearing in this
chapter. For each provide their name and
role, physical appearance, etc. And I
make sure it lists all of these things
because their physical appearance might
be different in this scene versus other
like more general scenes, right? I
already have the character sheet, but
that character sheet is going to be
different depending on what scene we're
in. So, I have it kind of create all of
that. Uh it does the same for tone and
style and setting and uh main source of
conflict. It basically goes through and
lists quite a few things to be able to
effectively write a good scene. And then
we move on to the next step which is the
first draft. And this one is also a
fairly complicated one. I have it pull
in the stylesheet, the list of forbidden
words, as well as the outline
characters, world building, and the
previous chapter text and the scene
brief that it had in the last chapter.
So, this is by far the step with the
most context being handled. Um, but most
of the the beefier models like Claude
4.5 Opus and Gemini 3 can handle it.
I've seen people do even larger prompts
than this. Uh, I tend to keep it by
comparison on the lean side, but it's
still quite a bit of information. And
here I say your task is to write the
entire chapter name based on the scene
brief and to cover it thoroughly from
deep point of view. Writing the scene as
if it's written by a bestselling
novelist and not rushing through the
scene. Use the pro style examples
samples to know what the pro style of
your chapter should be. Chapter should
be as long as it is needed to properly
properly flesh everything out. Pay
special care to show deep point of view
and showing not telling in order to
fully flesh out the scene without
skipping over important details. The
reader should feel like they are fully
immersed in the scene, seeing the events
through the lens of the viewpoint
character rather than being simply told
what happened. Always keep the follow
following rules in mind. And then I've
over the years added a couple of things
here, taken away some, added more. I ask
it not to use m dashes, you know, and
say tell it to use commas or an ellipses
instead, stuff like that. This section
is probably the section I am tweaking
the most. And I often tweak it on a per
model basis because some models do like
I'll catch something it's doing that I
don't want it to do and I'll just add
that in here. But in general, that's the
essentially what the prompt looks like.
All right. And then the next one is a
little bit simpler. It's the improvement
plan. So for this, I bring in the
previous chapter text, the chapters, the
scene brief, uh the so the first draft
of the chapter, the scene brief, the pro
style example, and the prohibited words.
and I say, "Given the above chapter, I
want you to critique the chapter on a
lineby-line basis and find ways to
improve the chapter. Give specific
examples. Here are a few things to look
out for." And then I give it a big long
list of all of the things that I want it
to look for. I actually think that I may
be rethinking this in the future and
actually creating some automations that
are specific for editing where I have a
different AI agent that is specifically
focused on one specific thing and it
gives you recommendations. Um, that way
I could probably use a less powerful
model because it's only focusing on one
thing, but for now I'm just using this
and uh I will refine those editing
automations in the future. And then from
there, it creates an improvement plan
and then it goes to rewrite the chapter.
This one's really simple. I give it the
original chapter that was written and
the improvement plan and say using the
text of the original chapter and the
improvement plan, I want you to
implement the suggestions in the
improvement plan. Only implement the
suggested changes and do not change
anything else about the original
chapter. reproduce the entire chapter
with the suggestions made. A chapter
should begin with a chapter header
written and markdown as an H2 heading
like this. And then I just give it the
name of the chapter. All right. And
that's essentially it. And once it
finishes that for the chapter it's
working on, it will loop back. Well,
first it'll add that chapter to your
document, your blank [snorts] document.
And then it'll loop back around and
start on the next chapter. So why don't
we go ahead and run this automation?
remember here in where I ask it to find
the names of all the chapters. I'm
asking it specifically to do just
chapters one through three. So, I'm
going to go ahead and run that for you
right now so you can see what that looks
like. And um yeah, let's go. So, I'll go
ahead and hit execute workflow. And then
it'll have this little popup come come
up and I'll say this the name is of the
book is The Chosen of Avalon. And I
don't really have any author notes. So,
I'm just going to hit submit. And now
it's going through grabbing all of those
documents and it selected the chapter
names. If we go through and actually
look at the output for that node where
it selected the chapter names, we can
see that it successfully selected just
the first three chapters here in this
output. And it's outputting in JSON like
I asked it to. And if I had removed that
one line in the prompt, it would have
actually gone through and given me all
the chapters that are in the outline.
But for now, it's just doing chapters 1
through three. And now it's working on
the first step, which is the scene
brief. And from there, it'll continue on
and I'll get back to you when this is
finished. Quick pause. If you're an
author who wants to start writing more
books, I put together my complete AI
prompt pack that helped me and many
others in my community write a book in a
month, often more. It's completely free.
Hit the link in the description, join
the free weight list for Story Hacker
Gold. Then you just answer a couple
quick questions and I'll send you the
full prompt list plus a few extra free
goodies. I'll also email you when I open
the paid Story Hacker Gold group so you
can join if it feels right. There's no
commitment to join though and you'll
still be able to get all of the freebies
you signed up for either way. All right,
back to the video. All right, so it's
gone ahead. It's already finished
chapter 1 and has started work on
chapter 2. But since we've got chapter 1
already, we can go ahead and go into our
first draft. And you can see that it has
successfully pasted chapter 1 in here.
Now it's pasted in in markdown. There's
a simple way that you can convert that
either through an a free online tool or
something like that. I believe there's a
way to do it inside of Google Docs as
well. But regardless, we can take this
and actually start to go through it and
modify it to our heart's content. So
this is what I would do if I were going
through and doing a couple chapters at a
time. I'd say. All right. Dirt packed
under my fingernails, cool and gritty,
kneeling in the lom felt right, far
better than the stiff wooden chair back
at the cottage. Hello there, Mr. Moss.
The patch of green clinging to the
limestone didn't answer, but it looked
particularly fluffy. I poked it. It
sprang back, spongy and damp. You look
very dashing today, I told it. Mrs.
Fungus is just over that rotting log.
You know, it's not a long trip if you
stretch. A squirrel chattered from high
in the canopy, dropping a chewed acorn
shell inches from my knee. I glanced up
at the shaking branch. Rude. I am having
a conversation down here. Pine needles
and damp earth filled the air a scent
that always settled my stomach. Sunlight
cut through the leaves, warming the back
of my neck. The basket beside me sat
half full with wild garlic nettles and a
few precious roots I'd pried from the
soil without snapping them. I shifted my
weight to stand. My foot slid on the
slip pack on a slick patch of mud. My
boot came down heavy. A wet snap sounded
under my soul. I froze. Um, so a couple
of things here. Um, this might be more
of an a problem with the outline, but
I'm realizing we're kind of not really
getting into the action very quickly.
Um, there's very little hook in this
first page. So, I I might go back to the
drawing board actually and make sure I
have something that happens right away.
Or I could go f further and find a place
where it would make sense to start the
chapter uh a little bit more in medius
res. Also, a couple of things. I liked
the pros overall. This last bit though
needed some work. Uh, lots of very short
sentences. So, I would modify this a
little bit. I'd say my shifting my
weight to stand just as my foot slid on
a slid on a slick patch of mud. That's a
little bit of a what we call that
redundant right there. My foot slid on a
patch of mud. Right. Um, my boot came
down heavy. See the See the the foot
already slipped on the patch of mud. So,
the boot doesn't really make sense. So,
I'd say I just delete that entirely. A
wet snap sounded under my soul. So, I
changed this to say, "And I froze."
Dread curled in my stomach. I lifted my
foot. A single blue bell lay crushed
against the dark earth. Its delicate
stem bent as a sharp unnatural angle.
Oh, no. I dropped it back to my knees,
discarding the back the basket. No, no,
no. I'm so sorry. All right. So, you get
the idea. Little edits like that
throughout. Probably a lot for some
people uh depending on how much you uh
like the pros and how close it is to
your vision. There's always going to be
a fair amount of editing needed even as
these large language models get better
and better. And you can also try
experimenting with different models. Um
for instance, this was written with
Gemini 3. I find that Claude 4.5 Opus is
also very good. slightly different, a
little bit more dramatic, which it would
not be appropriate for this scene, I
think, but for like a climactic end of
the book kind of scene, it would be very
appropriate. Uh, so that those are just
my thoughts there. And that is
essentially what we've got for this full
thing. It's continuing on with chapter 3
now. Looks like it finished. If we go
down, scroll down and we can get to
chapter two. And here it is, chapter 2.
And then chapter 3 will stop here. Then
chapter 3 will start here at the end
there. And if we look at the word count,
the words for these first two chapters
is 5600 words. So that's a very good
good length for a full chapter. So I'm
happy with that. And yeah, so that's
been this full book automation process.
You may have noticed that uh if we were
to somehow combine the brain dump to
dossier and the dossier to full outline
and the outline to chapters automations,
you might be able to actually create a
whole system that creates a book in one
click. Now, it's not necessarily
something I recommend, but I do have
this tradition now of every year I will
try to write a sci-fi beach romance
book. Don't ask. using automations,
using prompts completely with no human
input, just to kind of get a sense and a
measure of how much these tools are
improving and how much like our
prompting methods and and all of that
are improving year-over-year.
And we're getting close to the time of
year to do that again. And I plan on
essentially putting these three
automations together and being able to
do it with one click. Now again, I don't
recommend that for most people if you're
doing that for your own book because
you're going to end up with a lot of
logical issues. But we are moving to an
age where that might be possible. Uh
although I do think and I will I have
said this a lot, but an AI doesn't
matter how good the AI gets, it will
always be better when paired with a
human and having a human guiding it. And
even if it can create a cohesive story
that actually works, it won't
necessarily be your story. So making
sure that you actually spend the time to
do the thinking and let AI do the doing
is absolutely crucially important as we
move forward into this very AI saturated
world. All right, those are just my two
cents. If you want to get your hands on
this specific automation, it is
available in my story hacker gold group.
The link for that is down below. And
again, if you sign up for the waiting
list, assuming that the uh that it's not
open at the time that this video goes
out, then you'll get my prompts for free
when you join the waiting list. You
obviously get a whole lot more if you
actually join. Uh but if you join the
waiting list, you'll get those free
prompts as well, regardless of whether
you actually want to join the group or
not. So check that out and I'll see you
in the next
