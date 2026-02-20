---
url: https://www.youtube.com/watch?v=fOY0_WCR3eY
title: Claude Code can now make videos, here’s how
channel: David Ondrej
created: 2026-01-23
uploader: David Ondrej
view_count: 96267
like_count: 4281
comment_count: 150
tags: David Ondrej, david ondrej, AI, ChatGPT, artificial intelligence, ai, Artificial Intelligence, OpenAI, chatgpt, chat gpt, Chat GPT, AGI, midjourney, david ondrej podcast, GPT, new society, david ondrej new society, david ondrej community, make money with AI, AI Agents, ai agent, AI Agent Startup, AI SaaS, AI Startup, claude code, remotion
description: Wanna learn how to code with AI? Go here: https://www.skool.com/new-society

Learn about the best AI Business models here - https://www.youtube.com/watch?v=Ta5g-OxjPO4

Wanna scale your AI business? Go here: https://www.scalesoftware.ai/start

Follow me on Instagram - https://www.instagram.com/davidondrej1/
Follow me on Twitter - https://x.com/DavidOndrej1

AgentZero: https://github.com/agent0ai/agent-zero

Remotion: https://www.remotion.dev/

Host your n8n agents on Hostinger: https://www.hostinger.com/david

Subscribe if you're serious about AI.

Claude Code can now make and edit your videos, with remotion

www.vectal.ai
---

