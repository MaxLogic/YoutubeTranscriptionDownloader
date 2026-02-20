---
url: https://www.youtube.com/watch?v=5Eca5OV5uno
title: This AI Reveals the Secrets of Bestselling Books and Films
channel: The Nerdy Novelist
created: 2025-12-31
uploader: The Nerdy Novelist
view_count: 6336
like_count: 276
comment_count: 27
tags: storytelling, how to write a novel, how to plot a novel, worldbuilding, chat gpt, chatgpt, claude, sudowrite, ai writing, writing with artificial intelligence, anthropic, open ai, openai, sudo write
description: Write more books with AI (12+ in a year). Join the Story Hacker waitlist and get the actual prompts I use for FREE while you wait: https://www.skool.com/story-hacker/about

My Favorite Tools for Authors (UPDATED):

N8N (via Hostinger) for Automations: https://storytellingdb.com/go/n8n-hostinger
Novelcrafter (for hands-on authors): https://storytellingdb.com/go/novelcrafter
RaptorWrite (for authors on a budget): https://storytellingdb.com/go/raptorwrite
Autocrit (best editing program): https://storytellingdb.com/go/autocritlifetime
Perplexity (best chatbot): https://storytellingdb.com/go/perplexity
---

Today we're going over one of my
favorite NAN automations which allows me
to really understand storytelling at a
level that most people don't. And I
don't say that to like brag or anything.
It's just like I don't I literally don't
see anybody picking apart stories like
this, which I'm able to do thanks to AI.
This is one of those areas where AI
absolutely enhances what an author or
writer is capable of doing. And don't
ever let anybody tell you that AI will
make you a lazy storyteller. It can
obviously depending on how you use it,
but it's how you use it that's most
important. And in this video, we're
going to really break that down with
what I'm calling the story hacker
prompt. Now, in my last video, I did a
video uh about story hacking a short
story. And in this one, we're really
getting deep into the uh breaking down a
novel or a full-on film script or
something like that. So, with that in
mind, let's dive in. All right, so this
is the automation right here. And it's
fairly simple, but a little bit more
complicated than the one that I showed
you yesterday with the short story
hacking uh automation. Uh but it does
start relatively similar. So it starts
with uh when you just click the button
that says execute workflow and then you
need to give it a specific document
where all of the information is going to
go. So at the beginning it will look
like a blank slate and all you have to
do is get the ID number of that Google
doc which you can get in the URL of the
Google doc and just copy and paste that
into this slot right here in this node.
Once you have that, you're also going to
need a file that
has the story that you are looking to
hack. Okay. Now, there are a number of
ways you can do this. Um, uh, Amazon
actually recently announced that they're
going to have DRM free books available
if an author opts into that. So there
you might be able to do this with books
that you buy on Amazon or there is quite
a library of public domain books online
and uh film scripts that you can find
online. And that's what I did for the
example I'm going to be showing you
today, which is Star Wars: A New Hope.
And in this case, what I did is I took
the screenplay, pasted it in here, and
then went through and manually, because
I know Star Wars very well, I went
through and manually put in uh a little
heading at the start of each scene. That
way, I knew approximately how many
scenes there were. And this allows the
AI to be able to break it up into chunks
and process things individually to
better understand it. Uh, and this is a
little tedious when it comes to
screenplays because you do have to
manually go and put those in there. With
novels, it's not usually as bad because
you could just go straight to the
chapter headings and make sure that
they're the correct heading. In this
case, it's a H1 or a heading one. As you
can see up here at the top where it says
heading one. Um, and that is what our
automation is going to be looking for is
H1 headings. And I'll walk you through
that in a second. But as you can see, we
have, you know, the long time ago in a
galaxy far, far away. We have the
opening crawl. We have an explosion
rocks the ship as two robots, R2-D2 and
C-3PO, struggle to make their way
through the shaking, bouncing
passageway. And you know, it's the
script of Star Wars, and I'm sure we're
all pretty much familiar with Star Wars.
And then we get to the end of the scene,
and I just added this in myself that
just said scene break, right? or I could
have said scene one, scene two, or
however you want to do it is fine. Just
as long as this is an H1 heading. Okay.
All right. So once you've got the
document with your story in it and it's
been processed and each of the scenes
andor chapters are separated by H1
headers, then uh what happens is you
take the ID number which again is in the
URL of your document and we copy and
paste that into this node which says
download file and which I've done here.
You just put it right there. And then
make sure this thing here says HTML
under Google file conversion. And that's
because we want to extract the HTML of
this document. And the reason we need to
extract HTML is so it can read where
those H1 headers are.
Uh, and then from there, I've got two
code nodes here. This first one is
relatively short and simple. All it does
is it extracts that HTML content and
returns it. And then this node splits it
up by the headers. So it looks
specifically for H1 headers and splits
it up accordingly. So it looks a little
bit like this. Just goes through and
finds those H1 headers. And um the how I
made this I didn't I'm not a coder. So,
I was able to make this just by asking
Perplexity what I should do by
describing my automation. And it it was
able to give me the exact code that I
needed to be able to split things up by
the H1 headers. Um, and by the way, if
this is seeming complicated to you and
you don't know if you want to figure
this out for yourself, my story hacker
gold group is open I think for just
uh let's see this is going out. Yes. So,
at it is going out tonight. Tonight is
the last time that you will be able to
sign up for it for now and it'll go back
to a waiting list. And the price also
goes up. The next time it opens, it will
be $20 more per month. So, if you want
to get in on the ground floor now and
keep the current price uh because you'll
be grandfathered in, go do it now
because today is the last day that
you'll be able to do that. All right.
So, uh, and and this and all my other
automations are available for at no
extra charge when you join that group.
All right. So, um, once we've split up
our document by headers, uh, we
essentially have several chunks of text
separated by those H1 headers. So,
everything in between each of the H1
headers is a different chunk of text.
And then from there, we go into this
loop over items thing where we then run
a prompt on each chunk of those texts.
And once that's done, it goes and does
this part, but we'll get to that later.
Um, so first we have it create this
analysis of the story. And this is a
pretty lengthy [laughter]
uh prompt right here. Uh, but it goes
something like this. If we zoom in here,
here's the chapter or scene you will
analyze. And then I have it pull in the
chunk of text that it's going to an
analyze. You can actually see it over
here. It's it looks like a bunch of
gibberish. And that's because this is
the HTML that it's reading. Thankfully,
it can read through that mess better
than we can. Uh so just trust that the
the correct section of text is in there.
And then I actually have it
read through this as part of the
analysis. I have it identify what scale
it is on in terms of how much spice is
there in the scene, how much violence is
there in the scene, and how much
swearing is there in the scene. And I
have a 10point rubric for each of those.
So I can see uh from 1 to 10, what level
is each of those things? And so I
specify what that rubric is here. Uh and
all of this is part of that rubric even.
It's a it's a big part of the prompt
even though it's just a small part of
the output. Uh, and all the way up to
here. All right. And then it says,
"Given the above short story, please
follow these steps." Oops, I didn't mean
to say short story. This should say
chapter or scene. Please follow these
steps. Make sure to answer all the
questions for each step. Summary. Create
a five to six sentence summary of the
events of the chapter or scene. yada
yada yada. Characters. List every
character who appears in the scene and
only those that are actually in the
scene. So, and so on. Setting. Write out
the key setting of the scene. For each
setting, tell us how or if this
particular setting contributes to the
story in a meaningful way, yada yada.
Conflict. Identify the main source of
conflict and tension in the scene. This
should be one to two sentences. Tropes.
Are there any tropes that are clearly
evident in the scene? Limit this to
three. Uh because I found that it was
giving us way too many. Scene intensity.
Pick a number between 1 and 10 to
indicate the intensity of the scene,
meaning level of action and emotional
resonance, with one being the least
amount of intensity and 10 being the
most. And then I also have it do the
same for spice level, violence level,
and swearing level. Then I said just
have a note here. Do not include any
preamble or post summary commentary of
the scene. Just provide the headings and
the summary as outlined. Format your
output in markdown as follows. And then
I just have some information using
markdown on what it should look like uh
in its formatting. Right? That is the
prompt. and it runs that prompt
individually on every single scene uh
based on where those H1 headings were
set. So, let me show you a little bit of
what this looks like as it outputs this
particular prompt. I'll go here to my
document that has everything. So, if
you're I assume most of you are familiar
with Star Wars, uh we have the summary.
A rebel blockade runner is pursued and
fired upon by a massive Imperial star
destroyer near the planet Tatooine. I
mean, you know the scene, right? Hit the
list of characters. R2-D2, C3PO, rebel
troopers, stormtroopers, Darth Vader.
Um, it also mentions what their heart's
desire is, you know, like R2-D2. Uh,
heart's desire is to survive the chaos
and follow the logic of the mission.
C3PO heart's desire is to find safety
and avoid madness of the battle. You
know, that all makes sense. Uh, then we
have the setting. So, we have outer
space and the rebel blockade runner. Uh,
those are that's definitely the setting
of this first scene. Conflict. The
primary conflict is the life or death
struggle between rebel forces attempting
to protect stolen plans and an
overwhelming Imperial boarding party led
by Darth Vader. Tropes, we have the evil
empire, the faceless henchmen and enmity
of Rez, uh, which actually I'm surprised
I'm impressed that it got that because
the story begins in the middle of a
highstakes space battle with the broader
war already in progress. Star Wars is a
classic example of Nvidia res. So, uh,
that's pretty cool. And then the ratings
are scene intensity is pretty high. It's
an eight. Spice level is a one.
Obviously, there's no romantic or sexual
content in this scene. Violence levels a
five. Uh it is a little bit of a uh
violent scene compared to the rest of
the movie. And swearing levels of level
one. Um and that's the scene, right? And
then it continues and does that for all
of the the [clears throat] rest of the
scenes, right? So that's kind of what it
does. and uh it just continues that loop
over and over again for each scene.
However, where this really differs is
that I do a uh later analysis of the
whole thing. Like once it's done
creating those individual scene
analyses,
we actually have it do some analyses of
the entire thing as a whole. So first um
we go through it using n we go through
and run it through a limiter. Uh all
this does is it means uh only do this
next step once right otherwise it would
run it would continue to run for every
single loop and we don't want that. So
this just limits it to one. Then I have
it get the summary plus document that it
just created and that's what all of this
prompting was doing. So, it then
accesses that info that it just created
and runs this two-part prompt on it
before updating the document with that
information. So, the first part of the
analysis, the prompt looks something
like this. Here's the list of scenes you
will analyze. And then I give it the
content uh which is the entire content
that it just went through. Okay. Uh so
all of that's those analyses that it
created. Now we add that in here and it
pulls that into this prompt which is a
significant amount of text and then I
say please follow these te steps. Number
one, genre. Give the specific genre of
the story. Right, pretty
self-explanatory there. Common tropes.
Next, make a list of common tropes that
this story has for the genre that it's
in. Make sure these tropes are relevant
to the genre and are clearly contained
in the story. Explain each trope and how
the story uses it. Character arcs. Next,
make a list of the characters from the
story. Besides the name, include their
role in the story, like protagonist,
antagonist, side character, love
interest, mentor, etc. Then, in three to
four sentences for each character, map
out the character's arc that they go
through uh throughout the story. Talk
about things like their beginning, fatal
flaw, their want at the beginning, their
needs, and most importantly, the change
that they undergo from the first
introduction to the end of the story. If
there's not much of an arc for the
character, mention this and explain
their role in the story. I also make a
list of the characters primary
demographics like gender, age, etc. Uh,
I added that little bit in because I
found it often confusing, men and women.
So, number four is character archetypes.
Make a list of the character archetypes
that appear in the story. So, that one's
related to the above theme. Identify the
central theme of the story and point out
the scenes where this theme comes up.
Plot devices and foreshadowing. Detect
the uses of foreshadowing, red herrings,
and check offs guns. Map setups and
payoffs throughout the narrative.
Analyze flashbacks if any. nonlinear
timelines or narrative framing devices
uh which can give you some useful infi
insights there. And then the rest of
these or well the next couple are all
very key plot moments. These are the
plot moments that pretty much every
story has no matter what genre it is
including the inciting incident, the
midpoint, the climax and the duma.
And then we have some world building
info. What key setting artifacts and
other worldbuing elements appear in this
book? Create a list of all the major
elements and how they contribute to the
story overall. Magic system and
technology. If this is a fantasy or
sci-fi book, write a full explanation on
how the magic system works for fantasy
or how the technology works for sci-fi.
Uh and then we get average ratings. Take
the average of all the ratings including
the scene intensity, spice level,
violence level, and swearing level. This
could be useful if you want to judge
like how much spice should this book
have to appeal to readers of this genre,
stuff like that. And then uh format your
output in the following format. And this
is all in markdown. Uh just as before, I
just basically repeat a lot of what I
just said, but show it how to format it.
All right. And that's analysis part one.
In analysis part two, we say here's the
list of scenes you will analyze. And I
give it the the text uh again that we
did previously. And then here's some
preliminary analysis to help. And then I
give it the results that it just came up
with in the previous step. Please follow
these steps. Analyze the plot structures
of the chapter scene. Then I have it
summarize it here and then it performs
an analysis. Beneath each summary,
identify each of the following if needed
in a bulleted list. Assess each scene's
primary purpose and reproduce the
ratings. And basically what this is
doing to kind of shorten this up is it
is creating a template for the plot of
this story. So essentially, if you
wanted to write a story just like Star
Wars, kind of like Aragon, right? You
could break this down scene by scene and
then create a template from it that is a
little bit more non-specific, doesn't
include actual names of characters or
anything like that so that you could use
it and even transfer it to a different
genre and use it that way. It's
essentially creating that road map for
you so you can write a scene by scene
comparable story that follows very
similar beats. Uh so this is a really
fun thing that I like to do just to
further analyze what is going on on the
scene level. Uh so it runs that and then
the last step is it takes both of the
answers from those things and it puts it
into our document
uh like this. And to see what that looks
like here we go. Um so this is my story
hack of Star Wars a new hope. Uh, first
of all, it gives us the genre. Science
fiction, space opera/h heroic fantasy.
Totally spot-on. Common tropes used, the
chosen one, the evil empire, the mentor
figure, the mcguffin, the smuggler with
a heart of gold, the damsel in distress,
albeit subverted, uh, a used future, so
the world is not shiny and pristine, and
the ticking clock. Climax relies on a
literal countdown as the DAR orbits
Yavin, raising the stakes and creating
urgency for the trench run. So 100%
these are definitely all spot-on tropes
that are used. Um it gives us character
arcs for each character. So let's read
let's read Hans cuz he has the best one.
Uh human male smuggler in his 30s. He
acts as a reluctant hero and skeptic.
Constantly claiming he is only in it for
the money and dismissing the hokey
religion of the force. His arc is one of
moral redemption. He abandons the
rebellion before the final battle, but
returns at the climax to save Luke,
proving his loyalty to his friends
outweighs his greed. Yep. So, that's a
good description of the arc that he goes
on and 100% accurate there. Uh, we have
character archetypes. Uh, nothing
particularly
u groundbreaking here, but you
definitely get things like Darth Vader's
the shadow, which 100%. Um, and stuff
like that. Uh, I think it got the theme
spoton here as well. Uh, I'm, you know,
I don't really go to Star Wars for any
profound themes, right? It's not the
kind of thing it is, but it it's not
even something I think about very often,
but it absolutely does have a theme that
is woven throughout the story, and it
perfectly illustrates it here in this,
which says, "The central theme is faith
versus technology, or man versus
machine. The story consistently
contrasts the cold technological terror
of the Empire with the Death Star
invader as more machine than man, with
the spiritual human intuition of the
rebels and the Jedi. This theme is
cemented in act one during the
conversation in in Kenobi's dwelling
regarding the force, but finds its
ultimate expression in the climax when
Luke turns off his targeting computer to
trust his feelings or the force rather
than the machine to destroy the enemy.
So, yeah, I didn't even put together
that they have all these moments like
when Obi-Wan is talking about Darth
Vader and how he's more machine than
man, connecting that moment to the
moment when Luke turns off his targeting
computer. Um, but that is 100% there and
definitely evidence of the theme. So, I
thought this was actually an excellent
analysis of the theme. All right, then
we got our plot devices and
foreshadowing. So, we have foreshadowing
with the force. Obi-Wan explains the
force as an energy field that binds the
galaxy together and controls actions
early on. This foreshadows Luke's
ability to aim the torpedo without a
computer. Yep. And then we have like
other things. pilot skills, check off's
gun,
uh, a red her herring, deos sex machina,
subverted,
um, because Han Solo returns at the end
serves as a surprise rescue, but it is
character-driven based on his
established bond with Luke rather than a
random occurrence, which by the way,
that's how you do at dayx machino,
right? Is you make it character-driven
instead of a random occurrence.
Key plot structures. So it identifies
where the inciting incident is, where
the midpoint is, where the climax is,
and where the duma is. Uh world
building, it briefly touches on the
force, Tatooine, the Death Star, droids,
hyperspace, lightsabers, technology. We
have starships, weaponry, robotics,
holograms. Average ratings are scene
intensity of 6.8, average spice level of
1.2,
uh average violence level of 3.8, and
average swearing level of 1.3.
Uh, and then we get that plot template I
was talking about. Uh, so this is where
it essentially goes chapter by chapter
and shows you what happens in the scene.
So rather than making it with specific
details about the scene, it kind of
makes it a little bit more broad so you
could actually do something that has a
similar story arc but related to your
characters and your plot and everything.
Um so for instance this first one a
small vessel is frantically frantically
fleeing and is overtaken by a gargantuan
warship establishing establishing an
immediate imbalance of power. Inside two
lowly servants provide a ground level
perspective of the terrifying boarding
action while soldiers attempt a futile
defense against a faceless armored
horde. The antagonist enters the con
captured ship immediately establishing a
presence of supreme authority and
ruthlessness. So this is pretty good. It
definitely represents the scene. I might
even say it could go even more generic.
It doesn't have to say ship, right? It
doesn't say it's a uh spaceship. Uh this
could be like you could adapt this into
a pirate show, you know, uh or like a a
Revolutionary War fiction or something
like that where we're using ships and
and the Americans versus the British
instead of the rebels versus the empire.
Uh you know, I'm just throwing that out
there. But at the same time uh this is
definitely representative of what
actually happens in the movie Star Wars.
And then in the analysis we have the
primary purpose which is world building
establishing the power dynamic and the
hook. Uh multi-function meaning like
what other functions does it serve? It
serves as a hook introduces the
antagonist and sets the tone of the
conflict. The structural beat that it
represents is the hook which makes
sense. It's the first scene. And then
the ratings are intensity 8, spice one,
violence five and swearing one which it
pulled directly from the other material
that we had. and then it moves on and
does the exact same thing for the next
scene and then the next scene and so on.
So this is really a fun way to really
understand what a story is doing on a
scene by scene level and in terms of
tropes and things like that. I've been
using this very heavily in some of the
genre uh analyses that I've been doing
including the urban fantasy ones that
you've seen recently. So hopefully this
can be useful for you. Again, if you
want to get this exact thing rather than
having to rebuild it yourself, uh you
can get it in my Story Hicker Gold
membership. And today is the last day
that you can uh get in at the current
price. And we'll also be closing it down
for a little while. So, we'll be back to
that waiting list. So, if you want in,
now's the time to get in. Now, now is
your moment. Uh so, hopefully that will
be good for you. And I will see you in
the next
