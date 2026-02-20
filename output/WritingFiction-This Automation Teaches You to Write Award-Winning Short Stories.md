---
url: https://www.youtube.com/watch?v=s8sSmquiQZo
title: This Automation Teaches You to Write Award-Winning Short Stories
channel: The Nerdy Novelist
created: 2025-12-30
uploader: The Nerdy Novelist
view_count: 10212
like_count: 419
comment_count: 30
tags: storytelling, how to write a novel, how to plot a novel, worldbuilding, chat gpt, chatgpt, claude, sudowrite, ai writing, writing with artificial intelligence, anthropic, open ai, openai, sudo write
description: Write more books with AI (12+ in a year). Join the Story Hacker waitlist and get the actual prompts I use for FREE while you wait: https://www.skool.com/story-hacker/about

My Favorite Tools for Authors (UPDATED):

N8N (via Hostinger) for Automations: https://storytellingdb.com/go/n8n-hostinger
Novelcrafter (for hands-on authors): https://storytellingdb.com/go/novelcrafter
RaptorWrite (for authors on a budget): https://storytellingdb.com/go/raptorwrite
Autocrit (best editing program): https://storytellingdb.com/go/autocritlifetime
Perplexity (best chatbot): https://storytellingdb.com/go/perplexity
---

All right, guys. We're going to actually
start getting into a lot more of the
actual automations that I use and how
they work and how you could create
something similar. If you want to get
your copy of my exact automation, you
can go to my story hacker gold program
down below. I'll have a note about that
later. But this is an automation that is
simple but actually super powerful. And
don't let any of the AI haters out there
say that using AI will make you a worse
writer or a worse storyteller because
this automation is kind of proof that
that is not the case. So what am I
talking about? I'm talking about my
automation that is I'm just calling up
here. It's called the short story hack.
Okay? And there's a reason why my group
is called the story hackers, right?
because a lot of it is all about just
going through actual bestsellers and
other successful stories and using AI to
sort of figure out how they work and and
then using that practical knowledge to
inform our own storytelling capability.
And this is one of my favorite
automations, even though you can tell
it's not that big. There's only one AI
agent part of it. Um, but it creates
some very interesting results.
So, what this does is you start out with
a Google doc that has everything that
you want to analyze. So, you can have
just one short story in it and that will
be fine, but you could also have
multiple short stories in it. So, in
order to work with this this specific
automation, you need to make sure that
that document has a clear H2 heading for
each of the short stories. Otherwise,
it's not going to be able to do this
properly. So what we're going to look at
is first of all this has a manual
execution trigger. So you just click a
button and it starts and then it creates
a document where the story hacked
information is going to go. Then it
downloads a file here. Now if we click
on this you can uh specify the actual
file ID of the Google doc that you're
planning on doing. And we're here under
Google file conversion. We want to make
sure this is set to HTML right here
because we need to download the HTML of
the short story. Uh, and then what I
have here are two little code nodes that
I created. And uh, I'm not a coder, but
I use tools like Perplexity to help me
vibe code the whole, you know, what goes
into these. There's not a whole lot. If
we double click on this, you can see
like this is a very small amount of
code. Very little needed here. There's a
little bit more in this one, which what
this one does is it takes the
information it got and it splits it up
by the headers. So, it looks through the
HTML, finds where the H2 headers are,
and says, "Okay, everything between
these two H2 headers, we're going to
chunk that specific piece of text." And
it does that for the whole document. So,
it creates all of these different chunks
of text to then run our automation on
it. So we run through those two code
things and then it starts a loop so that
the loop it means that we're going to be
running these two steps on each chunk of
text as it is split up and then once it
gets to the end of these two steps it
loops back around and starts on the next
chunk and so on and so forth. So, the
prompt for this one, which by the way,
in the past I've been using Gemini 2.5
Pro, now I could probably update this to
Gemini 3. Uh, or even honestly some of
this you could pro because this is
almost a summary type thing, you could
almost get away with a less expensive
model. But because we're trying to do a
deep analysis and we wanted to be smart
about it, we'll leave that at Gemini 3
for now. It's not that expensive to be
honest. Uh but let's look at the actual
prompt for this. So under the prompt
user message, if we open this up, it'll
say here's the section of text you will
analyze and then it pulls in the text
that it got from the previous step,
which was the the step that started the
loop essentially. So it it essentially
inserts the short story that we're going
to analyze right here. Given the above
short story, please follow these steps.
Make sure to answer all the questions
for each step. First is the summary.
Create a five to six se sentence summary
of the events of the chapter or scene.
And actually, I could probably change
this to short story. Use the character
names instead of pronouns. Summarize the
direct events of the scene only. Do not
provide commentary of the scene. And
then we have the conceptual hook. Do a
deep analysis of the short story to
uncover the what the primary hook is for
that short story. What makes it
interesting? What makes the story stand
out? What is the concept of the of the
story? And what can we learn from it as
writers? And then we have it give
information about characters. So it
lists every character that appears in
the scene and some information on them,
including what is their heart's desire,
aka the thing they want most in the
story. How does that heart's desire
change over the course of the short
story? Do they get it in the end? And I
include this because u of a book that I
read from a writers of the future winner
who talked about this being one of the
most important things in a short story
is making sure your main character has a
very clear heart's desire. So I make
sure that we identify that in the short
stories we're analyzing. Next comes
world building and setting. Write out
key setting or world building elements
mentioned or important to the specific
scene or that the scene takes place in
etc etc. Then I have it analyze like
specific plot beats in the short story
including the inciting incident and
what's the conflict. Uh we have a have
it look for the magic sword. Uh because
this is another one I got from that same
book. Uh, in every short story, the
protagonist should gain some ability,
item, knowledge, companion, or other
tool that will help them in their quest
to solve the problem of the inciting
incident. This is not a literal sword,
but can be anything of power that can
defeat the opposing force if the
protagonist can get their hands on it.
Or perhaps they already have it in their
possession, but they have no idea how to
wield it effectively. Identify what this
magic sword is in this story. And then
we go into a series of tri fail cycles.
And every short story has these. Every
novel has these where where there are
usually one to four try fail cycles aka
moments when the protagonist tries to
solve the problem presented in the
inciting incident fails then tries
again. So we have it identify what those
are. And then finally, what's the
climax? What's the duma? [snorts] And I
have it select some of the best examples
of pros from the short story to give us
an idea of like what, you know, what
does the good pros sound like. And then
I just have some formatting information
at the end. And I always end with this
just to make sure it's formatting
correctly and has the correct headers
and all of that. I also like to put a
note like this in almost all of my
prompts where I say, "Do not include any
preamble or post summary commentary of
the scene. Just provide the headings and
the summaries as outlined." And that's
to avoid it to be having things like
here is your uh detailed summary of this
short story. I don't want it to do that.
I just wanted to give me the summary and
no like intros like that. Uh, and so I
have it I give it information about how
to format each of these things that I
just kind of went over already. And
that's it. And then it in the next step,
it updates the document where this goes.
So for this, it's pulling the ID of the
node earlier over here where we have it
create the story hack document. So it
pulls the ID from that document right
here. And then here it just includes the
output of the previous step. And then
it'll continue and loop around so that
it'll continue putting the output of
multiple stories
uh into the same document. Uh that's
assuming you have multiple short stories
in a single document. All right. So what
let's actually take a look at the actual
document for an example of this. And by
the way, if you want this specific
automation for yourself, you can get it
by joining my story hacker gold group.
It is open right now, this week only uh
because we usually have it on a waiting
list, but it is open to the public right
now and it will be going up in price by
the end of the year. Well, we'll be
closing it down and then the next time
it opens up, it will be at a higher
price. It's currently 47 a month. It
will be 67 a month. My goal is for it to
eventually be worth $100 a month or
more. So, if that sounds interesting to
you, go check the link down below
because we will be closing that out down
in like just a few days. So go check
that out and hopefully you you can join
us. All right. So here is a document
that is a example of some story hacks of
the writers of the future uh anthology
that they put out every year. Uh, I ran
one of those anthologies through this
prompt specifically because in my story
hacker gold group, we have a quarterly
challenge to write a writers of the
future submission without the use of AI
because AI is not allowed, but I think
it's worth practicing a little bit here
and there to actually write the pros
yourself. I think there's value in that.
uh but we use AI in every way that we
can legally uh in order to submit to
this thing just not in the actual pros.
So as part of that we have regular
classes during the month of that
challenge where we really study these
stories and we do so having hacked the
stories themselves. So here is a good
example
of one such thing. So the title of the
short story here in this case was Storm
Damage by TR NS. These are short stories
that won the writers of the future. So
we can actually get a sense of uh what
was it about the story that was so good?
How can we try and emulate something
similar? And here we go. We've got uh
the summary. Dr. Greger is a scientist
researching time manipulation is
escorted by the skeptical captain
Kushner to investigate a powerful Tachon
energy reading at a remote cottage.
Right? and so forth. It just gives us
the the full summary of the thing. And
this, by the way, is from the writers of
the future volume 41, which you can buy
on Amazon. Uh, and I bought it in order
to do this, obviously, um, to make sure
that I was legally in my rights to do
so. Uh, otherwise, this this would be
illegal to do any kind of
post-processing like this on a book that
I do not own. Uh, the conceptual hook.
The primary hook is a high concept
sci-fi morality play that pits personal
ambition against the salvation of
humanity. The story is interesting
because it subverts the typical
protagonist journey. We follow a
character we believe is on a mission of
discovery only to learn he is the
story's primary threat and the cause of
the apocalypse he's investigating. This
twist forces the reader to re-evaluate
the character's motivations and the very
notion of scientific progress. The
concept writers can learn from is the
power of the Fouian bargain as a central
theme. Is a personal dream worth a
collective nightmare? And how inverting
the protagonist/antagonist dynamics
creates a memorable and
thought-provoking narrative? All right,
so we can look at that and be like,
okay, that's interesting what it did
there. And then we have the list of
characters and what they're all about,
including their heart's desire, which in
for this character is to have his
theories of time manipulation validated
by the scientific community and to
achieve a permanent celebrated legacy
for his life's work. This desire does
not change. It hardens into a defiant
refusal to sacrifice his dream. he does
not get it. Instead, his entire
existence is erased from time. So,
there's information like that about each
of the characters. Then, we have the
world building information here um about
all of the different settings, uh
including like the cottage on a cliff
and the tachon energy, all those
elements. We have an identification of
what the inciting incident is, what the
main conflict is, what the magic sword
is, the different tri fail cycles that
go on in this story, the climax of the
story, the duma of the story. Here are
some pros examples from the story. In
the distance, you could see thick great
clouds producing a new explosive plumes
in a rhythm of constant motion that
brought the tempest closer to them and
so on. And then that's it. And then we
move on to the next short story in the
bunch. and continue on from there. And
so this is a really great way,
especially if you're reading the story
itself and then using this as kind of a
study guide alongside. It's a really
fantastic way to really understand what
makes a good story and how the
storytelling brings these stories to
life. In the next video, I'm going to
give you another automation like this,
but one that works for a whole novel,
not just for a short story. So stay
tuned for that. And once again, check
out my story hacker gold program if
you're interested because the price is
going up very soon and it will not be
open for much longer. So check that out
and I will see you in the next