So, Cloth Code can now make videos. You
tell it what you want in plain English,
and it creates professional animations
from scratch. It's insane. For example,
this entire video you're watching right
now was made just by typing into close
code. No animations, no touching UI,
plain English. Now, you might be
thinking, "But David, how is this even
possible?" Well, all of this is powered
by Remotion, which lets us create videos
programmatically. But now, Remotion has
released their own agent skills, which
means that Cloud Code, Open Code, and
other AI agents can finally use it. So,
in this video, we'll go over what
Remotion is, how to set up these new
agent skills, and how to actually use it
for your own AI marketing to grow your
business. So, make sure to watch until
the end. Here's another example of what
this Remotion skill can do. Now,
everything except for the design of the
characters was generated and stitched
together with cloth code. So, this
entire video you're watching was created
with cloth code. someone typing English
and clothes code designing a video of
this video game. Crazy. Here's another
example that was made with Remotion,
Clothe code and anti-gravity. Now,
personally, I'm not a animator or a
designer and doing something like this
would take me many, many hours because I
would first have to learn these
softwares. But now, you can just type to
close code and close code will build it
for you. So, not only can you use AI to
build your product, now you can use AI
to market it as well. It has never been
a better time to start your own
business. Okay. So, what is remote?
What's the thing that makes all of this
possible? Well, Remotion is a framework
for creating videos programmatically
using Rust. And the code looks something
like this. You can think of it as a
website that gets recorded frame by
frame into a video file. So you get the
data either from APIs, databases or user
input. And then each of the render that
motion makes produces a unique video
automatically. Now the reason why AI
agents love it is that they are great at
writing code. So whether it's cloud
code, open code or any other coding
agent, they already excel at writing
code. However, these same agents are
terrible at using complex graphical user
interfaces like After Effects, Premiere
Pro or any other app designed for
humans. Remotion fixes this. It turns
video creation and animations into React
components. So all the agents have to do
is write a few React components and the
result is a beautiful looking video or
animation. So any of you that are
building your own app or you have your
own business, here is how you could use
remotion to create product videos. So
this is another one built just with
cloud code and just with a motion. Look
at this professional looking animation
of email looks like Gmail highlighting
moving cursor text. You would have to
pay thousands of dollars to an animator
or designer to do this. Now it's just a
few prompts to glot code with the motion
skill. And of course I'm going to show
you how to set it up later in the video,
but I just want to show you how
impressive this really is. Here's one
more example. Now, obviously, this guy
gave it these assets, right? So, if you
have great quality images or assets, it
will do even better. But the animation
cycling between them was built by
Remotion. By the way, this agent skill
came out literally less than 24 hours
ago. So, if you want to stay on the
cutting edge of AI, make sure to
subscribe. It takes 2 seconds and it
helps out a lot. Thank you. Now, let's
look at how Remotion works under the
hood. The first thing you have to
understand is the sequence components.
And these place elements in time, just
like in any video editing tool, you have
a something like a timeline. And each of
these are sequence components. Now, when
you start your development server with
npm rundev, you get a local host player,
something like this, where you can scrap
through your video in real time and
actually see what the different sections
look like. And when you're ready and
when you want to actually render it,
each of the frames gets screenshotted
and stitched into an MP4 through FFmpeg.
Now, let's talk about agent skills
because this is a relatively new concept
that most people don't understand. Agent
skills are instruction files that teach
AI coding agents like close code and
open code how to work with specific
tools. Now, the beauty of agent skills
is that they use what's called
progressive disclosure. You don't just
dump a bunch of tokens, a bunch of
prompts into context window. That would
be wasteful. Instead, cloth only loads
the skills full instructions when your
task matches its description. So, if
your task is about coding, it's not
going to load the skills about video
editing. But if your prompt does mention
video editing, it will load the skills
about video editing. This progressive
disclosure principle always keeps the
context lean. Now skills are an open
standard meaning it's something like
MCPS something that's becoming like the
agents.mmd file right something that
more and more companies and agents are
adopting across the whole AI ecosystem
so today skills work across cloth code
agent zero open code and many other
agents so the big news here is that
remotion created their own agent skill
that you can just plug and play into
these agents and have them creating
professional animations right away. Now,
this emotion skill contains all of the
API patterns for emotion, the different
component conventions and best practices
for writing animations. So, when you ask
CL to create a video, it reads these
instructions and generates proper
emotion code. The skill also bundles
reference docs for specific topics like
3D audio captions. So, Claude only loads
whatever it needs for that task. And
since Remotion is very easy to use
because you just type to cloth code and
cloth code runs the code, people are
creating impressive animations on their
first try, which you're watching right
now. This was made with just a couple of
prompts on the very first try. Now,
there are some clear best practices that
will decide whether you get mediocre
results with this skill or whether you
get great animations from the motion.
First off, always start with a clear
storyboard. You need to describe each
scene before prompting cloth. Also, the
best results require an iterative
approach instead of trying to oneshot
everything. Start with small prompts,
see the result, adjust the prompt, so on
and so forth. Usually, the best motion
animations I've seen required five to 10
prompts at least. And pro tip, make sure
to keep your compositions modular. So,
build reusable components for intros,
transitions, outros. Don't try to put
everything into a single component. And
as I said earlier, give it high quality
assets. Right? If you're building a
video game, give it the sprites. If
you're designing a product, give it high
quality product photos. The better
assets you provide, the better the
outcome will be. And now, let me show
you how to actually set this up. First
thing we have to do is go to remote.dev.
So, make sure to click on this u npx
create command. It will copy it into
your clipboard. Then open a terminal and
we need to cd into a folder where we
want to build this. So, let's do cd
documents get ls cd into David Andre.
Boom. All right. I'm going to paste the
terminal command in this folder. Choose
a blank template. Boom. Add tailwind.
Yes. Add agent skills. Yes, for sure.
And there we go. Open a cursor. Yes.
There we go. Here's our project with a
full remote setup. Let me close some of
these sidebars that always pop up. So,
you can see we have everything on the
right that we need for a blank motion
project. And what remains is installing
the skill. Now, this is the skills.sh
page developed by Versel. I'm going to
link this below the video, but again,
you just need to click this to copy the
terminal command. Go back to the
terminal. Type in clear and paste it in.
Yes, we want to install this package.
There we go. We have the skills. Select
agents. We're going to use cloth code.
And here you can select whether you want
to install Remotion for just this
project or globally. It's up to you.
Installation method. Let's do Sim. And
let's proceed with installation. Done.
And that's it. The setup is very simple.
Again, if you're afraid of using the
terminal, why? Like, you just copy paste
a few commands and it asks you in plain
English. Don't be afraid of the
terminal. It's a limiting belief. In
2026, you must be using the terminal to
be on the cutting edge of AI. Next up,
let's go back into our IDE. And then
let's open a terminal in this same
folder. Type in cloth to launch CL code.
Give it permissions for this folder. Go.
Let me move it here. Let's do SLSkill to
see if we have available skills. And
there we go. Project skills. Yes,
promotion best practices. Amazing. Let's
click escape. So now it means that the
skill has been successfully installed
and cloud code knows about it. Now again
I would recommend you to create a
separate folder a clear directory for
this. So that's what I did right here.
You know I created a motion folder with
this project folder and everything is
happening in here so I'm not messing the
files all across my computer. I'm going
to run it in this folder and I'm going
to let cloth code cook right here. This
is a great practice when working with
any coding agents. Now when using
remotion skill through cloth code, you
have to remember that animations are
created by simple prompts. So make sure
to use a very detailed prompt and ask
cloth to use the remotion skill. So I
just pasted it as well so that I give
Claude context on what you're doing. The
next thing I would recommend you to do
is to ask CL to create a separate
subdirectory for each animation to keep
things organized. So basically you'll
have like one root folder like this and
this shouldn't have any animations right
here because you'll have multiple
subfolders for each of the animations.
All right. So clo understands it and now
it has all the context. So we can start
building our first animation. So let's
create a new folder and I'm going to
name it prompts and I'm going to create
a new file in there named prompt01.md.
And this is going to be our first
prompt. As you can see it's very
detailed and that's because I want a
great result for this animation. So,
it's going to be a visual animation in
the style of free blue, one brown. If
you don't know this channel, you're
greatly missing out. This is one of the
best YouTube channels when it comes to
math education, also some videos on AI,
LLM, how does Bitcoin work. Really great
channel, and it's known for having
beautiful animations. So, we're going to
use Remotion to try to replicate his
style. Now, this is a very detailed,
obviously written with AI as well, but
very detailed uh description of what we
want to build. So, you should be as
detailed as possible when using remote.
Actually, we can probably delete several
of these. All right, just cleaned up a
bit. I'm going to interrupt this. Okay,
I'm going to tell it to stop regressing,
read prompt 01, and actually build it
using the remote skills you have. Boom.
Enter. As you can see, the prompt is 400
lines. Very detailed prompt. And now,
let's watch Claude do the magic. So, now
uh it's asking to use the skill. So, I'm
going to select yes. And don't ask again
because uh I don't need to accept this
skill every single time. As you can see,
it's loading specific things. Animations
MD, timing.md, and sequencer MD. So it's
not loading everything from the skill,
only the parts it needs. And this is the
progressive disclosure, right? This is
this is what's keeping the context
engineering optimal. So now it's
creating all subdirectory right here.
Pythagorean. So there it goes. Clothe
code is running the react code for
remote. So this is uh like 77 lines of
code. is 81. It's doing different
components. So, very nice. One for the
animated line, one for triangle, one for
square. So, it's creating reusable
components. That way, we can reuse them.
It's in the word opening index. It's
creating a lot of files. So, I'm
interested in this animation. All right,
let's do npm rundef.
See what this looks like. This is the
motion UI.
So far, we don't have anything, but this
is what it will look like. It's similar
to any video editing tool as you can
see. Let's go to the main cloth code.
Still cooking up the animation. 17,000
tokens going for 4 minutes. So the best
animations take some time. This is not
like a single thing that you're going to
get like in 1 second because keep in
mind cloud code has to write hundreds of
lines of code for these different React
components because remote works on
React. Oh, there we go. Okay, so the
main cloud code finally updated root.tsx
tsx by registering these different
components. I like this new cloud code
UI. It's very clean. Oh, never mind.
That's crazy. [laughter]
I I complement the new design and it
breaks completely. Anyways, uh it's
removing the unused variables now. So,
hopefully we won't get any other llinter
errors. 10 minutes, guys. 10 minutes for
this animation. It's pretty insane. Few
like cloth core few months ago would
never run for 10 minutes. So, Enthropic
is making it less lazy. There is a
complete. Okay, let's see. All right,
there we go. There we go.
The Pyan proofs animation is complete.
Here's what was created. Project
structure, main orchestrator,
self-drawing lines, triangle intro.
Okay, let's see. ID by figure and proofs
duration 2,400 frames, 40 seconds at 60
fps. To preview, run npm rundef and
select py proofs composition in the
motion studio. So, let's do that. Let's
kill this. Boom. NPM rundev. On the
left, we have the compositions. Let's
select pyan proofs. And as you can see,
we have a timeline with multiple
different sequences. So, let's run it.
This is pretty nice. Okay, guys. This is
this is wild. Let me make this bigger.
This is actually crazy. Written by cloth
code. Imagine having to do this by
yourself.
Doing this manually would take forever.
single prompt in plain English.
Okay, some of these are wrong order
obviously but again one prompt
this is wild. Okay, this is mis a little
misaligned but hey nothing you can't fix
in future prompts and again all of this
is code so all of this is programmatic
okay so let me give you one more example
this time with some assets so I'm going
to create a new prompt new file prompt
O2 boom paste it in a little shorter
almost 200 this is going to be a
advertisement for cloth code so I have
this u image right here cloth startp is
just a you a screenshot of the cloud
code UI. So I'm going to say read prompt
O2
and using cloud
startup create the animation in
remotion. The fewer lines of code, the
better. Don't want it to be running for
12 minutes again. Let's see if it
remembers the subfolder directory
because that's what we instructed it to
create subfolders for each. So it moved
the PNG file into public. Okay, because
uh I guess that's where assets go. And
now it created the cloth ad subfolder
which is empty for now. It's going to
create the whole folder structure for a
motion composition. So again inside of
the browser you can have different
compositions, right? This is the default
one and this is the pyan proof one. Can
split it up to 4x and on the sequence
below you can like disable different
parts, right? So maybe you don't want
this one. You can hide it. It's a it's a
proper video editor. like it's not as
advanced as Premiere obviously, but uh
it's solid. It's solid and everything is
programmatic. Everything is react code
and you can see your assets right here.
So obviously we have the clo startup
file and now we have the clo add. So we
can see it's being built in real time.
Clothe ad is here.
Okay, let's zoom out to fit.
Look at this. Is it finished yet? Okay,
this one's faster. Okay, 2 minutes
composition code add duration 17
seconds. Cursor moves to do terminal
icon click. Let's look at this. Let's
play it in 1x from the beginning. So, we
have a desktop view here. Make it a bit
bigger. So, the term go icon clicks.
Okay, it didn't click on the terminal.
It clicked on the browser, but it opens
the terminal. It types in cd subscribe
to the channel. Very nice. Look at this
guys. This is crazy. This is all code.
This is all animated. Let me replay
this.
Like doing this manually if you're not
an animator would take a lot of time.
It's a advertisement for cloud code in a
single prompt less than 2 minutes.
Obviously, this one was a lot faster
than the previous one and it has less
detail, but you can follow it up. You
can say like change the background
gradient to be cloud orange color
instead. Boom. And let's watch it change
in real time.
There we go. Change the clothes code.
Already much better. Already feels way
more like cloth code.
You literally animating by typing plain
English. If you're not using cloth code
in 2026, you are falling behind. In
2026, you really cannot afford to fall
behind. Now, if you want to take things
to the next level and actually start an
AI business this year, I made a full
video on just on that. It's going to be
right here on the screen. So go wash it
out.
