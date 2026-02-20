---
url: https://www.youtube.com/watch?v=7OR-L0AySn8
title: How people are generating videos with Claude Code (Remotion Skill)
channel: Leonardo Grigorio | Build & Ship with AI
created: 2026-01-22
uploader: Leonardo Grigorio | Build & Ship with AI
view_count: 26771
like_count: 746
comment_count: 26
description: I evaluate Remotion's crazy new Agent skills that let you create videos just by using Claude Code in the terminal. I walk through setting up the project with Bun, installing the necessary packages, and prompting the AI to build a dynamic YouTube UI animation from scratch.

x post: https://x.com/Remotion/status/2013626968386765291
prompt example: https://gist.github.com/JonnyBurger/5b801182176f1b76447901fbeb5a84ac

Timestamps
00:00 - Intro to Remotion Agents
00:34 - Installing Agent Skills
01:32 - Prompting the Interface
02:31 - Fixing Cursor Animations
04:20 - Final Result & Review

📱 X: https://x.com/leonardogrig

💼 LinkedIn: https://www.linkedin.com/in/leonardogrig
---

This has got to be one of the coolest
things that you've seen today.
Basically, Remotion now has agent
skills. And what that means is that we
can create entire videos like this one
by just using claude code. So, in this
video, we'll go through exactly how you
can do that. First, you'll want to
create a folder. Go inside of that
folder and once in there, type in bun
create video. As simple as this. Now,
here you'll want to select a template.
Select blank. Let me zoom out a bit. And
yes, I want to use Tailwind. If all goes
well, you'll probably see the enjoy
remotion message at which you'll type in
bunks skills add reotion-dev/
skills or just go with npx. Hit enter.
It'll ask you which skill you want to
install. So there's anti-gravity, cloud
code, codeex, cursor, gemini. I'll go
with cloud code. And I'll actually
cancel my installation since I've
already gone through this process. But
now that it created the project, let me
just type in bun I to install all of the
packages. All right. Now with all the
packages installed, let me zoom out.
Type in bundev. Wait for it to open the
localhost 3000 or whatever port is
available. You should now see something
like this. If yours opens up without
being inside of the composition, it'll
probably be just gray area. So, click on
my comp and it should open up this
interface. Now, we can go over to
Claude. Let me run it with dangerously
skip permissions. Okay, now it's time to
get creative. My prompt will be this. I
haven't tested this before, by the way,
but create a web window interface that
is opened inside of a YouTube video. And
then place in the name of my channel.
The video shows the Cloud Code terminal
interface and it starts typing, "This is
way too cool." So, as simple as this.
Um, let's actually take a screenshot of
how the claude terminal looks like. So,
has that as context. And now, just hit
enter and let's see what it builds for
us. It's been around 2 minutes now, and
it's the first time something happens.
But I feel like it's been creating a
bunch of different components. Let me
hit
Yeah, this is actually way too cool.
Just imagine where we'll be with this in
a few months from now. It's opening up a
bunch of different instances. So, let me
tell Claude don't run npm rundev as it
is already running. And don't use npm,
use button. Okay, but what should we do
now? I think I'm going to make it scroll
down and click on the like button and
subscribe like have that nice
interaction. So, I added make sure that
at the end when it's done typing this is
way too cool. It seems as if the user is
scrolling down inside the YouTube page
and it shows a cursor clicking on the
like button then on the subscribe
button. Oh, and by the way, for more
context, if you want to see how they
built this example, uh there's an entire
video that's actually in like 10x the
speed, but I mean you can you might want
to use it as a reference for prompting.
Uh by the way, those prompts are here as
well. But it's really about knowing what
you want to build and aiming towards
building something that can be kind of
drawn into a web interface. Not like uh
draw myself in a YouTube video like
produce my entire video for me. Let's
see how it's going with that. Seems
pretty cool. So it already presume that
the video will reach 2.5,000 views. Uh
seems like it's done actually. Let's
watch. So play it. Scrolls down. There's
a cursor there. the c. So, the cursor
really isn't clicking on the like button
nor on the subscribe because it's like
all the way up here. Let me take a
screenshot of this and send it over to
Claude. So, all I said is the cursor
should be bigger and it isn't exactly on
top of the buttons. Okay, it seems like
it changed the cursor's position, but
it's not quite there yet. One thing we
can do is just find out where are these
positions. This could be a bit tricky.
All right, so this is what we got. It
types in this is way too cool, then goes
over to the like button, kind of clicks
that. So, it seems like it dashes
through the like button and then goes
already up to subscribe. But yeah, we
could improve this in many different
ways, like just adding the other
thumbnails and videos here, making sure
this description is bigger, uh
correcting this cursor, like making it
bigger overall. But just the fact that
we built all this by talking to an AI
agent is absolutely fantastic. This
video isn't sponsored at all, but as a
content creator, I know how hard it is
sometimes to just build these type of
things. And just knowing that AI agents
can do all this for us already is pretty
amazing. So, make sure to check out
Remotion. Their link will be in the
description of the video as well as the
description to as well as the prompt
GitHub links and this expost. Thanks for
watching and I'll see you guys in the
next video. Intellect.
