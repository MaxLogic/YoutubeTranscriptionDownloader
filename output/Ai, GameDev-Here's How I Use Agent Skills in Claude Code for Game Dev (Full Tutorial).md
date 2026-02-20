---
url: https://www.youtube.com/watch?v=ak0QkJjwK9U
title: Here's How I Use Agent Skills in Claude Code for Game Dev (Full Tutorial)
channel: Chong-U — AI Oriented Dev
created: 2026-01-09
uploader: Chong-U — AI Oriented Dev
view_count: 15394
like_count: 582
comment_count: 36
tags: sonnet 4.5, opus 4.5, claude code, claude code skills, claude skills, vibe coding, vibe code, agent skills, vibe code games, vibe code game, Game Development, GameDevelopment, Game Dev
description: 🚀 Join My AI Builders Community + My Full System ► https://aiod.dev/777427 
🧰 Get the Claude Code Builder Pack  ► https://aiod.dev/9d8f33
🕵 This Video's Games + Skills + Source & Weekly Insider Updates (FREE) ► https://aiod.dev/8077f6
📝 Try TinyPRD Today ► https://aiod.dev/fc2d64

In this video, learn how I rapidly built four games, including an endless runner, tower defense, a Mario Party-style mini-game, and a 3D action arena shooter, using vibe coding and agent skills. 

I walk you through my EXACT workflow for designing, building, and deploying these games, focusing on the critical 'three js builder' skill that's versatile for both Codex, Claude Code and Cursor

Learn how to use tools like Nano Banana Pro and Tiny PRD for game development. By following this step-by-step guide, you'll be equipped to start creating your own 3D games with ease. 

📚 Chapters
00:00 Intro
01:14 Step 1: Threejs Skill
03:46 Step 2: Art Assets
06:25 Step 3: assets.json index
09:12 Step 4: Nano Banana Pro for Concept Mockups
11:43 Step 5: TinyPRD for Game Design Document
13:38 Step 6: Opus 4.5 + ThreeJS Skill for Technical Design Document
18:40 Step 7: Plan Mode
25:15 Step 8: Implementing The Game
29:23 Step 9: Iterating, iterate, iterate!
39:28 Wrap Up

#Claude #AI #Anthropic #Claude4.5 #ClaudeCode #ClaudeCodeSkills #ClaudeSkills #ClaudeOpus4.5 #Opus4.5 #NanoBanana #NanoBananaPro #ThreeJS #vibecode #vibecode
---

Hey everyone. In the past week, I built
not one, not two, but four games using
Vibe coding. An endless runner, a tower
defense, a Mario Party style miniame, as
well as a full 3D action arena shooter
that you see here. And this started to
blow up all over Twitter. And I got a
lot of questions about how this was
done. And the answer is actually very
simple. The answer is agent skills. So,
in today's video, I'm going to show you
the exact workflow that I used to
design, build, and deploy these games.
I'll highlight the critical 3JS agent
skill that I used to get the games
working and looking the way that I
wanted. You can use this skill both with
clot code and codec CLI as well. Cursor
is also going to support agent skills
very soon. So, if you've always wanted
to build 3D games like this, but haven't
been able to get started, this is the
video for you. If you want the exact
skills and prompts that I'm using today,
I've made them completely free inside my
insiders club. And if you want to take
things a step further, that's inside
builderpack.ai. It's my entire toolkit.
Includes source code, prompts,
configurations, sub agents, and
everything that I use to build the apps
in this channel. So without further ado,
let's get started.
All right. So the first thing that we're
going to do is take a look at the
project structure that I have. So within
the plot andcodex folders, you will see
that I have something called the 3JS
builder skill. All right. So it's
sitting within the skill subfolder and
we have the 3JS builder skill that has
been made for both codeex as well as for
cloud code. You don't have to go into
too much detail over here, but just know
that I've been iterating on these skills
as I've been building more and more
games with them. And that's the key
thing that you need to understand here
is that you should always be updating
your skills as you go along because as
you build more and more products and
applications, you will end up fixing
certain bugs or things or gotchas as I
like to call them when they occur and
then you can update your skills so that
they learn to better work within your
codebase and the requirements that you
need. If you're interested in getting
hold of it, you can check out the links
in the description below where I link
not only to the final games that I've
made, but also the source code and the
exact skills that I've been using to
build them. But one of the questions
that I do get is that how did I even
come up with this initial 3JS skill? I'm
just going to show it to you right over
here. I've been working on various
different skills across all my different
projects as part of build.ai. But one of
the most key skills that I've created is
this skill creator plus skill. This
skill is a skill that creates other
skills and I actually use this to build
the initial version of the freejs skill
that I did. Now you can go ahead and use
anthropic's own version which they have
over here called skill creator. But the
version that you see here was faded by
me and in my opinion is a lot more
advanced because I actually looked
across a lot of different skills that
have been built and built this more
enhanced version of the skill creator
plus skill based on all the learnings of
all these other skills. And if you want
to get hold of this skill creator plus
it's available in my builder pack. Links
are also in the description below. So
anyway, now that we have the 3GS skill
here, the way that you'll be able to
launch it, and I'll just show you over
here, is very simple. You can just type
clot
and in this latest version of cloud
code, if you type slash, you should be
able to see that the skills already
loaded. But if you're in an earlier
version, you can also ask it what skills
do you have. And while this is running,
I'm going to show you how you can do the
same thing for Codex. You can do skills
and you can see that there are two
default skills here. And the 3JS skill
has indeed been loaded correctly. All
right. So this is how you ensure that
you've loaded the skills correctly
because sometimes if you do not put it
in the right folders, you might end up
not using the skill when things run.
Okay. All right. So this is step one and
this is the most important thing in
order for you to be able to v code your
3D games using 3JS. What you're going to
do next is actually not coding related.
Remember game development is all about
visuals and art design. And a lot of
people do ask, did I create the assets
myself or did it just generate it on its
own? And the answer is that I actually
made use of off-the-shelf art assets.
And the reason why you want to do
something like that is in my experience.
I've done it several times. It's really
difficult to create art assets using
just pure vanilla 3JS and out of
geometric shapes. You'll not be able to
get nice textures. You won't be able to
get complicated shapes. And there's a
lot of AI software out there that will
allow you to generate assets for you,
whether it's 3D or 2D. But trust me,
nothing at this moment beats having
something that has been cohesively
created by a human. All right, for
example, I'm using this one over here by
and he has a lots of really good assets.
So, I'll show you the one that you see
most in my videos was this one called
Cube World. And you can see here, right?
Like it's already done in a very
consistent style. And the best part is
it's all animated, textured, it comes in
all the different formats, but the most
important thing you want to get is the
glTF format. And definitely check the
license. So this is a CC0 which is
creative common zero which is extremely
permissive. You can use it freely for
anything whether it's your own private
thing. You can put it in your own G. You
can sell it. You can market it. You
don't even need to credit the author.
But it's always good practice if you're
using some offtheshelf assets to that
values credit them. Or if you want to
you could actually go on and support
them on Patreon or any other ways as
well. You can use paid assets as well
but for the purpose of my experiments I
was just using these free assets. Okay.
Just very quickly I can I'm just going
to show you. I use this cube wall asset.
And then for the shooter, I use this
tune shooter game kit that you can see
over here. And so what I'm going to say
here is that don't think about creating
assets manually because there are a lot
of assets that you need to create in
order to make something that looks good.
And if you're going AI generated or
whatever, you know, it's going to take a
lot of time and honestly to get it
generated to get it animated uh and then
get it in the right format, it just
doesn't work. And trust me because I
actually have worked with Blender with
to create animated characters as well as
3D looking assets and I know that
nothing beats a cohesive pack like this.
So once you've decided what you want to
use, let's just go back to using the
cubable one. What it is is just go down
here, click on download, and then you
can click on just give me the download
if you want to get hold of it. And this
will bring and there are a lot of other
places where you can get hold of these
assets. You can go to each io. Just
remember to check the license before you
use them. All right. So you can see here
this is the cubo walls. I just click on
download over here and then it will
prepare the download and all you have to
do is just wait for this to complete.
Okay, as you can see here, it's just
asking me to download this entire zip
file. And you can actually open up the
entire zip file over here. And if you
actually take a look at what's inside
here, you can see it has everything
including an atlas as well as the pixel
art and a preview all the assets within
it. So what you're going to do now, I'm
going to make this a little bit bigger,
is that you create a folder, call it
public. Okay. And then I'm going to
create a folder called assets within it.
And then I'm going to drag this cube one
and pop it in over here. Okay. And I'm
also going to take the chance to rename
this. I'm just going to call this cube
world so that sits very nicely. So you
can see all I've done is just move the
entire extracted archive into this
public assets folder. The reason I like
to do it this way is because when you
actually publish it onto the web, it's
important that you use a good structure
that allows the app to be able to access
the assets when they need it. I'm just
going to delete that zip file. And now
we have all the assets over here. Now
this is the key step that you should do
when you're working and trying to bite
code with external assets. And make sure
you're using Opus. And now the default
model is using Opus 4.5. But just check
because depending on the version of
cloud code that you're using, opus might
not be the default and you need to
switch it. Okay. And what you want to do
is the following. You want to say study
the public assets cube world folder and
look through all of the assets that are
present there. Create an assets.json
file that will be an index to all the
assets that are available as well as
their paths. And one more thing that I
forgot to add is that focus mainly on
the gltf formats. And that was the thing
that you want to do. And I'm going to
kick this off right now. And the reason
why you want to do this is that what you
want to end up with is a way to very
quickly understand what assets are
available without it having to traverse
and go through all of the different
folders each time. So the AI will be
able to just look at a single file
called assets.json and you'll be able to
know exactly where every one of the art
assets are going to be. And this is
really important because as you will see
in the latest step, this is going to be
the key thing that will help you to help
the LLM and the AI understand exactly
how to access what's there. All right,
so this is a really important step that
I found very useful especially when I'm
prototyping my games. So we're just
going to let this run to completion and
see where we end up with. Okay, so it's
completed this phase right now and you
can see that it has done a summary of
115 of the models and grouped them
according to the categories based on the
subfolders. And you can take a look at
the assets.json JSON over here. And
you'll see this is just 170 lines
including the stats as well as the ids
for all of these models. And this will
make it a lot easier later on when you
are deciding which assets that you want
to use and where to locate them rather
than it having to look through the
folder structure by itself each time. So
now that this is done, you're going to
enjoy this next step because I'm going
to show you how to use Nano Banana Pro
to create some concept art for the
design that you want. All right, so
let's get going. All right, here I am in
Nano Banana Pro and this is just within
Google AI Studio. If you want to know
how to set up Nano Banana Pro so that
you'll be able to use it, you can check
out my other video and there's lots of
tutorials online out there. But the main
thing you want to do is create an
account and then tie it to a paid API
key. Okay, so what you want to do now is
just jump in and look at the preview
image if you have one. In this case, I
really like Quonius's assets because he
gives you a preview which is very
useful. So, what you're going to do is
that we're just going to take this
entire file and we're going to paste it
within Nano Banana Pro. Okay? And you're
going to use the following prompt. Given
the following preview of assets that I
have and the following assets.json
index, create a mockup of a 3D game
where the user has to find the key and
then walk towards the chest to open it
and complete it each time. There are
some enemies within the dungeon that the
player needs to avoid. All right. And
now I'm just going to drag in the
assets.json as well because I did
mention it there. And just give this a
world. Now, this is actually what I
found to be a great creative unlock when
you're working with games like this
because sometimes you have an idea of a
game that you want to build. In this
case, just based on looking at this
preview, I just came up with the idea.
But now with Nano Banana Pro, you're
going to be able to create some screen
mockups that make it a lot more visceral
that makes you be able to visualize how
the endgame might really look like. And
this is really good, right? Because this
is a really fantastic concept art to
begin with cuz you're going to send some
stats to Google so that they can
continue improving your models. And if
you actually look at this, it has a nice
mini map at the top as well and it has
the player. It has nice lighting. So
let's see. But most of the time, you're
not going to be able to get exactly what
this mockup is going to look like. There
are ways to get there, but it will
require some level of iteration. But the
whole point here is that we're going to
save this now. And I'm going to put it
into public. And then I'm going to
create a new folder here called dungeon.
Okay. And then I'm going to call this
concept.
JP JPEG. Okay. So now if you actually
see within here, within dungeon, oop, I
have a typo. All right. It's going to be
called concept.jpeg. All right. So now
you have the concept out and don't
forget because all the models now are
multimodal you'll be able to visualize
this. This is going to help as it tries
to replicate the kind of game design
that you want. So what you could do over
here is just take a look at what you've
written into Nano Banana. Right? So it
just says here it's really a 3D game
where the user has to find a key and
walk towards the chest. So, what you
could do is actually take this and throw
it into chat GPT and say, "Write me a
better prompt or write me a game design
document." And it'll give you some
fairly good results. But what I'm going
to do is use a tool that I've built and
it's called tiny PRD. Now, the whole
point of doing this is that it allows
you to put in the prompt that we saw
earlier and it will help you to create a
PRD or in this case, if you switch it to
game mode, it will actually create you a
game design document. And the reasons
why you might want to do something like
this is that it's been tailored to
produce game design documents that work
really well with agentic coding tools
such as these that you see over here. It
gets rid of a lot of fluff that you
might often get when you use something
like chat gpt or claude. And as you can
see, I've actually used it to build
different apps such as the one by the
month website as well as the games that
we've been talking about in this
episode. So the way that you do it is
that once you've created an account, you
can go ahead and paste in the exact same
description that you had from earlier.
And over here, you'll be able to add in
some reference images. So this will be
extremely useful to have as well. So
we're going to drop this in over here. I
have added concept mockups that reflect
how the game looks. And the other thing
that you can do is remember the
assets.json
file. You can just copy the whole thing
and paste it in here. And then I'm also
going to take the preview image and drop
it in. I have also added a preview of
the assets that are available. Okay. And
so once you're done, we're going to
scroll down and we're going to do we're
going to switch this to game. And then
we're going to click on generate PRD
over here. Okay. And this will kick off
and it'll take a couple of seconds and
we'll be able to draw back once this is
completed to take a look at what we end
up with. Okay. And you can see now it's
completed and it's given you a much more
comprehensive
design document for us to implement this
game. So you can see here it says it's
identified as a small isometric 3D
dungeon game, right? And the important
thing here is because we've been able to
provide some of these reference images.
This is how you know that it's actually
managed to read the reference images
because if you had just typed in the 3D
game without these assets, it would have
maybe given you a different style as
well. You can see that it uses gltf
assets and you can see that there's all
the different technical requirements
about using the 3JS and all of the
different things that will help to
ensure that when it builds the game you
will be in pretty good shape and we'll
see the end result of this very shortly.
So this is the reason why I created tiny
prd. You might have heard of the notion
of creating a spec or spec driven
design. This helps you to ensure that
your agent is constrained in how it goes
about building the application. So, all
we have to do now is just click copy and
we can go back into our project. I'm
going to pop it into a folder and I'm
going to call it docs. And I'm just
going to create something called PRD.
And I'm just going to pop it over here.
Okay. And we're going to click save. All
right. So now we've got our PRD and we
are almost ready to go ahead and
actually implement this game. So what
we're going to do is we're going to
launch plot over here. We're going to do
context to see how much of the context
has been taken up. What I'm going to do
is just very quickly install a plugin
that I use myself. So I'm going to do
mpx trunk-uccus
line at latest in it. And you will see
very shortly what this does. But this
will install something called a clot
code status line. I'm just going to
accept all the defaults and then kick
this off. I just clear the screen. I'm
going to type clot and I'm going to do
resume. So this will allow me to pick up
from where I left off earlier. So this
was the one. All right. And you can see
this time the difference is that I have
this status line below my bar. So I
automatically know I have 80% of my
contacts left. I'm using Opus 4.5. I'm
on clock version 2.1.1 and this is just
the default output style. This is the
most important thing because with 80%
context I feel confident enough that I
can continue on because once this starts
getting lower, you will get lower
quality outputs. So it's really
important to pay attention to your
context. So what we're going to do now
is we're going to start reading this PRD
over here. So I'm going to say based on
the PRD come up with a technical design
document
called TDD that will help ensure that we
will be able to implement this game with
minimal problems and as fast as
possible. And I'm going to say here use
the 3JS skill to pin this. And the other
thing I'm going to do at here is I'm
going to say refer to the
public/assets.json.
And I'm not sure why it's not
autocompleting here, but it doesn't
matter. For a list of assets
and use public dungeon and set jpeg as a
reference mockup of the game. All right.
So, let's go ahead and kick this off.
And you see the whole point that you're
doing here is that you're actually doing
context engineering.
building up sufficient context before
jumping in and diving into building the
game right off the bat. And I found that
this really helps you to get to a really
good first initial state of the game
which you can then iterate upon and it
will allow you to just get to a playable
state much easier. And the reason why
you have something called a technical
design document is that based on the
game design, you want to identify the
technical implementation plan that
you're going to have when you're
building the game. And the reason why we
also mentioned using the FJS skill is
all right and you can see down here it
says now I have all the context needed
and like I told you this is context
engineering. So what this is going to do
is that it's going to increase the
likelihood of the first version that it
builds is going to look and feel and
play a lot better. And I actually have a
different video where I showcase where
if you go ahead and just throw in a
prompt into something like Gemini or
cloud code or whatever. The first
version oftent times will have a lot of
little bugs that you do not want. The
great thing with what we've done here is
that we've got a mockup and you can
obviously continue to iterate on how
this mockup looks like to get to
something that you want. I'm very happy
with just this one and I think Nano
Banana Pro tends to fare really well
with this. So, we've got the mockup,
we've got the PRD, and now we're
creating a TDD or technical design
document to go along with it. So, we're
almost there, right? I promise you that
is the last step of the context phase
before we go ahead and implement the
game. So, we're going to let this chug
along. And you will notice that the
context has depleted quite
significantly. And that's because we've
been loading in a lot of the different
contexts. We're loading in the skills,
we're loading in the TDD, the
assets.json, the image. So this will
start to go down quite significantly.
And as you will see later, I will want
to refresh this context before I go
ahead and build the game. But let's just
wait till this is completed and then
we'll draw back. Okay. So this is now
completed. All right. And you will see
that it has written something called a
TDD over here. And it's given an
architecture overview, the text stack,
how to do asset management, and
everything to do with the dungeon
creation, collision system input,
everything you expect this game to have.
Now, this one is going to build it in a
single index.html file. So, this will
make it very easy to distribute as how I
designed the current version of tiny prd
to encourage it to be in just a single
file. Now, there are a lot of reasons
why you wouldn't want to do that, but
I'll be working on a new version that
potentially splits this up into smaller
files, but for now, this has worked
really well for me, especially when
you're building quick prototypes and you
want this to be very easy to distribute.
And so you can see here it also knows
how to ensure that you can load all the
assets and it covers a lot of snippets
of code that you'll need to do in order
to implement this very well. Okay. So
now that this is done, we are ready to
go ahead and implement the game. So
let's scroll down. All right. So I'm
going to scroll down here and you can
see the context remaining is 54%. And
what I'm going to do is I'm going to
export the conversation that I had so
far. I'm going to call this the
transcript. Okay. And the reason why I
like to have this transcript is so that
when I go ahead and go back and look at
the prompts that I use so that I can
improve it in the future or for the
purpose of recording this video, I'll be
able to get hold of it. So this is the
reason why this is very useful. So now
that we have 54% left, it's actually
going to be useful to either compact or
in this case I don't think it's that
necessary because we actually have
everything we need to build this game.
So we're going to do new over here and
we're going to free up the entire
context so that we can go ahead and
implement this entire game and make the
full use of the combat that we have.
Right? So I'm going to go into plan
mode. So I'm going to do shift tab to go
into plan mode as you see over here. And
I'm going to say implement the game
defined in prd.mmd. All right. So you
have this adhering to the technical
design in TDD.md.
Let's go get that one. Note the assets
index in assets.json. JSON
manager
get hold of these
assets over here and use the 3JS builder
skill.
All right. And this one probably didn't
get it. So I'm going to do the 3JS
builder skill.
All right. And then we're going to make
sure to be in Opus 4.5. And let's go
ahead and do that. All right. All right.
So, we're going to kick this off. And
this is the final step before we let
Cloud Code go ahead and build the entire
game. So, you can see here it's kicked
off and used the 3JS builder skill that
we that I've been talking about the
entire time. And this is the only skill
that you really need in order to build
games like this because like I said,
this skill has been refined over several
projects that I've used. And it includes
some really useful scripts in order to
fix a lot of very gnarly issues such as
coordinate systems and facing the right
direction and animation states and just
all the things that you will if you've
ever tried to build a game using AI with
3JS, you just know that everything is
just you'll have all these little niggly
issues where it's facing the wrong
direction and things like that. and it
might still happen, don't get me wrong,
but the idea is that it'll be quite easy
to fix as well because it has all of
this knowledge of how to deal with 3JS.
Okay, so we're going to let this go
ahead and continue on. All right,
because what it's going to do is that
it's going to get a good understanding
of what to do and then go ahead with and
create the implementation plan as you
see over here. All right, you can
actually immediately see the reason why
we freed up the context just now because
you see just by reading all the docs
looking at all the assets. It's already
taken up almost half of its context
window and now coming up with this plan
is probably going to delete the
remainder. So this is the reason why
it's always very useful to make sure
that you are keeping aware of the
context they're using. Don't wait until
it autocompacts because by that point
it's going to be too late. All right. So
now it's completed the plan that he
needs to do to implement this. And you
can see here, all right, you can say
it's ready to code. And here's the plan.
Now, one of the new things in cloud code
is this / plan command. And I'm going to
just very quickly show it to you over
here because there's several reasons why
you want to do it. Now, if you go ahead
and press one and bypasses now, it's
going to go off and build the entire
game. But we're not quite ready to do
that. And I'll show you why. So I'm
going to jump out here cuz you see this
entire plan that's sitting within this
win box. In the past for you to access
this plan was not always clear how
you're going to be able to see it right
but recently they've come up this new
plan command and if you do plan open
what it does is that it will open up the
plan that cla code has created in this
markdown file over here and you will see
that it stores it in doclans and it will
give it some random name and what I like
to actually do is to save this plan into
my own folder over here so that I can
refer to it when I need to in the
future. here. So, whistling sonnet.md.
Now, the reason why you want to do
something like this is here's the trick
is that with this plan, if just say
you've run out of your usage limits, you
can pretty much I've had good success
with now just taking this plan and
giving it to another coding agent like
in cursor or in codec cli and getting gp
5.2 to go ahead and implement it. So,
this is actually a really good trick
especially if you're hitting your usage
limits when you're doing a lot of stuff
with opus 4.5. And so the reason why you
want to have this plan over here is so
that you will be able to do just that.
All right. So I'm going to close this
now and just go back into here. And in
this case, I think it's worthwhile
compacting the conversation so that we
free up some of this context window
before we go ahead and implement the
plan. So what you could do is do an
entire like new again and just free up
the entire context window and just give
it this plan that you see over here and
you have pretty good results. But in
this case, I'm going to compact it and
then just proceed on from where it's
left off so that it has that in memory.
All right. Right. So it's finished the
compacting over here. So it's probably
been able to free up a little bit more
of the context which will refresh once
we do the next command. So now that
we're ready, please proceed
with implementing
based on the plan. All right. So you can
see it actually even though now that
it's refreshed, it's freed up to 83% of
the context which should be sufficient
for it to complete the implementation of
this. So, we're going to let this run
until the end, and then we'll draw back
because it pretty much has everything it
needs to go ahead and implement this.
I'm going to click okay, bypass
permissions, and it's going to go ahead
and implement the very first version of
your game. And I'm really excited to see
how it turns out. All right, you can see
it's going to create the thing in a
single index.html file, which will make
it very easy to distribute, and then
it's going to test the game. All right,
so we'll draw back once this is
completed. All right. And it's actually
completed now, which completed a lot
quicker than I expected it to. But you
will see that it did it for about 5
minutes and 14 seconds. And if you
recall, we were at 60ish% in terms of
context, and it cut it down to about 50.
So actually, it had enough context based
on everything that we provided for it to
be able to implement the entire game. So
what you're going to do is just open a
new terminals. I'm just opening by the
side over here. I'm going to close this
in the side. And what you want to do is
just go to the public folder, right? So
what you want to do is that you want to
serve this, right? You're not going if
you try to open up index.html,
right? So if you see it's basically
built the it's already built the game
here in index.html. But if you try to
just reveal this and find it and just
open this in a browser, often what you
will see is that what you'll see is that
you have the game here, but none of the
assets are loading. Okay? Because the
reason is that it actually needs to
serve and load the assets and if you
don't serve it from local host, it isn't
able to access it due to the
permissions. All right? But the nice
thing that you can see just from this
game over here with the girl that we
have is that the game is fully
functional as you saw over here, right?
That's the enemy. I'm walking around. I
have to find the key, right? I have to
find a key that you can see over here.
The 3J skill actually creates
placeholder assets. And this allows you
to play and test the game even if your
assets aren't working. And this is a
really good way to make sure that the
game is even fun even without
good-looking assets. All right, so you
can see that it's already working over
here, but let's actually check it out
with the full assets. Just jumping back
into my IDE. Like I said, one of the
easiest ways that you can do is just do
serve. All right. And this will just put
it in here. And you can see it's serving
a local host at this URL. So I'm going
to open it up. And here we go. All
right. So I'm going to look. And you can
see in this case it is running
correctly. It was the same game that you
saw earlier, but this time it's able to
load all the assets that we saw from
earlier. You can see that the enemies
are chasing me and they're all animating
correctly. And this game is actually a
lot harder. So, what we're going to have
to do is that we're going to have to try
to sneak past this goblin that we see
over here. So, I'm going to hide over
here. Okay. So, I think shift is for
sneaking. So, you can see if I hold
shift, I actually move a lot slower,
right? And if I don't hold shift, I'm
running a lot faster. And I have to get
past this goblin over here. So, I'm just
going to sneak past him. He's just saw
me. I'm going to run away. Oh no, this
game is a lot harder than it looks. I'm
going to do a close save. Okay, so
that's pretty hard, but I'm going to try
this time. So, I'm running here. Let's
see if I can grab the key, right? Oh no.
And this is a lot harder than I thought.
Okay, but you can see the game is
already working. It's loaded in the
assets. There's something about the game
design and the camera that probably
needs tweaking. But overall, the game is
working as expected. See, I picked up
the key. You can see I picked it up over
here. And now the guy's chasing me and
there's no way to run away from it. It's
game a lot harder than it looks. And
they definitely need some tweaks. But
the whole point is that you've gotten to
a pretty good spot over here because now
with this first iteration, the character
is moving correctly. It's animating.
Okay, you can see if I do WSD, I'm
moving correctly. And there's already
the character movements and you already
saw that they are able to know whether
they should chase you or not. And this
provides you with a really good baseline
for you to continue to implement the
rest of the game. So, this is really the
crux of it. Once you get to this point,
it's really solved a lot of the issues
that you would normally encounter if you
just tried to build a game with 3GS.
Like the models won't load correctly,
the animations don't play correctly,
they won't blend together correctly. But
you can see at this point it's already
got all the elements of what will make
the game fun and all you need to do from
this point is to iterate upon it. So
that's generally how I did it. And you
just take a look at this video. This is
the game that I built the last time. It
was a little bit buggy but the main game
was there and then I slowly iterated
upon it until the game started to look
better and better. And that's how games
are made. Nobody ever oneshots an entire
game like this because there's just so
much iteration that goes into game
development. The main thing is that you
want to get to a playable version of the
game. As we see over here, we're going
to get to a playable version of a game
that allows you to iterate quickly and
not have to worry about whether the
models are loaded correctly, whether the
controls are working correctly, whether
or not the game mechanics work correctly
as well. And this is how I like to build
my games. All right, so I'm just going
to spend a little bit of time trying to
see how I can improve this, and then
ultimately where we can end up in the
next couple of minutes. So, what we're
going to do is just identify some key
issues that we want to fix, and then we
wanted to implement it. Okay? Because
the core mechanics are already there.
says that the game right now is has a
bit of problems with the cameras, the
difficulty, and several different things
like that. So, let's think about what
we're going to do. So, I think what
we're going to do is do a few things,
which is we want to make sure that the
maps don't have such narrow corridors
because right now there's only enough
space for you to walk or get through and
it's pretty tough. The second thing is
that the camera isn't great because of
the walls as well. And then I think
those are the really the key things that
make this game unplayable at the moment.
So, let's just fix those things right
now. Okay. So, I'm going to say let's
fix the following issues. All right. So,
I'm going to say first of all, the
game's map is currently too tight. The
corridors are narrow. The intention is
to have a lot more space to allow the
player to navigate and avoid enemies.
I'm going to actually I'm also going to
say that it might be worthwhile
referencing the I'm going to reference
and reference the concept
JPG for a good example. Right? And the
second thing, what was the second thing
I say? Currently, we're not using any
tiles for the walls, making it look very
bland and gray. So, let's use some
assets to be able to make the map look
better. Okay. All right. So, we have
that. And what else should we do? I
noticed just now that if you walk
towards them, you will see that the
exclamation mark doesn't appear above
the head of the enemy. So, I'm going to
say the exclamation marks do not appear
above the mesh of the enemies and
instead it intersects with their body.
All right. So, that's the other one. So,
that I noticed that the zombies so
aren't really animating correctly, are
they? They're just floating around. Oh,
they animate when they chase you. All
right. I just want to double check that
is the case. So you can see. All right.
So I'm going to add that as another
issue. The enemies are not animating
when they're patrolling, but they do
animate correctly when they're chasing
the player. All right. And what else do
we want to fix? I think those are the
main issues. All right. Otherwise,
everything works pretty well. The camera
is actually pretty good. It's just that
the walls are too are too high and
oluding it. I'll just add as another
point. Note that with the current design
and having not implemented the earlier
suggestions, the wall procludes much of
the player character and the game,
making it hard to play. All right, so I
think we can go ahead and try to fix all
of these issues and see how it turns
out. Normally, you want to fix one issue
at a time, but I think it should be able
to fix all of these issues quite
quickly. So, let's just give this a roll
and see how this goes. All right, so you
can see now it's actually looking at the
concept art. So hopefully you'll be able
to get a good reading into what we're
going to look for. All right. So now I
did acknowledge that you should have a
much more open with large rooms and
wider passages. Like I said, this is not
a silver bullet, right? The main goal
was really to make sure that the initial
game was good enough for you to iterate
upon. I suppose that there's a lot of
stuff we could have done to make it even
better. But I find that having been
working in games for ages now, both in
the vibe coding age and the traditional
sense, games are not built in in one
shot. Just trust me on that. They
usually have a first version. They try
to solve one issue. For example, the
controls, the mechanics and things like
that and then you iterate upon that. A
game like Assassin's Creed or Batman was
never created in just one shot and it's
built upon a lot a lot of iterations.
And in fact, most of the games that you
saw at the beginning of this video were
built with a pretty shorty first
implementation and then I iterated it
upon it quite quickly to the state that
it got to over several days. So, let's
see if we can how far we can bring this.
I don't want this video to be too long.
I just really wanted to show you the
process to get to a stage where you can
really start by coding a 3D game and
then you're able to create something
that's really fun and really just avoid
a lot of the problems that you usually
get if you try to just work on the game
and bite code things using 3GS. This is
just what's worked for me. Obviously
very open to other suggestions and
improvements. And as I learn and work
more on this, I'll also be happy to
update maybe to create an updated video
or share more tips and tricks on how to
make this process a lot better. All
right, so I can already see some changes
that are propagating through. And you
can see this game is looking a lot
better now, right? And all I needed to
do was to just change the layout of the
map, right? The way that the map was
previously, it just made it really I got
a key now. And let's see if I'm going to
be able to open the chest, right? I
think I have to press E on because this
is so close. Okay, so there's definitely
something about the game balance. I'm
going to press I managed to clear the
game. So you see the game is actually
playable now. And I think this time it's
got a different map. Pick up the key.
This one's a lot easier. And let's see
if I could get it. Yes, I managed to
clear it. All right. So you can see just
by changing the level design, it's
already made it a lot better. The camera
feels a lot better. So the camera was
fine earlier. It's just that the level
design just didn't make it look good.
And you can see that now the enemies are
animating when they are walking and idle
uh and while they're not chasing me. And
now when they chase me, okay, you can
see that. Yeah, I'm going to just
refresh this and see if the other issues
are also fixed. Let's see. He hasn't
seen me. Oh, yeah, he saw me. Okay, so
now it's definitely appearing higher
this time, but still not high enough.
So, pick up the key and just close the
project. Cool. Right. So, you can see
just that change has made it has made it
a lot better. Let's see whether there's
any other issues. I think what would
make this game more fun really is that
you should be able to rather than
stealth walk, which I think is the whole
point of a hold shift, I think it's so
that they won't be able to detect me.
But I think I'm going to swap it around
where holding shift allows you to burst,
but you only have a certain progress bar
before the burst drops. So, I think that
will make the game a lot more fun. Okay,
let's see anything else. And let's see
what he managed to fix. Okay, so he
managed to fix a bunch of things. I'm
happy with the layout design. Now, I
think it needs to be higher. So, I'm
going to tell them to fix that.
Animation patrol. Okay, cool. So, I'm
going to say, and you can see the
context remaining as it shows over here.
And my status line actually flags this
as orange. This tells you that you're
probably in a position where you want to
either compact or create a new
conversation. So, I'm going to compact
the conversation now, right? hopefully
to claw back because I do want it to be
able to pick up on the fact that I'm
going to continue on this exclamation
mark and something to do to wall tiles
as well. Okay, so let me just look at
the preview. So it should be able to use
some nicer tiles for the wall. So I'm
going to tell it to do that and then I
think we have some random ornaments that
we could have lying around. So we'll
just do this one more thing and then
just see how it ends up. All right, so
it's compacted now. So, let's fix up a
few of the things, right? So, number
one, the exclamation mark is still a
little bit too low. Put it higher still.
Okay.
All right. So, this one. All right. So,
there we go. Secondly, I would like to
use GL glTF tiles for the walls rather
than the plain gray mesh that is there
currently. And rather than holding shift
to go stealth, let's introduce a game
mechanic where holding shift allows the
player to run at a higher speed for a
limited amount of time. So with energy
depleting. Okay, so I think that will
help to make the game better. And what
else can I see? Right. So I think
everything else is really about visuals
and polish which we can do maybe as a
final step. So let's get these things
fixed up first. So I'm going to kick it
off here. I'm still using Opus 4.5 and
and let's just wait to see how this is
going to go. Right? And you notice
because we have compacted our context is
you saw at 82% and then it read our file
and it dropped straight away down to
67%. So you can see the reason why you
want to ensure that you in control of
your context is that as I said you can
get context route if you let it deplete
too low and wait until it does it auto
compact because by that point you want
to be always in control of your context
window. So, this is something that's
really important. So, you can see it's
adding brick walls. All right. And okay,
so you can see it started to load in the
brick walls now. So, that does look a
little bit better in my opinion because
it adds a bit of color. I didn't really
like the gray. All right. So, they
aren't spinning just yet. And but we can
pick up the key. And hey ho, going to
get it. Just follow me. Okay. The
exclamation marks are looking correct
now, but the animation of the of the the
animations now don't play for the
skeleton correctly, but that's fine.
Okay, so I managed to clear and open the
box. Let's try again. Okay, so you can
see that it's the same level this time.
Oh, yep. After me this time. So I think
the sprint mechanic would really make
this game feel a lot better. Okay, I
noticed there also All right, so I think
sprinting is working now. So you can see
this is like the speed and then when I
start sprinting, it's going to be a bit
so me. Okay. All right, so now I can
sprint now. All right, so I think the
game is a lot better now because of this
sprint mechanic, right? It just adds an
extra depth. This guy is not very smart.
He doesn't see me. And oh, wait. All
right, let's I'm going to sprint. So,
you can see the sprint mechanic actually
makes this game a lot better. All right,
I can see the energy bar at the bottom
left hand corner which is depleting when
I hold shift down. So, yeah. All right,
you can see this is actually making good
progress. The game is actually starting
to look better, become more fun. If I
actually make this a bit bigger, you may
see that the game actually is pretty
decent and there's just still some small
little bugs with the animation and
things like that,
but the game is in a good position. So
you can see how you can have a really
good baseline for you to continue to
iterate this. And I built this game
really just off the whim as I was making
this video and I think you can take this
and build some really cool mechanics. I
know weapons and multiple chest cases
and things like that and improve the AI.
So hopefully this has been useful to
showcase to you how you would go about
building a game in CL code. Like I said,
it's actually a really good baseline for
you to go ahead and iterate upon and
build a full-fledged game. All right, so
I'm going to take this and maybe if I
get a chance, I'll add a little bit more
polish and other things, but I just want
to keep this video as short as possible
because I think this has already covered
the entire workflow. I hope you see the
power of the agent skills as I
demonstrated through here. Combining it
with nano banana and a really good spec
can allow you to create games that play
and feel better. And the 3JS skill is
really useful because helps you to
overcome a lot of the gotchas and the
bugs that you encounter that takes the
fun away from building games. But with
the skill, I found that it's allowed me
to get straight into having something
playable so that I can iterate upon. So
that brings us to the end of today's
video. I really hope you enjoyed it. If
you found this helpful, give it a like,
hit that subscribe button, and don't
forget to turn on notifications so that
you'll always be the first to know
whenever new content like this drops.
And if you haven't seen my previous
video, which talks about how I made use
of a Nano Banana Pro skill to create an
interactive greeting card system, you
might want to check out this video over
here. All right, till next time. I'll
see you.
